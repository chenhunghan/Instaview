angular.module("timeline", []).directive("timeline", ['$timeout', '$window', '$interval', ($timeout, $window, $interval) ->
  restrict: "E"
  template: '<div>' +
              '<div class="timeline-wraper"></div>' +
              '<div class="timeline-controller">
                <input type="text" ng-model="range.start.date" data-autoclose="1" placeholder="Date" bs-datepicker>
                <input type="text" ng-model="range.start.time" data-autoclose="1" placeholder="Time" bs-timepicker>
                <input type="text" ng-model="range.end.date" data-autoclose="1" placeholder="Date" bs-datepicker>
                <input type="text" ng-model="range.end.time" data-autoclose="1" placeholder="Time" bs-timepicker>
                <input type="button" ng-click="play()" value="Play">
                <input type="button" ng-click="pause()" value="Pause">
                <input type="button" ng-click="reset()" value="Reset">
                <input type="button" ng-click="playback()" value="Playback">
                <input type="number" ng-model="playbackvalue">
                <input type="range" ng-model="playmoment" max="{{playbackend}}" min="{{playbackstart}}" step="{{playbackstep}}" style="width:90%; margin-left:70px;">
              </div>' +
            '</div>'
  scope:
    chart: "=chart"
  compile: (tele, attrs) ->
    link = (scope, ele, attr, ctrl) ->
      timelineWraper = $('.timeline-wraper')[0]
      timeline = new links.Timeline(timelineWraper)
      bind_timeline_and_controller = ->
        scope.range = {}
        scope.range.start = {}
        scope.range.end = {}
        before = new $window.Date()
        before = before.setHours(before.getHours()-2)
        scope.range.start.time = before
        scope.range.start.date = before
        scope.range.end.time = new $window.Date()
        scope.range.end.date = new $window.Date()
        scope.$watch 'range', (o, n) ->
          timeline.setVisibleChartRange scope.range.start.time, scope.range.end.time
        , true
        onrangechange = () ->
          scope.$apply( ->
            timeline_range = timeline.getVisibleChartRange()
            scope.range.start.time = timeline_range.start
            scope.range.start.date = timeline_range.start
            scope.range.end.time = timeline_range.end
            scope.range.end.date = timeline_range.end
          )
        links.events.addListener timeline, 'rangechange', onrangechange
      timeline_init = ->
        options =
          width: "90%"
          height: "200px"
          zoomMax: 315360000000 * 0.25 #315360000000 = 10 years
          zoomMin: 10000 * 60
          cluster: true
          eventMargin: 5
          eventMarginAxis: 10
          groupMinHeight: 13
        timeline.setOptions options
        data = []
        data.push
          start: new Date(2014, 5, 27)
          content: "Event A"
          group: 'node down'
        data.push
          start: new Date(2014, 5, 24)
          content: "Event B"
          group: 'node down'
        data.push
          start: new Date(2014, 5, 22)
          group: 'link down'
        data.push
          start: new Date(2014, 5, 21)
          group: 'system down'
        timeline.draw(data)
        onselect = () ->
          if timeline.getSelection().length isnt 0
            console.log data[timeline.getSelection()[0].row]
        links.events.addListener timeline, 'select', onselect
      timeline_init()
      bind_timeline_and_controller()

      scope.play = ->
        playtime = 5000 #milliseconds
        scope.playbackstart = timeline.getVisibleChartRange().start.valueOf()
        scope.playbackend = timeline.getVisibleChartRange().end.valueOf()
        scope.playbackstep = (scope.playbackend - scope.playbackstart)/playtime
        scope.playmoment = scope.playbackstart
        allevent = timeline.getData()
        playbackloop = ->
          scope.playmoment = scope.playmoment + scope.playbackstep
          #console.log new Date(scope.playmoment)
          for event in allevent
            do ->
              if (event.start.valueOf() - scope.playmoment) > 0
                if (event.start.valueOf() - scope.playmoment) < scope.playbackstep
                  console.log event
          if scope.playmoment is scope.playbackend
            console.log 'end'
            $interval.cancel playloop
        playloop = $interval playbackloop, 1
        scope.pause = ->
          $interval.cancel playloop
          console.log 'pause'
          console.log scope.playmoment
        scope.reset = ->
          $interval.cancel playloop
          scope.playmoment = timeline.getVisibleChartRange().start.valueOf()
          console.log 'reset'
      scope.playback = ->
        console.log timeline
      scope.$on '$destroy', ->
        console.log 'timeline destroyed'
      console.log timeline
    return link
  #controller: "timelineController"
]).controller("timelineController", [
    "$scope"
    "$element"
    "$timeout"
    "$window"
    FlowChartController = ($scope, $element, $timeout, $window) ->
      time = new $window.Date()
      Number.prototype.pad = (size) ->
        s = String(this)
        size = 2  if typeof (size) isnt "number"
        s = "0" + s  while s.length < size
        s
      $scope.startDate = "#{time.getFullYear()}-#{time.getMonth().pad()}-#{time.getDate().pad()}"
      $scope.startTime = "#{time.getHours()-2}:#{time.getMinutes().pad()}:#{time.getSeconds().pad()}"
      $scope.endDate = "#{time.getFullYear()}-#{time.getMonth().pad()}-#{time.getDate().pad()}"
      $scope.endTime = "#{time.getHours()}:#{time.getMinutes().pad()}:#{time.getSeconds().pad()}"
      startYear = parseInt($scope.startDate.split('-')[0])
      startMonth = parseInt($scope.startDate.split('-')[1])
      startDay = parseInt($scope.startDate.split('-')[2])
      startHour = parseInt($scope.startTime.split(':')[0])
      startMin = parseInt($scope.startTime.split(':')[1])
      startSec = parseInt($scope.startTime.split(':')[2])
      endYear = parseInt($scope.endDate.split('-')[0])
      endMonth = parseInt($scope.endDate.split('-')[1])
      endDay = parseInt($scope.endDate.split('-')[2])
      endHour = parseInt($scope.endTime.split(':')[0])
      endMin = parseInt($scope.endTime.split(':')[1])
      endSec = parseInt($scope.endTime.split(':')[2])
      return
])