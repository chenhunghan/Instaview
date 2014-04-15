#
# Flowchart module.
#

#
# Directive that generates the rendered chart from the data model.
#

#
# Controller for the flowchart directive.
# Having a separate controller is better for unit testing, otherwise
# it is painful to unit test a directive without instantiating the DOM 
# (which is possible, just not ideal).
#

#
# Directive that allows the chart to be edited as json in a textarea.
#

#
# Serialize the data model as json and update the textarea.
#

#
# First up, set the initial value of the textarea.
#

#
# Watch for changes in the data model and update the textarea whenever necessary.
#

#
# Handle the change event from the textarea and update the data model
# from the modified json.
#

#
# Controller for the flowchart directive.
# Having a separate controller is better for unit testing, otherwise
# it is painful to unit test a directive without instantiating the DOM 
# (which is possible, just not ideal).
#
angular.module("flowChart", ["dragging"]).directive("flowChart", ->
  restrict: "E"
  templateUrl: "flowchart/flowchart_template.html"
  replace: true
  scope:
    chart: "=chart"

  controller: "FlowChartController"
).directive("chartJsonEdit", ->
  restrict: "A"
  scope:
    viewModel: "="

  link: (scope, elem, attr) ->
    updateJson = ->
      if scope.viewModel
        json = JSON.stringify(scope.viewModel.data, null, 4)
        $(elem).val json
      return

    updateJson()
    scope.$watch "viewModel.data", updateJson, true
    $(elem).bind "input propertychange", ->
      json = $(elem).val()
      dataModel = JSON.parse(json)
      scope.viewModel = new flowchart.ChartViewModel(dataModel)
      scope.$digest()
      return

    return
).controller "FlowChartController", [
  "$scope"
  "dragging"
  "$element"
  FlowChartController = ($scope, dragging, $element) ->
    controller = this
    
    #
    # Reference to the document and jQuery, can be overridden for testting.
    #
    @document = document
    
    #
    # Wrap jQuery so it can easily be  mocked for testing.
    #
    @jQuery = (element) ->
      $ element

    
    #
    # Init data-model variables.
    #
    $scope.draggingConnection = false
    $scope.connectorSize = 10
    $scope.dragSelecting = false
    
    # Can use this to test the drag selection rect.
    #	$scope.dragSelectionRect = {
    #		x: 0,
    #		y: 0,
    #		width: 0,
    #		height: 0,
    #	};
    #	
    
    #
    # Reference to the connection, connector or node that the mouse is currently over.
    #
    $scope.mouseOverConnector = null
    $scope.mouseOverConnection = null
    $scope.mouseOverNode = null
    
    #
    # The class for connections and connectors.
    #
    @connectionClass = "connection"
    @connectorClass = "connector"
    @nodeClass = "node"
    
    #
    # Search up the HTML element tree for an element the requested class.
    #
    @searchUp = (element, parentClass) ->
      
      #
      # Reached the root.
      #
      return null  if not element? or element.length is 0
      
      # 
      # Check if the element has the class that identifies it as a connector.
      #
      
      #
      # Found the connector element.
      #
      return element  if hasClassSVG(element, parentClass)
      
      #
      # Recursively search parent elements.
      #
      @searchUp element.parent(), parentClass

    
    #
    # Hit test and retreive node and connector that was hit at the specified coordinates.
    #
    @hitTest = (clientX, clientY) ->
      
      #
      # Retreive the element the mouse is currently over.
      #
      @document.elementFromPoint clientX, clientY

    
    #
    # Hit test and retreive node and connector that was hit at the specified coordinates.
    #
    @checkForHit = (mouseOverElement, whichClass) ->
      
      #
      # Find the parent element, if any, that is a connector.
      #
      hoverElement = @searchUp(@jQuery(mouseOverElement), whichClass)
      return null  unless hoverElement
      hoverElement.scope()

    
    #
    # Translate the coordinates so they are relative to the svg element.
    #
    @translateCoordinates = (x, y) ->
      svg_elem = $element.get(0)
      matrix = svg_elem.getScreenCTM()
      point = svg_elem.createSVGPoint()
      point.x = x
      point.y = y
      point.matrixTransform matrix.inverse()

    
    #
    # Called on mouse down in the chart.
    #
    $scope.mouseDown = (evt) ->
      $scope.chart.deselectAll()
      dragging.startDrag evt,
        
        #
        # Commence dragging... setup variables to display the drag selection rect.
        #
        dragStarted: (x, y) ->
          $scope.dragSelecting = true
          startPoint = controller.translateCoordinates(x, y)
          $scope.dragSelectionStartPoint = startPoint
          $scope.dragSelectionRect =
            x: startPoint.x
            y: startPoint.y
            width: 0
            height: 0

          return

        
        #
        # Update the drag selection rect while dragging continues.
        #
        dragging: (x, y) ->
          startPoint = $scope.dragSelectionStartPoint
          curPoint = controller.translateCoordinates(x, y)
          $scope.dragSelectionRect =
            x: (if curPoint.x > startPoint.x then startPoint.x else curPoint.x)
            y: (if curPoint.y > startPoint.y then startPoint.y else curPoint.y)
            width: (if curPoint.x > startPoint.x then curPoint.x - startPoint.x else startPoint.x - curPoint.x)
            height: (if curPoint.y > startPoint.y then curPoint.y - startPoint.y else startPoint.y - curPoint.y)

          return

        
        #
        # Dragging has ended... select all that are within the drag selection rect.
        #
        dragEnded: ->
          $scope.dragSelecting = false
          $scope.chart.applySelectionRect $scope.dragSelectionRect
          delete $scope.dragSelectionStartPoint

          delete $scope.dragSelectionRect

          return

      return

    
    #
    # Called for each mouse move on the svg element.
    #
    $scope.mouseMove = (evt) ->
      
      #
      # Clear out all cached mouse over elements.
      #
      $scope.mouseOverConnection = null
      $scope.mouseOverConnector = null
      $scope.mouseOverNode = null
      mouseOverElement = controller.hitTest(evt.clientX, evt.clientY)
      
      # Mouse isn't over anything, just clear all.
      return  unless mouseOverElement?
      unless $scope.draggingConnection # Only allow 'connection mouse over' when not dragging out a connection.
        
        # Figure out if the mouse is over a connection.
        scope = controller.checkForHit(mouseOverElement, controller.connectionClass)
        $scope.mouseOverConnection = (if (scope and scope.connection) then scope.connection else null)
        
        # Don't attempt to mouse over anything else.
        return  if $scope.mouseOverConnection
      
      # Figure out if the mouse is over a connector.
      scope = controller.checkForHit(mouseOverElement, controller.connectorClass)
      $scope.mouseOverConnector = (if (scope and scope.connector) then scope.connector else null)
      
      # Don't attempt to mouse over anything else.
      return  if $scope.mouseOverConnector
      
      # Figure out if the mouse is over a node.
      scope = controller.checkForHit(mouseOverElement, controller.nodeClass)
      $scope.mouseOverNode = (if (scope and scope.node) then scope.node else null)
      return

    
    #
    # Handle mousedown on a node.
    #
    $scope.nodeMouseDown = (evt, node) ->
      chart = $scope.chart
      lastMouseCoords = undefined
      dragging.startDrag evt,
        
        #
        # Node dragging has commenced.
        #
        dragStarted: (x, y) ->
          lastMouseCoords = controller.translateCoordinates(x, y)
          
          #
          # If nothing is selected when dragging starts, 
          # at least select the node we are dragging.
          #
          unless node.selected()
            chart.deselectAll()
            node.select()
          return

        
        #
        # Dragging selected nodes... update their x,y coordinates.
        #
        dragging: (x, y) ->
          curCoords = controller.translateCoordinates(x, y)
          deltaX = curCoords.x - lastMouseCoords.x
          deltaY = curCoords.y - lastMouseCoords.y
          chart.updateSelectedNodesLocation deltaX, deltaY
          lastMouseCoords = curCoords
          return

        
        #
        # The node wasn't dragged... it was clicked.
        #
        clicked: ->
          chart.handleNodeClicked node, evt.ctrlKey
          return

      return

    
    #
    # Handle mousedown on a connection.
    #
    $scope.connectionMouseDown = (evt, connection) ->
      chart = $scope.chart
      chart.handleConnectionMouseDown connection, evt.ctrlKey
      
      # Don't let the chart handle the mouse down.
      evt.stopPropagation()
      evt.preventDefault()
      return

    
    #
    # Handle mousedown on an input connector.
    #
    $scope.connectorMouseDown = (evt, node, connector, connectorIndex, isInputConnector) ->
      
      #
      # Initiate dragging out of a connection.
      #
      dragging.startDrag evt,
        
        #
        # Called when the mouse has moved greater than the threshold distance
        # and dragging has commenced.
        #
        dragStarted: (x, y) ->
          curCoords = controller.translateCoordinates(x, y)
          $scope.draggingConnection = true
          $scope.dragPoint1 = flowchart.computeConnectorPos(node, connectorIndex, isInputConnector)
          $scope.dragPoint2 =
            x: curCoords.x
            y: curCoords.y

          $scope.dragTangent1 = flowchart.computeConnectionSourceTangent($scope.dragPoint1, $scope.dragPoint2)
          $scope.dragTangent2 = flowchart.computeConnectionDestTangent($scope.dragPoint1, $scope.dragPoint2)
          return

        
        #
        # Called on mousemove while dragging out a connection.
        #
        dragging: (x, y, evt) ->
          startCoords = controller.translateCoordinates(x, y)
          $scope.dragPoint1 = flowchart.computeConnectorPos(node, connectorIndex, isInputConnector)
          $scope.dragPoint2 =
            x: startCoords.x
            y: startCoords.y

          $scope.dragTangent1 = flowchart.computeConnectionSourceTangent($scope.dragPoint1, $scope.dragPoint2)
          $scope.dragTangent2 = flowchart.computeConnectionDestTangent($scope.dragPoint1, $scope.dragPoint2)
          return

        
        #
        # Clean up when dragging has finished.
        #
        dragEnded: ->
          
          #
          # Dragging has ended...
          # The mouse is over a valid connector...
          # Create a new connection.
          #
          $scope.chart.createNewConnection connector, $scope.mouseOverConnector  if $scope.mouseOverConnector and $scope.mouseOverConnector isnt connector
          $scope.draggingConnection = false
          delete $scope.dragPoint1

          delete $scope.dragTangent1

          delete $scope.dragPoint2

          delete $scope.dragTangent2

          return

      return
]
