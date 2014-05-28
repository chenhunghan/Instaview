angular.module("timeline", []).directive("timeline", ['$timeout', ($timeout) ->
  restrict: "E"
  template: "<div></div>"
  replace: true
  scope:
    chart: "=chart"
  link: (scope, ele, attr, ctrl) ->
    onselect = () ->
      if timeline.getSelection().length isnt 0
        console.log data[timeline.getSelection()[0].row]
    timeline = new links.Timeline(ele[0])
    links.events.addListener timeline, 'select', onselect
    options =
      width: "90%"
      height: "35%"
      zoomMax: 315360000000 * 0.25 #315360000000 = 10 years
      zoomMin: 10000 * 60
      cluster: true
      eventMargin: 5
      eventMarginAxis: 10
    timeline.setOptions options
    data = []
    data.push
      start: new Date(2014, 5, 27)
      #end: new Date(2010, 8, 2) # end is optional
      content: "Event A"
      group: 'node down'
      type: 'dot'
      className: '1111'
    data.push
      start: new Date(2014, 5, 24)
      content: "Event B"
      group: 'node down'
      className: '11122'
    data.push
      start: new Date(2014, 5, 22)
      group: 'link down'
    data.push
      start: new Date(2014, 5, 21)
      group: 'system down'
    timeline.draw(data)
    $timeout (->
      #console.log $scope.chart.data.nodes
      scope.chart.data.nodes = scope.chart.data.nodes.splice(0,10)
      scope.chart.updateNodeQuantity()
    ), 1000
  #controller: "timelineController"
]).controller("timelineController", [
    "$scope"
    "$element"
    "$timeout"
    "$window"
    FlowChartController = ($scope, $element, $timeout, $window) ->
      #console.log $element

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