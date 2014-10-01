/* 
 * This file is part of Transitime.org
 * 
 * Transitime.org is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (GPL) as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Transitime.org is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Transitime.org .  If not, see <http://www.gnu.org/licenses/>.
 */
package org.transitime.core;

import java.util.Collections;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Objects;

import org.transitime.configData.CoreConfig;
import org.transitime.db.structs.Arrival;
import org.transitime.db.structs.AvlReport;
import org.transitime.db.structs.Block;
import org.transitime.db.structs.Location;
import org.transitime.db.structs.StopPath;
import org.transitime.db.structs.Trip;
import org.transitime.db.structs.VectorWithHeading;
import org.transitime.ipc.data.IpcPrediction;
import org.transitime.utils.StringUtils;
import org.transitime.utils.Time;

/**
 * Keeps track of vehicle state including its block assignment, where it
 * last matched to its assignment, and AVL reports.
 * 
 * @author SkiBu Smith
 *
 */
public class VehicleState {

	private final String vehicleId;
	private Block block;
	private BlockAssignmentMethod assignmentMethod;
	private String assignmentId;
	private Date assignmentTime;
	private boolean predictable;
	// First is most recent
	private LinkedList<TemporalMatch> temporalMatchHistory = 
			new LinkedList<TemporalMatch>();
	// First is most recent
	private LinkedList<AvlReport> avlReportHistory =
			new LinkedList<AvlReport>();
	private List<IpcPrediction> predictions;
	private TemporalDifference realTimeSchedAdh;
	
	// For keeping track of how many bad matches have been encountered.
	// This way can ignore bad matches if only get a couple
	private int numberOfBadMatches = 0;
	
	// So can make sure that departure time is after the arrival time
	private Arrival arrivalToStoreToDb;
	private long lastArrivalTime = 0;
	
	// So can keep track of whether assigning vehicle to same block that
	// just got unassigned for. The unassignedTime member is the time when the
	// vehicle was unassigned.
	private Block previousBlockBeforeUnassigned = null;
	private Date unassignedTime = null;
	
	private static int MATCH_HISTORY_MAX_SIZE = 6;
	private static int AVL_HISTORY_MAX_SIZE = 6;
	
	/********************** Member Functions **************************/

	public VehicleState(String vehicleId) {
		this.vehicleId = vehicleId;
	}
	
	/**
	 * Sets the block assignment for vehicle. Also, this is how it is specified
	 * whether a vehicle is predictable or not.
	 * 
	 * @param newBlock
	 *            The current block assignment for the vehicle. Set to null if
	 *            vehicle not assigned.
	 * @param assignmentMethod
	 *            How vehicle was assigned (AVL feed, auto assigner, etc). Set
	 *            to null if vehicle not assigned.
	 * @param assignmentId
	 *            Can be blockId, tripId, or tripShortName. Depends on type of
	 *            assignment received from AVL feed. Can be null.
	 * @param predictable
	 *            Whether vehicle is predictable
	 */
	public void setBlock(Block newBlock, BlockAssignmentMethod assignmentMethod, 
			String assignmentId, boolean predictable) {
		// When vehicle is made unpredictable remember the previous assignment
		// so can tell if getting assigned to same block again (which could
		// indicate a problem and arrival/departure times shouldn't be generated.
		if (this.block != null && newBlock == null) {
			this.previousBlockBeforeUnassigned = this.block;
			this.unassignedTime = getAvlReport().getDate();
		}

		this.block = newBlock;
		this.assignmentMethod = assignmentMethod;
		this.assignmentId = assignmentId;
		this.predictable = predictable;
		this.assignmentTime = getAvlReport().getDate();		
	}
	
	/**
	 * Sets the block for this VehicleState to null. Also sets assignmentId
	 * to null and predictable to false.
	 * 
	 * @param assignmentMethod
	 *            How vehicle was assigned (AVL feed, auto assigner, etc). Set
	 *            to null if vehicle not assigned.
	 */
	public void unsetBlock(BlockAssignmentMethod assignmentMethod) {
		setBlock(null, // newBlock
				assignmentMethod, 
				null,   // assignmentId
				false); // predictable
	}
	
	/**
	 * Determines if vehicle is currently getting assigned and it is getting assigned
	 * back to the same block it was assigned to just a while ago. In other
	 * words this tells if vehicle might have become unpredictable but then is
	 * getting reassigned again. In this kind of situation don't want to for
	 * example determine arrivals/departures back to the beginning of the block
	 * because probably already did so when vehicle was previously assigned.
	 * 
	 * @return True if vehicle is being reassigned to the same block as before
	 */
	public boolean vehicleNewlyAssignedToSameBlock() {
		// If previously wasn't assigned but it is now then it is 
		// newly assigned...
		if (getPreviousMatch() == null && getMatch() != null) {
			// If being assigned to same block it had previously...
			if (previousBlockBeforeUnassigned == getBlock()) {
				// If didn't get unassigned that long ago
				if (getAvlReport().getTime() <  
						this.unassignedTime.getTime() + 20 * Time.MS_PER_MIN) {
					// It is being newly assigned to the same block it was 
					// recently unassigned from
					return true;
				}
			}
		}
		
		// Vehicle not newly assigned
		return false;
	}
	
	/**
	 * Sets the match for the vehicle into the history. If set to null then
	 * VehicleState.predictable is set to false. Also resets numberOfBadMatches
	 * to 0.
	 * 
	 * @param match
	 */
	public void setMatch(TemporalMatch match) {
		// Add match to history
		temporalMatchHistory.addFirst(match);
		
		// Set predictability
		if (match == null) {
			predictable = false;
			
			// Make sure that the arrival time buffer is cleared so that
			// when get a new assignment won't try to use it since something
			// peculiar might have happened.
			setArrivalToStoreToDb(null);
		}
		
		// Reset numberOfBadMatches
		numberOfBadMatches = 0;
		
		// Truncate list if it has gotten too long
		while (temporalMatchHistory.size() > MATCH_HISTORY_MAX_SIZE) {
			temporalMatchHistory.removeLast();
		}
	}
	
	/**
	 * Returns the last temporal match. Returns null if there isn't one.
	 * @return
	 */
	public TemporalMatch getMatch() {
		try {
			return temporalMatchHistory.getFirst();
		} catch (NoSuchElementException e) {
			return null;
		}
	}

	/**
	 * To be called when predictable vehicle has no valid spatial/temporal
	 * match. Only allowed so many of these before vehicle is made
	 * unpredictable.
	 */
	public void incrementNumberOfBadMatches() {
		++numberOfBadMatches;
	}
	
	/**
	 * Returns if have exceeded the number of allowed bad matches. If so
	 * then vehicle should be made unpredictable.
	 * 
	 * @return
	 */
	public boolean overLimitOfBadMatches() {
		return numberOfBadMatches > CoreConfig.getAllowableNumberOfBadMatches();
	}
	
	/**
	 * Returns the number of sequential bad spatial/temporal matches that
	 * occurred while vehicle was predictable.
	 * 
	 * @return current number of bad matches
	 */
	public int numberOfBadMatches() {
		return numberOfBadMatches;
	}
	
	/**
	 * Returns true if the last AVL report was successfully matched to the
	 * assignment indicating that can generate predictions and arrival/departure
	 * times etc.
	 * 
	 * @return True if last match is valid
	 */
	public boolean lastMatchIsValid() {
		return numberOfBadMatches == 0;
	}
	
	/**
	 * Stores the specified avlReport into the history for the vehicle.
	 * Makes sure that the AVL history doesn't exceed maximum size.
	 * 
	 * @param avlReport
	 */
	public void setAvlReport(AvlReport avlReport) {
		// Add AVL report to history
		avlReportHistory.addFirst(avlReport);
		
		// Truncate list if it is too long or data in it is too old
		while (avlReportHistory.size() > AVL_HISTORY_MAX_SIZE) {
			avlReportHistory.removeLast();
		}
	}
	
	/**
	 * Returns the current Trip for the vehicle. Returns null if there is not
	 * current trip.
	 * 
	 * @return Trip or null.
	 */
	public Trip getTrip() {
		TemporalMatch lastMatch = getMatch();
		return lastMatch!=null ? lastMatch.getTrip() : null;
	}
	
	/**
	 * Returns the current route ID for the vehicle. Returns null if not
	 * currently associated with a trip.
	 * 
	 * @return Route ID or null.
	 */
	public String getRouteId() {
		Trip trip = getTrip();
		return trip!=null ? trip.getRouteId() : null;
	}
	
	/**
	 * Returns the current route short name for the vehicle. Returns null if not
	 * currently associated with a trip.
	 * 
	 * @return route short name or null
	 */
	public String getRouteShortName() {
		Trip trip = getTrip();
		return trip!=null ? trip.getRouteShortName() : null;
	}
	
	/**
	 * Returns true if last temporal match for vehicle indicates that it is at a
	 * layover. A layover stop is when a vehicle can leave route path before
	 * departing this stop since the driver is taking a break.
	 * 
	 * @return true if at a layover
	 */
	public boolean atLayover() {
		TemporalMatch temporalMatch = getMatch();
		if (temporalMatch == null)
			return false;
		else
			return temporalMatch.isLayover();
	}
	
	/**
	 * Returns the next to last temporal match. Returns null if there isn't
	 * one. Useful for when need to compare the previous to last match with
	 * the last one, such as for determining if vehicle has crossed any
	 * stops.
	 * 
	 * @return
	 */
	public TemporalMatch getPreviousMatch() {
		if (temporalMatchHistory.size() >= 2)
			return temporalMatchHistory.get(1);
		else
			return null;
	}

	/**
	 * Returns the current AvlReport. Returns null if there isn't one.
	 * @return
	 */
	public AvlReport getAvlReport() {
		try {
			return avlReportHistory.getFirst();
		} catch (NoSuchElementException e) {
			return null;
		}
	}
	
	/**
	 * Looks in the AvlReport history for the most recent AvlReport that is
	 * at least minDistanceFromCurrentReport from the current AvlReport.
	 * Also makes sure that previous report isn't too old.
	 * 
	 * @param minDistanceFromCurrentReport
	 * @return The previous AvlReport, or null if there isn't one that far away
	 */
	public AvlReport getPreviousAvlReport(double minDistanceFromCurrentReport) {
		// Go through history of AvlReports to find first one that is specified
		// distance away from the current AVL location.
		long currentTime = getAvlReport().getTime();
		Location currentLoc = getAvlReport().getLocation();
		for (AvlReport previousAvlReport : avlReportHistory) {
			// If the previous report is too old then return null
			if (currentTime - previousAvlReport.getTime() > 20 * Time.MS_PER_MIN)
				return null;
			
			// If previous location far enough away from current location
			// then return the previous AVL report.
			Location previousLoc = previousAvlReport.getLocation();
			if (previousLoc.distance(currentLoc) > minDistanceFromCurrentReport) {
				return previousAvlReport;
			}
		}
		
		// Didn't find a previous AvlReport in history that was far enough away
		// so return null
		return null;
	}

	/**
	 * Returns the next to last AvlReport where successfully matched the
	 * vehicle. This isn't necessarily simply the previous AvlReport since that
	 * report might not have been successfully matched. It is important to use
	 * the proper AvlReport when matching a vehicle or such because otherwise
	 * the elapsed time between the last successful match and the current match
	 * would be wrong.
	 * 
	 * @return The last successfully matched AvlReport, or null if no such
	 *         report is available
	 */
	public AvlReport getPreviousAvlReportFromSuccessfulMatch() {
		if (avlReportHistory.size() >= 2+numberOfBadMatches) 
			return avlReportHistory.get(1+numberOfBadMatches);
		else
			return null;
	}

	/**
	 * Returns true if the AVL report has a different assignment than what is in
	 * the VehicleState. For when reassigning a vehicle via the AVL feed.
	 * 
	 * @param avlReport
	 * @return
	 */
	public boolean hasNewAssignment(AvlReport avlReport) {		
		return  !Objects.equals(assignmentId, avlReport.getAssignmentId());
	}
	
	/**
	 * Returns true if previously the vehicle had the same assignment but that
	 * assignment was recently removed due to a problem where the vehicle
	 * shouldn't be assigned to that assignment again. A specific example is
	 * that this happens if an exclusive block assignment is grabbed by another
	 * vehicle. Even though the original vehicle with the assignment might
	 * continue to get that assignment via the AVL feed don't want to reassign
	 * it to the problem assignment again.
	 * <p>
	 * BUT WHAT ABOUT A VEHICLE SIMPLY BECOMING UNPREDICTABLE BECAUSE IT 
	 * TEMPORARILY WENT OFF ROUTE FOR 3 AVL REPORTS?? IN THAT CASE WANT VEHICLE
	 * TO MATCH ASSIGNMENT AGAIN. OR WHAT IF BLOCK SIMPLY ENDED??
	 * SEEMS THAT NEED TO REMEMBER IF VEHICLE WAS UNASSIGNED IN SUCH A WAY
	 * THAT SHOULDN'T TAKE THAT ASSIGNMENT AGAIN FOR A WHILE.
	 * <p>
	 * An old assignment is considered recent if the unassignment happened
	 * within the last 2 hours.
	 * 
	 * @param avlReport
	 * @return True if vehicle already had the assignment but it was problematic
	 */
	public boolean previousAssignmentProblematic(AvlReport avlReport) {
		// If the previous assignment is not problematic because it wasn't
		// grabbed or terminated then it is definitely not problematic.
		if (assignmentMethod != BlockAssignmentMethod.ASSIGNMENT_GRABBED
				&& assignmentMethod != BlockAssignmentMethod.ASSIGNMENT_TERMINATED)
			return false;
		
		// If the AVL report indicates a new assignment then don't have to
		// worry about the old one being problematic
		if (hasNewAssignment(avlReport))
			return false;
		
		// Got same assignment from AVL feed that was previously problematic.
		// If the old problem assignment was somewhat recent then return true.
		return avlReport.getTime() - unassignedTime.getTime() < 
				2 * Time.MS_PER_HOUR;  
	}
	
	/********************** Getter methods ************************/
	
	/**
	 * Returns an unmodifiable list of the match history. The most recent
	 * one is first. The size of the list will be not greater than
	 * MATCH_HISTORY_SIZE.
	 * 
	 * @return the match history
	 */
	public List<TemporalMatch> getMatches() {
		return Collections.unmodifiableList(temporalMatchHistory);
	}
	
	/**
	 * The current block assignment. But will be null if vehicle not currently
	 * assigned.
	 * 
	 * @return
	 */
	public Block getBlock() {
		return block;
	}

	/**
	 * Can be the blockId, tripId, or tripShortName depending on the type of
	 * assignment received from the AVL feed.
	 * 
	 * @return blockId, tripId, or tripShortName or null if not assigned
	 */
	public String getAssignmentId() {
		return assignmentId;
	}
	
	/**
	 * Indicates how the vehicle was assigned (via block assignment, route
	 * assignment, auto assignment, etc).
	 * 
	 * @return
	 */
	public BlockAssignmentMethod getAssignmentMethod() {
		return assignmentMethod;
	}

	public Date getAssignmentTime() {
		return assignmentTime;
	}

	public String getVehicleId() {
		return vehicleId;
	}
	
	public boolean isPredictable() {
		return predictable;
	}
	
	/**
	 * Returns true if not a real vehicle but instead was created to produce
	 * schedule based predictions.
	 * 
	 * @return true if for schedule based predictions
	 */
	public boolean isForSchedBasedPreds() {
		AvlReport avlReport = getAvlReport();
		return avlReport != null && avlReport.isForSchedBasedPreds();
	}
	
	/**
	 * Records the specified arrival as one that still needs to be stored to the
	 * db. This is important because can generate arrivals into the future but
	 * need to make sure that the arrival is before the subsequent departure and
	 * can't do so until get additional AVL reports.
	 * 
	 * @param arrival
	 */
	public void setArrivalToStoreToDb(Arrival arrival) {
		this.arrivalToStoreToDb = arrival;
	}
	
	public Arrival getArrivalToStoreToDb() {
		return arrivalToStoreToDb;
	}
	
	/**
	 * Sets the current list of predictions for the vehicle to the
	 * predictions parameter.
	 * 
	 * @param predictions
	 */
	public void setPredictions(List<IpcPrediction> predictions) {
		this.predictions = predictions;
	}
	
	/**
	 * Gets the current list of predictions for the vehicle. Can be null.
	 * @return
	 */
	public List<IpcPrediction> getPredictions() {
		return predictions;
	}
	
	/**
	 * Stores the real-time schedule adherence for the vehicle.
	 * 
	 * @param realTimeSchedAdh
	 */
	public void setRealTimeSchedAdh(TemporalDifference realTimeSchedAdh) {
		this.realTimeSchedAdh = realTimeSchedAdh;
	}
	
	/**
	 * Returns the current real-time schedule adherence for the vehicle, or null
	 * if schedule adherence not currently valid (vehicle is not predictable or
	 * running a non-schedule based assignment).
	 * 
	 * @return The TemporalDifference representing schedule adherence, or null
	 *         if vehicle not currently predictable.
	 */
	public TemporalDifference getRealTimeSchedAdh() {
		if (isPredictable())
			return realTimeSchedAdh;
		else
			return null;
	}
	
	/**
	 * Determines the heading of the vector that defines the stop path segment
	 * that the vehicle is currently on. The heading will be between 0.0 and
	 * 360.0 degrees.
	 * 
	 * @return Heading of vehicle according to path segment. NaN if not
	 *         currently matched or there is no heading for that segment.
	 */
	public float getPathHeading() {
		// If vehicle not currently matched then there is no path heading
		SpatialMatch match = getMatch();
		if (match == null)
			return Float.NaN;
				
		// If layover stop then the heading of the path isn't really valid
		// since the vehicle might be deadheading to the stop.
		StopPath stopPath = getTrip().getStopPath(match.getStopPathIndex());
		if (stopPath.isLayoverStop())
			return Float.NaN;
		
		// Vehicle on non-layover path so return heading of that path.
		VectorWithHeading vector = 
				stopPath.getSegmentVector(match.getSegmentIndex());
		return vector.getHeading();
	}

	/**
	 * For when trying to get heading but vehicle is at a layover. Can't use
	 * heading of layover because vehicle might be deadheading and therefore
	 * heading in a different direction of the layover segment. Plus the layover
	 * segment is usually just a stub segment that might not have valid
	 * direction at all. This method can be used to get the heading of the next
	 * path segment, which should be valid. But only uses next path heading
	 * if vehicle is actually within 200m of the layover. Otherwise the
	 * vehicle is deadheading and don't want to use the next path heading
	 * if vehicle is actually reasonably far away from the layover.
	 * 
	 * @return
	 */
	private float getNextPathHeadingIfAtLayover() {
		// If vehicle not currently matched then there is no path heading
		SpatialMatch match = getMatch();
		if (match == null)
			return Float.NaN;

		// This is only for layovers so if not at layover return NaN
		if (!match.isLayover())
			return Float.NaN;
		
		// Determine if actually at the layover instead of deadheading. If more
		// than 200m away then don't use the next path heading. Instead 
		// return NaN.
		double distanceToLayoverStop = match.getStopPath()
				.getEndOfPathLocation().distance(getAvlReport().getLocation());
		if (distanceToLayoverStop > 200.0) 
			return Float.NaN;
		
		// Vehicle is reasonably close to the layover stop so determine the
		// heading of the segment just after the layover.
		// If already at end of trip can't go on to next stop path
		if (getTrip().getNumberStopPaths() <= match.getStopPathIndex()+1)
			return Float.NaN;

		// Determine the next first segment vector of the next path
		StopPath stopPath = getTrip().getStopPath(match.getStopPathIndex()+1);
		VectorWithHeading vector = stopPath.getSegmentVector(0);
		
		return vector.getHeading();
	}
	
	/**
	 * Looks in avlReportHistory and returns last valid heading. Will still
	 * return null in certain situations such as there not being a history, the
	 * AVL report is old, never have valid heading info, etc.
	 * <p>
	 * Reports are considered too old if they are more than 2 minutes old. This
	 * is useful distinction because if report is too old then don't really know
	 * if the heading is valid. At layovers it is likely that a vehicle turned a
	 * corner a bit before the layover point and don't want to show the old
	 * heading before the turn.
	 * 
	 * @return
	 */
	private float recentValidHeading() {
		long maxAge = System.currentTimeMillis() - 2 * Time.MS_PER_MIN;
		
		for (AvlReport avlReport : avlReportHistory) {
			// If report is too old then don't use it
			if (avlReport.getTime() < maxAge)
				return Float.NaN;
			
			// If AVL has valid heading then use it
			if (!Float.isNaN(avlReport.getHeading())) {
				return avlReport.getHeading();
			}
		}
		
		// No reports have a valid heading so return NaN
		return Float.NaN;
	}
	
	/**
	 * Normally uses the heading from getPathHeading(). But if that returns NaN
	 * then uses recent valid heading from last AVL report, though that might be
	 * NaN as well. This can be better then always using heading from AVL report
	 * since that often won't line up with the path and can make vehicles be
	 * oriented in noticeably peculiar ways when drawn on an map.
	 * 
	 * @return The best heading for a vehicle
	 */
	public float getHeading() {
		// Try using path heading so that direction of vehicle will really 
		// follow path. This make the maps look good.
		float heading = getPathHeading();
		if (!Float.isNaN(heading))
			return heading;
	
		// If vehicle not matched to path or if matched to layover then the
		// heading from getPathHeading() is NaN. For this situation use the
		// most recent valid GPS heading.
		heading = recentValidHeading();
		if (!Float.isNaN(heading))
			return heading;
		
		// Most recent heading wasn't valid either so as last shot try using
		// path segment of next segment past layover.
		heading = getNextPathHeadingIfAtLayover();
		return heading;
	}

	@Override
	public String toString() {
		return "VehicleState [" 
				+ "vehicleId=" + vehicleId 
				+ ", blockId=" + (block==null? null : block.getId())
				+ ", assignmentId=" + assignmentId
				+ ", assignmentMethod=" + assignmentMethod
				+ ", assignmentTime=" + assignmentTime 
				+ ", predictable=" + predictable 
				+ ", realTimeSchedAdh=" + realTimeSchedAdh
				+ ", pathHeading=" + StringUtils.twoDigitFormat(getHeading())
				+ ", getMatch()=" + getMatch()
				+ ", getAvlReport()=" + getAvlReport()
				+ (arrivalToStoreToDb != null ? "\n  arrivalToStoreToDb=" + arrivalToStoreToDb : "")
				//+ ",\n  block=" + block // Block info too verbose so commented out
				//+ ",\n  temporalMatchHistory=" + temporalMatchHistory 
				//+ ",\n  avlReportHistory=" + avlReportHistory 
				+ "]";
	}

	public String toStringVerbose() {
		return "VehicleState [" 
				+ "vehicleId=" + vehicleId 
				+ ", blockId=" + (block==null? null : block.getId())
				+ ", assignmentId=" + assignmentId
				+ ", assignmentMethod=" + assignmentMethod
				+ ", assignmentTime=" + assignmentTime 
				+ ", predictable=" + predictable 
				+ ", realTimeSchedAdh=" + realTimeSchedAdh
				+ ", pathHeading=" + StringUtils.twoDigitFormat(getHeading())
				+ ", getMatch()=" + getMatch()
				+ ", getAvlReport()=" + getAvlReport()
				//+ ", \nblock=" + block // Block info too verbose so commented out
				+ ",\n  temporalMatchHistory=" + temporalMatchHistory 
				+ ",\n  avlReportHistory=" + avlReportHistory 
				+ (arrivalToStoreToDb != null ? "\n  arrivalToStoreToDb=" + arrivalToStoreToDb : "")
				+ "]";
	}

	/**
	 * Stores the last arrival time so that can make sure that departure
	 * times are after the arrival times.
	 * @param arrivalTime
	 */
	public void setLastArrivalTime(long arrivalTime) {
		lastArrivalTime = arrivalTime;
	}

	/**
	 * Returns the last stored arrival time so can make sure that departure
	 * times are after the arrival times.
	 * 
	 * @return
	 */
	public long getLastArrivalTime() {
		return lastArrivalTime;
	}
}
