<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
         pageEncoding="ISO-8859-1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <%@include file="/template/includes.jsp" %>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Run Time Analysis</title>

    <!-- Load in Select2 files so can create fancy route selector -->
    <link href="//cdnjs.cloudflare.com/ajax/libs/select2/4.0.0/css/select2.min.css" rel="stylesheet"/>
    <script src="//cdnjs.cloudflare.com/ajax/libs/select2/4.0.0/js/select2.min.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;700&display=swap" rel="stylesheet">

    <link rel="stylesheet" type="text/css" href="../jquery.datepick.package-5.1.0/css/jquery.datepick.css">

    <script type="text/javascript" src="../jquery.datepick.package-5.1.0/js/jquery.plugin.js"></script>
    <script type="text/javascript" src="../jquery.datepick.package-5.1.0/js/jquery.datepick.js"></script>

    <link href="params/reportParams.css" rel="stylesheet"/>
    <style>

        .wrapper {
            background: #f1f1f1f1;
            font-family: 'Montserrat', sans-serif !important;
            height: 100vh;
            width: 100vw;
            position: fixed;
            display: flex;
            flex-flow: row;
        }

        .wrapper.split {
            flex-flow: row;
        }

        #title {
            margin-top: 40px;
            margin-bottom: 2px;
            font-weight: normal;
            text-align: center;
            background: #019932;
            color: white;
            padding: 8px;
            font-size: 24px;
            width: -webkit-fill-available;
            display: inline-block !important;
        }

        #routesDiv {
            font-family: 'Montserrat', sans-serif !important;
        }

        input {
            -webkit-appearance: none;
            width: -webkit-fill-available;
            border: 1px solid #c1c1c1c1;
            background-color: #fff;
            line-height: 1.5;
            box-shadow: 0px 1px 4px rgba(0, 0, 0, 0.33);
            color: #444;
            padding: 0px 6px;
            font-family: 'Montserrat', sans-serif;
            font-size: 16px;
        }

        input::placeholder {
            color: #44444469;
        }

        select:not(.datepick-month-year):not(.datepick-month-year) lect {
            width: -webkit-fill-available;
            border: 1px solid #c1c1c1c1;
            background-color: #fff;
            line-height: 1.5;
            box-shadow: 0px 1px 4px rgba(0, 0, 0, 0.33);
            color: #444;
            padding: 0px 6px;
            font-family: 'Montserrat', sans-serif;
            font-size: 16px;
        }

        label {
            text-align: left;
            width: auto;
        }

        hr {
            height: 2px;
            background-color: darkgray;
            margin-right: 5px;
        }

        .paramsWrapper {
            width: 100%;
            height: 100vh;
            transition: width .75s ease-in-out, max-width .75s ease-in-out;
            font-size: 16px;
            background-color: #fff;
            border: #969696 solid 1px;
            box-shadow: 3px 3px 4px rgba(0, 0, 0, 0.3);
            /* align-self: center; */
            position: relative;
            z-index: 8;
        }

        .split .paramsWrapper {
            width: 22%;
        }

        #paramsSidebar {
            height: 100vh;
            max-width: 420px;
            width: 100%;
            margin: auto;
            display: flex;
            align-items: center;
            flex-flow: column;
            background-color: #fff;
            z-index: 2;
        }

        .split #paramsSidebar {
        }

        #paramsSidebar > * {
            display: flex;
        }

        #paramsFields {
            flex-flow: column;
            width: 90%;
            max-width: 30vw;
        }

        .param {
            display: flex;
            flex-flow: row;
            justify-content: space-between;
            margin-top: 6%;
        }

        .param-modal {
            margin: 10px 0px;
        }

        .param, .param-modal > * {
            font-size: 14px;
        }

        .param > label, .param-modal > label {
            width: 130px;
        }


        .param > span {
            font-weight: 500;
            padding-bottom: 12px;
        }

        .param > input, .param > select {
            height: 30px;
        }

        .param-modal > input, .param-modal > select {
            height: 30px;
            width: 200px;
        }

        .pair {
            display: flex;
            flex-flow: row;
            justify-content: space-between;
            margin-bottom: 6px;
        }

        .vertical {
            flex-flow: column;
            margin-top: 8%;
            /* background-color: #f1f1f1f1; */
            padding: 10px 0px;
        }


        /*#paramsSidebar {*/
        /*width: 25%;*/
        /*height: 100vh;*/
        /*margin-left: 10px;*/
        /*float:left;*/
        /*border-right: 1px solid black;*/
        /*}*/

        #mainPage {
            visibility: hidden;
            opacity: 0;
            display: none;
            margin-left: 2vw;
            margin-top: 20vh;
            height: 100vh;
            width: 90%;
            max-width: 1250px;
            padding: 10px 30px;
            background-color: #fff;
            border-radius: 4px;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.3);
            transition: visibility .25s .75s ease-in-out, opacity .25s .75s ease-in-out;
        }

        .split #mainPage {
            display: inline-block;
            position: relative;
            visibility: visible;
            opacity: 1;
            margin-top: 2vh;
        }

        .inactive {
            filter: blur(2px) grayscale(100%);
        }

        #comparisonModal {
            width: 40%;
            height: 40%;
            z-index: 999;
            border: 1px solid black;
            background-color: white;
            transition: all .5s ease;
            position: absolute;
            left: 44%;
        }

        #serviceDayType {
            width: 100%;
            height: 30px;
            margin-top: 0px;
            box-shadow: 0px 1px 4px #69696969;
            font-family: 'Montserrat', sans-serif;

        }

        #beginTime, #endTime {
            width: 50%;
        }

        .submit {
            margin: 40px 24px;
            background-color: #029932;
            cursor: pointer;
            width: 210px;
            padding: 5px 70px;
            color: #fff;
            font-family: 'Montserrat', sans-serif;
            box-shadow: 0 4px rgba(127, 127, 127, 0.8);
        }

        .submit:hover {
            background-color: #02772c;
        }

        .submit:active {
            box-shadow: 0 1px rgba(127, 127, 127, 0.33);
            transform: translateY(3px);
            outline: none;
        }

    </style>

</head>
<body>
<%@include file="/template/header.jsp" %>
<div class="wrapper">
    <div class="paramsWrapper">
        <div id="paramsSidebar">
            <div id="title">
                Run Time Analysis
            </div>

            <div id="paramsFields">
                <%-- For passing agency param to the report --%>
                <input type="hidden" name="a" value="<%= request.getParameter("a")%>">

                <jsp:include page="params/routeAllOrSingle.jsp"/>

                <div class="param individual-route-only">
                    <label for="direction">Direction:</label>
                    <select id="direction" name="direction" disabled="true"></select>
                </div>

                <div class="param individual-route-only">
                    <label for="tripPattern">Trip Pattern:</label>
                    <select id="tripPattern" name="tripPattern" disabled="true"></select>
                </div>

                <script src="../javascript/jquery-timepicker/jquery.timepicker.min.js"></script>
                <link rel="stylesheet" type="text/css"
                      href="../javascript/jquery-timepicker/jquery.timepicker.css"></link>

                <script>
                    $(function () {
                        var calendarIconTooltip = "Popup calendar to select date";

                        $("#datepicker").datepick({
                            dateFormat: "yy-mm-dd",
                            showOtherMonths: true,
                            selectOtherMonths: true,
                            // Show button for calendar
                            buttonImage: "img/calendar.gif",
                            buttonImageOnly: true,
                            showOn: "both",
                            // Don't allow going past current date
                            maxDate: 0,
                            // onClose is for restricting end date to be after start date,
                            // though it is potentially confusing to user
                            rangeSelect: true,
                            showTrigger: '<button type="button" class="trigger">' +
                                '<img src="../jquery.datepick.package-5.1.0/img/calendar.gif" alt="Popup"></button>',
                            onClose: function (selectedDate) {
                                // Strangely need to set the title attribute for the icon again
                                // so that don't revert back to a "..." tooltip
                                // FIXME $(".ui-datepicker-trigger").attr("title", calendarIconTooltip);
                            }
                        });

                        // Use a better tooltip than the default "..." for the calendar icon
                        $(".ui-datepicker-trigger").attr("title", calendarIconTooltip);

                        $("#beginTime, #endTime").timepicker({timeFormat: "H:i"})
                            .on('change', function (evt) {
                                if (evt.originalEvent) { // manual change
                                    // validate that this looks like HH:MM
                                    if (!evt.target.value.match(/^(([0,1][0-9])|(2[0-3])):[0-5][0-9]$/))
                                        evt.target.value = evt.target.oldval ? evt.target.oldval : "";
                                }
                                evt.target.oldval = evt.target.value;
                            });

                    });
                </script>

                <div class="param">
                    <label for="datepicker">Date:</label>
                    <input type="text" id="datepicker" name="datepicker"
                           title="The range of dates that you want to examine data for.
                                       <br><br> Begin date must be before the end date."
                           size="18"
                           value="Date range"/>
                </div>

                <div class="param">
                    <label for="beginTime">Begin Time:</label>
                    <input id="beginTime" name="beginTime"
                           title="Optional begin time of day to limit query to. Useful if
                                        want to see result just for rush hour, for example. Leave blank
                                        if want data for entire day.
                                        <br/><br/>Format: hh:mm, as in '07:00' for 7AM."
                           placeholder="(hh:mm)"
                           style="width:100%;"
                           value=""/>
                </div>

                <div class="param">
                    <label for="endTime">End Time:</label>
                    <input id="endTime" name="endTime"
                           title="Optional end time of day to limit query to. Useful if
                                        want to see result just for rush hour, for example. Leave blank
                                        if want data for entire day.
                                        <br/><br/>Format: hh:mm, as in '09:00' for 9AM.
                                        Use '23:59' for midnight."
                           placeholder="(hh:mm)"
                           style="width:100%;"
                           value=""/>
                </div>

                <div class="param">
                    <label for="serviceDayType">Service Day:</label>
                    <select id="serviceDayType" name="serviceDayType">
                        <option value="">All</option>
                        <option value="weekday">Weekday</option>
                        <option value="saturday">Saturday</option>
                        <option value="sunday">Sunday</option>
                        <span class="select2-selection__arrow">
                                    <b role="presentation"></b>
                                </span>
                    </select>
                </div>
            </div>
            <div class="submitDiv">
                <input type="button" id="submit" class="submit" value="Submit">
            </div>
        </div>
    </div>


    <div id="mainPage" class="scrollable-element inner-spacing">
        <div id="paramDetails" class="paramDetails">
            <p style='font-size: 0.8em;'></p>
        </div>
        <br>

        <div id="run-time-tabs">
            <ul>
                <li><a href="#component">Component</a></li>
                <li><a href="#percentage">Run Time</a></li>
                <li><a href="#distribution">Distribution</a></li>
            </ul>

            <div id="component">
                <div id="mainResults">




                    <div class="individual-route">
                        <h3>Summary</h3>
                        <table class="border-table">
                            <tr>
                                <th>Average</th>
                                <th>Fixed</th>
                                <th>Variable</th>
                                <th>Dwell</th>
                            </tr>
                            <tr class="average-time-details">
                            </tr>
                        </table>
                    </div>


                </div>

                <div id="comparisonModal"  class="individual-route" hidden="true">
                    <div id="modalContents" style="margin-right: 30px; margin-left: 30px; margin-top: 10px;">
                        <div id="modalHeader" style="text-align: left; vertical-align: middle; font-size: medium">
                            Trip Run Time Comparison
                            <button id='closeModal' type='button' style='float:right; margin-right: -10px;'>&times;</button>
                        </div>
                        <div id="paramDetailsModal" class="paramDetails" style="margin-top: 20px; margin-bottom: 20px;"></div>

                        <script src="../javascript/jquery-timepicker/jquery.timepicker.min.js"></script>
                        <link rel="stylesheet" type="text/css"
                              href="../javascript/jquery-timepicker/jquery.timepicker.css"></link>

                        <script>
                            $(function () {
                                var calendarIconTooltip = "Popup calendar to select date";

                                $("#modalDatepicker").datepick({
                                    dateFormat: "yy-mm-dd",
                                    showOtherMonths: true,
                                    selectOtherMonths: true,
                                    // Show button for calendar
                                    buttonImage: "img/calendar.gif",
                                    buttonImageOnly: true,
                                    showOn: "both",
                                    // Don't allow going past current date
                                    maxDate: 0,
                                    // onClose is for restricting end date to be after start date,
                                    // though it is potentially confusing to user
                                    rangeSelect: true,
                                    showTrigger: '<button type="button" class="trigger">' +
                                        '<img src="../jquery.datepick.package-5.1.0/img/calendar.gif" alt="Popup"></button>',
                                    onClose: function (selectedDate) {
                                        // Strangely need to set the title attribute for the icon again
                                        // so that don't revert back to a "..." tooltip
                                        // FIXME $(".ui-datepicker-trigger").attr("title", calendarIconTooltip);
                                    }
                                });

                                // Use a better tooltip than the default "..." for the calendar icon
                                $(".ui-datepicker-trigger").attr("title", calendarIconTooltip);
                            })
                        </script>

                        <div style='font-size: medium; margin-bottom: 2px;'>Select Comparison Range:</div>

                        <div class="param-modal">
                            <label for="modalDatepicker">Date:</label>
                            <input type="text" id="modalDatepicker" name="modalDatepicker"
                                   title="The range of dates that you want to examine data for.
                                               <br><br> Begin date must be before the end date."
                                   size="14"
                                   value="Date range"/>
                        </div>

                        <div class="param-modal">
                            <label for="serviceDayType">Service Day:</label>
                            <select id="modalServiceDayType" name="modalServiceDayType">
                                <option value="">All</option>
                                <option value="weekday">Weekday</option>
                                <option value="saturday">Saturday</option>
                                <option value="sunday">Sunday</option>
                            </select>
                        </div>
                        <div style="width:100%; display: flex; justify-content: center;">
                            <input type="button" id="modalSubmit" class="submit" value="Submit">
                        </div>
                    </div>
                </div>

                <div id="comparisonResults" class="individual-route" hidden="true"></div>

                <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>

                <div class="individual-route trip-block " >
                    <div class="param" id="trips-container"></div>

                </div>
                <div class="visualization-container">
                    <%--  <h3 id="visualization-container-header"> Route Breakdown</h3>--%>
                    <div id="runTimeVisualization" hidden="true">

                    </div>
                </div>
                <br>
                <br>
            </div>

            <div id="percentage">
                <div class="percentile-select-container" id="percentile-select-container"></div>
                <h3>Summary</h3>
                <div id="percentile-summary-content"></div>
                <h3>Trip Breakdown</h3>
                <table class="border-table percentile-summary-details">

                </table>
            </div>

            <div id="distribution">
                Distribution Tab
            </div>

        </div>

    </div>
</div>
</body>
</html>

<script>

    var stops = {};

    $("#route").attr("style", "width: 200px");
    $(".individual-route-only").hide();
    $( "#run-time-tabs" ).tabs();

    $("#route").change(function () {
        if ($("#route").val().trim() != "") {
            $(".individual-route-only").show();

            populateDirection();
        } else {
            $(".individual-route-only").hide();
            $("#direction").empty();
            $("#tripPattern").empty();
            $("#direction").attr("disabled", true);
            $("#tripPattern").attr("disabled", true);
        }
    })

    $("#direction").change(function () {
        populateTripPattern();
    })

    Chart.plugins.register({
        afterDatasetsDraw: function(chart) {
            var ctx = chart.ctx;

            ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
            ctx.fillStyle = '#000000';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'bottom';

            Chart.helpers.each(chart.data.datasets.forEach(function(dataset, i) {
                var meta = chart.controller.getDatasetMeta(i);
                Chart.helpers.each(meta.data.forEach(function(bar, index) {
                    ctx.save();
                    var data = dataset.data[index];
                    if(chart.options && chart.options.showPercentage) {
                        data = Math.floor(data);
                        if(data !== 0) {
                            ctx.fillText(data + "%", bar._model.x - ((bar._model.x - bar._model.base) / 2), bar._model.y + 5);
                        }
                    } else {
                        ctx.fillText(data, bar._model.x - ((bar._model.x - bar._model.base) / 2), bar._model.y + 5);
                    }
                    ctx.restore(); //<- restore canvas state
                }))
            }));
        }
    });

    function range(start, end, custom) {
        return Array(end - start + 1).fill().map(function(_, idx) {
            if(custom){
                return custom;
            }
            return { "name": (5 *(idx+1) + "%" ), "value": (5 *(idx+1))}
        })
    }

    function findMinMax(arr) {

        var min = arr[0], max = arr[0];

        for (var i = 1, len=arr.length; i < len; i++) {
            var v = arr[i].y;
            min = (v < min) ? v : min;
            max = (v > max) ? v : max;
        }

        return [min, max];
    }

    function percentileCalculation(data, param){

        var sortedData = data.sort(function(a, b) {
            return a - b;
        });
        var sortedDataLength = sortedData.length;
        var percentageValue = param;
        var valueOfPercentile = sortedDataLength * percentageValue / 100;
        var pickedValue = 0;
        var flooredValue = Math.floor(valueOfPercentile) === valueOfPercentile;
        var sortedIndexValues = [];
        var nonSortedIndexValues = [];
        var valuesPert = [];

        if(flooredValue){
            var u = data[valueOfPercentile- 1];
            var a = data[valueOfPercentile];
            sortedIndexValues.push(u);
            sortedIndexValues.push(a);


            pickedValue = (data[valueOfPercentile- 1] + data[valueOfPercentile]) / 2;
        } else {
            var ceilValue = Math.ceil(valueOfPercentile);
            sortedIndexValues.push(ceilValue-1);
            pickedValue = sortedData[ceilValue - 1];
        }
        data.forEach(function(eachValue,index){
            if(sortedIndexValues.length == 2 && (sortedData[sortedIndexValues[0]] === eachValue || sortedData[sortedIndexValues[1]] === eachValue)){
                nonSortedIndexValues.push(index);
            }else if(sortedIndexValues.length == 1 && (sortedData[sortedIndexValues[0]] === eachValue)){
                nonSortedIndexValues.push(index);
            }

        });


        return nonSortedIndexValues;
    }

    function convertToMins(scheduledData){
        var data = [];
        var sumOfData = 0;
        var average;
        for (var i = 0 in scheduledData) {

            data.push(parseFloat(scheduledData[i]));
            sumOfData += parseFloat(scheduledData[i] );

        }

        average = Math.round(sumOfData/scheduledData.length);
        var minMax = findMinMax(scheduledData);

        return {
            minsData : data,
            average: average,
            min: minMax[0],
            max: minMax[1]

        }
    }


    function generatePercentileTable(stopsData, formattedScheduled, formattedRunTimeTrips){

        var tableTD = "<tr><th>Trip</th><th>Schedule</th><th>Percentile</th></tr>";
        var sumOfData = 0;
        stopsData.forEach(function (eachTrip, i) {

            var eachData = {
                trip: eachTrip,
                schedule: formattedScheduled[i]+"min",
                percentile: formattedRunTimeTrips[i] +"min"
            };
            // percentileData.push(eachData);
            sumOfData += parseFloat(formattedRunTimeTrips[i]);
            tableTD += "<tr>";
            tableTD += "<td>"+eachData.trip+"</td>";
            tableTD += "<td>"+eachData.schedule+"</td>";
            tableTD += "<td>"+eachData.percentile+"</td>";
            tableTD += "</tr>";
        });

        var average = Math.round(sumOfData/stopsData.length);
        var percentileSummaryData = average +"min";

        $("#percentile-summary-content").html(percentileSummaryData);

        return tableTD;
    }

    function generateRunTimes(tripRunTimes, percentile){
        var filteredRunTimeTrips = [];
        tripRunTimes.forEach(function (eachTrip, i) {
            if(!eachTrip.formattedRunTimes){
                eachTrip.formattedRunTimes = msToMin(eachTrip.runTimes);
            }
            var nonSortedIndex =   percentileCalculation(eachTrip.formattedRunTimes, percentile);
            filteredRunTimeTrips.push(eachTrip.formattedRunTimes[nonSortedIndex[0]] || 0);
        });

        return filteredRunTimeTrips;
    }
    function percentageTabDetails(response){

        $("#percentile-select-container").html("");
        $("#percentile-summary-content").html("");
        $(".percentile-summary-details").html("");

        var percentileSelectOptions = range(1, 20);

        // var dummyTripRunTimes = range(1, response.data.trips.length,  {"runTimes": [2400499, 2430499, 2475499]});

        var tripRunTimes =  response.data.tripRunTimes;

        var formattedScheduled = convertToMins(response.data.scheduled);

        var formattedRunTimeTrips = generateRunTimes(tripRunTimes, 50);
        var stopsData = getStopsData(response.data.trips);

        var percentileData = [];


        var tableTD = generatePercentileTable(stopsData, formattedScheduled.minsData, formattedRunTimeTrips);

        var percentileSelect = $('<select id="percentile-select-box" name="percentileSelect"></select>');
        percentileSelectOptions[percentileSelectOptions.length-1] = {
            value: "99",
            name: "99%"
        };
        percentileSelectOptions.forEach(function (eachTrip, i) {
            var option = $('<option></option>');
            option.attr('value', eachTrip.value);
            option.text(eachTrip.name);
            percentileSelect.append(option);
        });

        percentileSelect.append( '<span class="select2-selection__arrow"><b role="presentation"></b></span>');
        $("#percentile-select-container").append('<label for="percentileSelect">Percentile</label>');
        $("#percentile-select-container").append(percentileSelect);

        $("#percentile-select-box").change(function () {
            var tableTD ;

            if ($("#percentile-select-box").val().trim() != "") {

                var valuePercentage = $("#percentile-select-box").val().trim();
                // if(valuePercentage == 100){
                //     valuePercentage = 99;
                // }
                var formattedRunTimeTrips = generateRunTimes(dummyTripRunTimes, valuePercentage );
                // var formattedRunTimeTrips = generateRunTimes(dummyTripRunTimes, $("#percentile-select-box").val().trim());
                // var nonSortedIndexValues = percentileCalculation(formattedRunTimeTrips.minsData, $("#percentile-select-box").val().trim());

                //  var filteredStopsData = [];
                // var filteredScheduled = [];
                // var filteredRunTimeTrips = [];


                /* nonSortedIndexValues.forEach(function(eachValue){
                    filteredStopsData.push(stopsData[eachValue]);
                    filteredScheduled.push(formattedScheduled.minsData[eachValue]);
                    filteredRunTimeTrips.push(formattedRunTimeTrips.minsData[eachValue]);
                }); */

                tableTD = generatePercentileTable(stopsData, formattedScheduled.minsData, formattedRunTimeTrips);
                console.log($("#percentile-select-box").val().trim());
            } else {
                tableTD = generatePercentileTable(stopsData, formattedScheduled.minsData, 0);
                console.log($("#percentile-select-box").val().trim());
            }

            $(".percentile-summary-details").html(tableTD);

        });


        $(".percentile-summary-details").html(tableTD);

    }

    function populateDirection() {

        $("#submit").attr("disabled", true);

        $("#tripPattern").empty();
        $("#direction").removeAttr('disabled');
        $("#direction").empty();


        $.ajax({
            url: apiUrlPrefix + "/command/headsigns",
            // Pass in query string parameters to page being requested
            data: {r: $("#route").val()},
            // Needed so that parameters passed properly to page being requested
            traditional: true,
            dataType: "json",
            success: function (response) {
                response.headsigns.forEach(function (headsign) {
                    $("#direction").append("<option value='" + headsign.headsign + "'>" + headsign.label + "</option>");
                })
                populateTripPattern();
            },
            error: function (response) {
                alert("Error retrieving directions for route " + response.r);
                $("#submit").attr("disabled", false);
            }
        })
    }

    function populateTripPattern() {
        $("#tripPattern").empty();

        var request = {};

        request.a = 1;
        request.r = $("#route").val();
        request.headsign = $("#direction").val();
        request.includeStopPaths = 'false';

        $.ajax({
            // The page being requested
            url: apiUrlPrefix + "/command/tripPatterns",
            // Pass in query string parameters to page being requested
            data: request,
            // Needed so that parameters passed properly to page being requested
            traditional: true,
            dataType: "json",
            async: true,
            // When successful process JSON data
            success: function (resp) {
                if (resp.tripPatterns.length == 0) {
                    alert("No trip pattern data for selected route and headsign.");
                    $("#submit").attr("disabled", true);
                } else {
                    $("#tripPattern").removeAttr('disabled');
                    $("#submit").removeAttr('disabled');

                    $("#tripPattern").append("<option value=''>All</option>")
                    resp.tripPatterns.forEach(function (tripPattern) {
                        $("#tripPattern").append("<option value='" + tripPattern.id + "'>" + tripPattern.firstStopName + ' to ' + tripPattern.lastStopName + "</option>");
                    })

                }

            },
            // When there is an AJAX problem alert the user
            error: function (request, status, error) {
                alert(error + '. ' + request.responseText);
                $("#submit").attr("disabled", false);
            }
        });
    }


    function getParams(modal) {
        var datepicker, serviceTypeSelector;
        if (modal) {
            datepicker = "modalDatepicker";
            serviceTypeSelector = "modalServiceDayType";
        } else {
            datepicker = "datepicker";
            serviceTypeSelector = "serviceDayType";
        }

        if ($("#" + datepicker).val() == "Date range") {
            var today = new Date();
            var beginDate = endDate = today.getFullYear() + "-"
                + (today.getMonth() <= 10 ? "0" + (today.getMonth() + 1) : (today.getMonth() + 1))
                + "-" + (today.getDate() < 10 ? "0" + today.getDate() : today.getDate());
        } else {
            var dateRangeStrings = $("#" + datepicker).val().replace(/\s/g, "").split("-");
            var beginYear = "20" + dateRangeStrings[0];
            var endYear = "20" + dateRangeStrings[3];
            var beginDate = [beginYear, dateRangeStrings[1], dateRangeStrings[2]].join("-");
            var endDate = [endYear, dateRangeStrings[4], dateRangeStrings[5]].join("-");
        }

        var beginTime = $("#beginTime").val() == "" ? "00:00:00" : $("#beginTime").val() + ":00";
        var endTime = $("#endTime").val() == "" ? "23:59:59" : $("#endTime").val() + ":00";

        var routeName = $("#route").val().trim() == "" ? "" : $("#route").val();
        var directionName = $("#direction").val() == null ? "" : $("#direction").val();
        var tripPatternName = $("#tripPattern").val() == null ? "" : $("#tripPattern").val();

        params = {};

        params.beginDate = beginDate;
        params.endDate = endDate;
        params.beginTime = beginTime;
        params.endTime = endTime;
        params.r = routeName
        params.headsign = directionName;
        params.serviceType = $("#" + serviceTypeSelector).val();
        params.tripPattern = tripPatternName;

        return params;
    }

    function getStopsData(trips){
        var stopsData = [];
        trips.forEach(function (eachTrip, i) {
            var values = eachTrip.split("-");
            var optionValue = values[1].trim();
            if(stopsData.indexOf(optionValue) < 0){
                stopsData.push(optionValue);
            }

        });
        return stopsData;
    }

    function msToMin(data) {
        var highest = 0;

        for (var i = 0 in data) {
            data[i] = (data[i] / 60000).toFixed(1);
            if (data[i] > highest) {
                highest = data[i];
            }
        }

        highestPoints.push(highest);
        return data;
    }

    function arraysToXAndY(data) {
        xsAndYs = [];
        for (var i = 0 in data[0]) {
            xsAndYs[i] = {x: data[0][i], y: data[1][i]};
        }

        return xsAndYs;
    }

    function calculateMaxMins(points) {
        maxMins = Math.round(points[0]) + Math.round(points[1]) + Math.round(points[2]);
        if (Math.round(points[3]) > maxMins) {
            maxMins = Math.round(points[3]);
        }
        if (Math.round(points[4]) > maxMins) {
            maxMins = Math.round(points[4]);
        }

        return Math.ceil(maxMins / 5) * 5;
    }



    var highestPoints = [];
    var visualarGraphChart;


    function showStopView(){

        highestPoints = [];
        request = getParams(false)
        request.tripId = $("#trips-select-box").val();
        /*Orginal URL*/
        var stopDataURL = apiUrlPrefix +  "/report/runTime/avgStopPathRunTimes";

        /*DONT COMMIT URL*/
        // var stopDataURL = "http://gtfsrt.dev.dart.obaweb.org/api/v1/key/5c348c1d/agency/1/"+"report/runTime/avgStopPathRunTimes";

        $.ajax({
            url: stopDataURL,
            // Pass in query string parameters to page being requested
            data: request,
            // Needed so that parameters passed properly to page being requested
            traditional: true,
            dataType: "json",
            success: function (response) {
                if(response.data.stopPaths && response.data.stopPaths.length ){

                    var defaultHeight = (response.data.stopPaths.length ) *80;
                    var defaultWidth = window.innerWidth;

                    if(defaultHeight < (window.innerHeight/2 - 100)) {
                        defaultHeight =  window.innerHeight;
                    }
                    $("#runTimeVisualization").html(' <canvas id="visualizationCanvas" class="custom-canvas"  height="'+defaultHeight+'" width="'+defaultWidth+'"></canvas>');

                    generateIndividualStopChart(response);
                } else {
                    alert("Error retrieving stop-by-stop summary.");
                }
            },
            error: function (e) {
                alert("Error retrieving stop-by-stop summary.");

            }
        });

    }

    function visualizeData() {
        $("#submit").attr("disabled", true);

        highestPoints = [];
        request = getParams(false)
        var visualDataURL = apiUrlPrefix +  "/report/runTime/avgTripRunTimes";
        var isAllRoutes = false;
        if(visualarGraphChart && visualarGraphChart.destroy){
            visualarGraphChart.destroy();
        }
        if(!request.r){
            delete request.r;
            delete  request.tripPattern;
            delete request.serviceType
            delete  request.headsign;
            isAllRoutes = true;
            visualDataURL =  apiUrlPrefix + "/report/runTime/routeRunTimes";

            /*DONT COMMIT URL*/
            // visualDataURL = "http://gtfsrt.dev.dart.obaweb.org/api/v1/key/5c348c1d/agency/1" + "/report/runTime/routeRunTimes";
        }



        $.ajax({
            url: visualDataURL,
            // Pass in query string parameters to page being requested
            data: request,
            // Needed so that parameters passed properly to page being requested
            traditional: true,
            dataType: "json",
            success: function (response) {

                $("#submit").attr("disabled", false);
                if(response.data && ((response.data.trips && response.data.trips.length > 0) ||
                    (response.data.routes && response.data.routes.length > 0))){


                    if(response.data.trips && response.data.trips.length ){

                        var tripSelectBox = $('<select id="trips-select-box" name="tripBoxType"><option value="">All</option></select>');
                        var stopsData = getStopsData(response.data.trips);
                        stopsData.forEach(function (eachTrip, i) {

                            var option = $('<option></option>');
                            option.attr('value', eachTrip);
                            option.text(eachTrip);
                            tripSelectBox.append(option);

                        });

                        tripSelectBox.append( '<span class="select2-selection__arrow"><b role="presentation"></b></span>');

                        $("#trips-container").html("");
                        $("#trips-container").append('<h3 for="tripBoxType" id="visualization-container-header">Run Times for Trips :</h3>');
                        $("#trips-container").append(tripSelectBox);

                        $("#trips-select-box").change(function () {

                            if ($("#trips-select-box").val().trim() != "") {
                                showStopView();

                                $("#visualization-container-header").html("Run Times for Trip Stops");
                            } else {
                                visualizeData();

                                $("#visualization-container-header").html("Run Times for Trips:");
                            }

                        });
                        $("#runTimeVisualization").html(' <canvas id="visualizationCanvas" maintainAspectRatio="false" responsive="true"></canvas>');
                    } else{
                        var defaultHeight = (response.data.routes.length ) *38;
                        var defaultWidth = window.innerWidth;

                        if(defaultHeight < (window.innerHeight/2 - 100)) {
                            defaultHeight =  window.innerHeight;
                        }
                        $("#runTimeVisualization").html(' <canvas id="visualizationCanvas" class="custom-canvas"  height="'+defaultHeight+'" width="'+defaultWidth+'"></canvas>');

                    }


                    if(isAllRoutes){
                        generateAllRouteChart(response);
                        /*generateAllRouteChart({
                            "data": {
                                "routes": [
                                    "011",
                                    "012",
                                    "013",
                                    "014",
                                    "015",
                                    "016",
                                    "017",
                                    "018",
                                    "019",
                                    "020"
                                ],
                                "early": [10, 5, 3, 30, 120, 0, 0, 15, 0, 10, 30],
                                "onTime": [0, 0, 0, 1, 1, 10, 1, 10, 0, 0, 0],
                                "late": [30, 0, 15, 20, 30, 45, 3, 1, 10, 0, 50],
                            }
                        }) ; */
                    } else{
                        generateIndividualRouteChart(response);
                        percentageTabDetails(response);
                    }



                    $("#comparisonResults").hide();
                    $("#runTimeVisualization").show();

                } else{
                    alert("No trip breakdown available for selected run time data.");

                }

            },
            error: function (e) {
                alert("Error retrieving trip-by-trip summary.");

                $("#submit").attr("disabled", false);
            }
        })
    }
    function getDefaultChartOptions(options){

        var canvas = $("#visualizationCanvas");
        var barGraph = new Chart(canvas, {
            type: 'horizontalBar',
            data: {},
            options: {
                showPercentage: options && options.showPercentage,
                scales: {
                    xAxes: [
                        {
                            stacked: true,
                            scaleLabel: {
                                display: true,
                                labelString: "Minutes"
                            },
                            ticks: options && options.xAxis && options.xAxis.ticks ||{}
                        }],
                    yAxes: [
                        {
                            id: "bars",
                            stacked: options && options.yAxis && options.yAxis.isStacked || false,
                            ticks: options && options.yAxis && options.yAxis.ticks || {
                                stepSize: 1
                            }
                        },
                        // {
                        //     id: "icons",
                        //     stacked: false,
                        //     display: true,
                        //     ticks: {
                        //         beginAtZero: true,
                        //         min: 0,
                        //         max: 8,
                        //         stepSize: 1
                        //     }
                        // }
                    ]
                },
                legend: {
                    position: 'top',
                    onClick: function (l) {
                        l.stopPropagation();
                    }

                },
                tooltips: {
                    callbacks: {
                        label: function (tooltipItem) {
                            var data = this._data.datasets[tooltipItem.datasetIndex];
                            var value = function () {
                                if(options && options.showPercentage) {
                                    return  Math.floor(data.data[tooltipItem.index]) +"%";
                                } else  if (data.label == "Scheduled" || data.label == "Next trip start") {
                                    return data.data[tooltipItem.index].x;
                                } else {
                                    return data.data[tooltipItem.index];
                                }
                            }
                            return data.label + ": " + value();
                        }
                    }
                },
                animation: false
            },
        });
        visualarGraphChart = barGraph;
        return barGraph;
    }

    function generateIndividualStopChart(response){
        var barGraph = getDefaultChartOptions();
        barGraph.data = {
            datasets: [
                {
                    data: msToMin(response.data.fixed),
                    backgroundColor: '#36509b',
                    label: "Fixed",
                    yAxisId: "bars"
                },
                {
                    data: msToMin(response.data.variable),
                    backgroundColor: '#df7f17',
                    label: "Variable",
                    yAxisId: "bars"
                },
                {
                    data: msToMin(response.data.dwell),
                    backgroundColor: '#8c8c8c',
                    label: "Dwell",
                    yAxisId: "bars"
                },
                {
                    type: "scatter",
                    data: arraysToXAndY([msToMin(response.data.scheduled), response.data.stopPaths]),
                    backgroundColor: '#70a260',
                    label: "Scheduled",
                    showLine: false,
                    fill: false,
                    // yAxisId: "icons"
                }],
            labels: response.data.stopPaths
        }

        barGraph.options.scales.xAxes[0].ticks.max = calculateMaxMins(highestPoints);

        barGraph.update();


    }

    function generateIndividualRouteChart(response){
        var barGraph = getDefaultChartOptions();
        barGraph.data = {
            datasets: [
                {
                    data: msToMin(response.data.fixed),
                    backgroundColor: '#36509b',
                    label: "Fixed",
                    yAxisId: "bars"
                },
                {
                    data: msToMin(response.data.variable),
                    backgroundColor: '#df7f17',
                    label: "Variable",
                    yAxisId: "bars"
                },
                {
                    data: msToMin(response.data.dwell),
                    backgroundColor: '#8c8c8c',
                    label: "Dwell",
                    yAxisId: "bars"
                },
                {
                    type: "scatter",
                    data: arraysToXAndY([msToMin(response.data.scheduled), response.data.trips]),
                    backgroundColor: '#70a260',
                    label: "Scheduled",
                    showLine: false,
                    fill: false,
                    // yAxisId: "icons"
                },
                {
                    type: "scatter",
                    data: arraysToXAndY([msToMin(response.data.nextTripStart), response.data.trips]),
                    backgroundColor: '#dfbf2c',
                    label: "Next trip start",
                    showLine: false,
                    fill: false,
                    // yAxisId: "icons"
                }],
            labels: response.data.trips
        }

        barGraph.options.scales.xAxes[0].ticks.max = calculateMaxMins(highestPoints);

        barGraph.update();


    }

    function getHighestData(data){
        var highest = 0;

        for (var i = 0 in data) {
            data[i] = data[i];
            if (data[i] > highest) {
                highest = data[i];
            }
        }

        highestPoints.push(highest);
        return data;
    }


    function percentageFormatter(data){

        var convertedPercentile = {
            early:[],
            onTime:[],
            late:[]
        };

        for(var i=0; i < data.early.length; i++){

            var totalSum  = data.early[i]+data.onTime[i]+data.late[i];

            var individualShare = ((100)/totalSum);
            if(!isFinite(individualShare)){
                individualShare = 0
            }
            convertedPercentile.early.push(individualShare*data.early[i]);
            convertedPercentile.onTime.push(individualShare*data.onTime[i]);
            convertedPercentile.late.push(individualShare*data.late[i]);

        }

        return convertedPercentile;
    }


    function generateAllRouteChart(nonPercentileResponse){

        var barGraph = getDefaultChartOptions({
            xAxis:{
                ticks: {
                    max: 100,
                }
            },
            yAxis:{
                isStacked: true
            },
            showPercentage : true

        });
        var response = percentageFormatter(nonPercentileResponse.data);


        barGraph.data = {
            datasets: [
                {
                    data: getHighestData(response.early),
                    backgroundColor: '#4778de',
                    label: "Ahead Of Schedule",
                    yAxisId: "bars"
                },
                {
                    data: getHighestData(response.onTime),
                    backgroundColor: '#4bd56b',
                    label: "On Schedule",
                    yAxisId: "bars"
                },
                {
                    data: getHighestData(response.late),
                    backgroundColor: '#e33b3b',
                    label: "Behind Schedule",
                    yAxisId: "bars"
                },

            ],
            labels: nonPercentileResponse.data.routes
        }

        // barGraph.options.scales.xAxes[0].ticks.max = calculateMaxMins(highestPoints);
        barGraph.update();


    }

    $("#submit").click(function () {
        $("#submit").attr("disabled", "disabled");
        $(".wrapper").addClass("split");
        $("#mainResults").hide();
        $("#runTimeVisualization").hide();
        $("#modalDatepicker").val("Date range")
        $("#comparisonModal").hide();
        $("#comparisonResults").hide();
        $("#comparisonResults").html(
            '<hr>' +

            '<div id="comparisonParams" class="paramDetails" style="float: left;">' +
            '<p style="font-size: 0.8em;"></p>' +
            '</div>' +

            '<div id="comparisonAvgRunTime" style="display: inline-block; margin-left: 20px; width: 90%; vertical-align: middle;">' +
            '<p style="font-size: 0.8em;display: inline-block;"></p>' +
            '<p style="font-size: 0.8em;display: inline-block; width: 60px; height: 1.5em;"></p>' +
            '<p style="font-size: 0.8em;display: inline-block;"></p>' +
            '<p style="font-size: 0.8em;display: inline-block; width: 60px; height: 1.5em;"></p>' +
            '<p style="font-size: 0.8em;display: inline-block;"></p>' +
            '<p style="font-size: 0.8em;display: inline-block; width: 60px; height: 1.5em;"></p>' +
            '<p style="font-size: 0.8em;display: inline-block;"></p>' +
            '<p style="font-size: 0.8em;display: inline-block; width: 60px; height: 1.5em;"></p>' +
            '</div>'
        );

        request = getParams(false);

        var beginDateArray = request.beginDate.split("-");
        var endDateArray = request.endDate.split("-");
        [beginDateArray[0], beginDateArray[1], beginDateArray[2]] = [beginDateArray[1], beginDateArray[2], beginDateArray[0]];
        [endDateArray[0], endDateArray[1], endDateArray[2]] = [endDateArray[1], endDateArray[2], endDateArray[0]];
        var beginDateString = beginDateArray.join("/");
        var endDateString = endDateArray.join("/");

        var timeRange = request.beginTime + " to " + request.endTime;

        if (beginTime == "00:00:00" && endTime == "23:59:59") {
            timeRange = "All times";
        }

        var serviceDayString = request.serviceType;

        if (serviceDayString == "") {
            serviceDayString = "All days";
        }

        if(!request.r){
            $("#paramDetails").html("<p style='font-size: 0.8em;'>" +
                (request.r == "" ? "All routes" : "Route " + request.r) + " to " +
                (request.headsign == "" ? "All directions" : request.headsign) + " | " +
                (request.tripPattern == "" ? "All Trip Patterns" : request.tripPattern) + " | " +
                beginDateString + " to " + endDateString + " | " + timeRange + " | " + serviceDayString
                + "</p>");
            $("#mainResults").show();
            visualizeData();
            $(".individual-route").hide();
            return true;
        } else{
            $(".individual-route").show();
            $("#comparisonModal").hide();
        }

        $.ajax({
            url: apiUrlPrefix + "/report/runTime/avgRunTime",
            // Pass in query string parameters to page being requested
            data: request,
            // Needed so that parameters passed properly to page being requested
            traditional: true,
            dataType: "json",
            success: function (response) {
                if (jQuery.isEmptyObject(response)) {
                    $("#submit").removeAttr("disabled");
                    alert("No run time information available for selected parameters.");
                } else {
                    $("#submit").removeAttr("disabled");

                    $("#paramDetails").html("<p style='font-size: 0.8em;'>" + (request.r == "" ? "All routes" : "Route " + request.r) + " to " + (request.headsign == "" ? "All directions" : request.headsign) + " | " + (request.tripPattern == "" ? "All Trip Patterns" : request.tripPattern) + " | " + beginDateString + " to " + endDateString + " | " + timeRange + " | " + serviceDayString + "<a id='compareLink' style='font-size: 0.8em; margin-bottom: 1em; margin-left: 4em; color: blue; text-decoration: underline; cursor: pointer' onclick='openModal()'>Compare</a></p>");
                    $("#paramDetailsModal").html("<p style='font-size: 0.7em;'>" + (request.r == "" ? "All routes" : "Route " + request.r) + " to " + (request.headsign == "" ? "All directions" : request.headsign) + " | " + (request.tripPattern == "" ? "All Trip Patterns" : request.tripPattern) + " | " + beginDateString + " to " + endDateString + " | " + timeRange + " | " + serviceDayString + "</p>");

                    var avgRunTime = typeof (response.avgRunTime) == 'undefined' ? "N/A" : (response.avgRunTime / 60000).toFixed(1);
                    var avgFixed = typeof (response.fixed) == 'undefined' ? "N/A" : (response.fixed / 60000).toFixed(1);
                    var avgVar = typeof (response.variable) == 'undefined' ? "N/A" : (response.variable / 60000).toFixed(1);
                    var avgDwell = typeof (response.dwell) == 'undefined' ? "N/A" : (response.dwell / 60000).toFixed(1);

                    var tableTD = "<td>"+avgRunTime+"</td>";
                    tableTD += "<td>"+avgFixed+"</td>";
                    tableTD += "<td>"+avgVar+"</td>";
                    tableTD += "<td>"+avgDwell+"</td>";
                    $(".average-time-details").html(tableTD);
                    $("#mainResults").show();
                    visualizeData();

                }

            },
            error: function () {
                $("#submit").removeAttr("disabled");
                alert("Error processing average trip run time.");
            }
        })
    })

    $("#modalSubmit").click(function () {
        $(".submit").attr("disabled", "disabled");
        $("#comparisonResults").hide();
        $("#runTimeVisualization").hide();

        request = getParams(true);

        $.ajax({
            url: apiUrlPrefix + "/report/runTime/avgRunTime",
            // Pass in query string parameters to page being requested
            data: request,
            // Needed so that parameters passed properly to page being requested
            traditional: true,
            dataType: "json",
            success: function (response) {
                if (jQuery.isEmptyObject(response)) {
                    $(".submit").removeAttr("disabled");
                    alert("No run time information available for selected parameters.");
                } else {
                    $(".submit").removeAttr("disabled");
                    $("#comparisonModal").hide();

                    var beginDateArray = request.beginDate.split("-");
                    var endDateArray = request.endDate.split("-");
                    [beginDateArray[0], beginDateArray[1], beginDateArray[2]] = [beginDateArray[1], beginDateArray[2], beginDateArray[0]];
                    [endDateArray[0], endDateArray[1], endDateArray[2]] = [endDateArray[1], endDateArray[2], endDateArray[0]];
                    var beginDateString = beginDateArray.join("/");
                    var endDateString = endDateArray.join("/");

                    var timeRange = request.beginTime + " to " + request.endTime;

                    if (beginTime == "00:00:00" && endTime == "23:59:59") {
                        timeRange = "All times";
                    }

                    var serviceDayString = request.serviceType;

                    if (serviceDayString == "") {
                        serviceDayString = "All days";
                    }

                    $("#comparisonParams").html("<p style='font-size: 0.8em;'>" + (request.r == "" ? "All routes" : "Route " + request.r) + " to " + (request.headsign == "" ? "All directions" : request.headsign) + " | " + (request.tripPattern == "" ? "All Trip Patterns" : request.tripPattern) + " | " + beginDateString + " to " + endDateString + " | " + timeRange + " | " + serviceDayString + "<a id='clearLink' style='font-size: 0.8em; margin-bottom: 1em; margin-left: 4em; color: blue; text-decoration: underline; cursor: pointer' onclick='clearComparison()'>Clear</a></p>");

                    var avgRunTime = typeof (response.avgRunTime) == 'undefined' ? "N/A" : (response.avgRunTime / 60000).toFixed(1);
                    var avgFixed = typeof (response.fixed) == 'undefined' ? "N/A" : (response.fixed / 60000).toFixed(1);
                    var avgVar = typeof (response.variable) == 'undefined' ? "N/A" : (response.variable / 60000).toFixed(1);
                    var avgDwell = typeof (response.dwell) == 'undefined' ? "N/A" : (response.dwell / 60000).toFixed(1);

                    $("#comparisonAvgRunTime").html(
                        "<p style='font-size: 0.8em;display: inline-block; vertical-align: middle;'>Average run time</p>" +
                        "<p style='font-size: 0.8em;display: inline-block; margin-left: 50px; width: 60px; height: 1.5em; background-color: lightgray; vertical-align: middle;'>" + avgRunTime + "</p>" +
                        "<p style='font-size: 0.8em;display: inline-block; margin-left: 50px;'>Fixed</p>" +
                        "<p style='font-size: 0.8em;display: inline-block; margin-left: 50px; width: 60px; height: 1.5em; background-color: lightgray; vertical-align: middle;'>" + avgFixed + "</p>" +
                        "<p style='font-size: 0.8em;display: inline-block; margin-left: 40px; vertical-align: middle;'>Variable</p>" +
                        "<p style='font-size: 0.8em;display: inline-block; margin-left: 40px; width: 60px; height: 1.5em; background-color: lightgray; vertical-align: middle;'>" + avgVar + "</p>" +
                        "<p style='font-size: 0.8em;display: inline-block; margin-left: 40px; vertical-align: middle;'>Dwell</p>" +
                        "<p style='font-size: 0.8em;display: inline-block; margin-left: 40px; width: 60px; height: 1.5em; background-color: lightgray; vertical-align: middle;'>" + avgDwell + "</p>"
                    );

                    $("#comparisonResults").show();
                }
            },
            error: function () {
                $(".submit").removeAttr("disabled");
                alert("Error processing average trip run time.");
            }
        })
    })

    function openModal() {
        $("#comparisonModal").show();
    }

    function clearComparison() {
        $("#comparisonResults").hide();
    }

    $("#closeModal").click(function () {
        $("#comparisonModal").hide();
    })

</script>