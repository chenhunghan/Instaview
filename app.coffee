
flowchart = {}

# Module.
(->
  # Width of a node.
  flowchart.nodeWidth = 250
  # Amount of space reserved for displaying the node's name.
  flowchart.nodeNameHeight = 40
  # Height of a connector in a node.
  flowchart.connectorHeight = 35
  # Compute the Y coordinate of a connector, given its index.
  flowchart.computeConnectorY = (connectorIndex) ->
    flowchart.nodeNameHeight + (connectorIndex * flowchart.connectorHeight)
  # Compute the position of a connector in the graph.
  flowchart.computeConnectorPos = (node, connectorIndex, inputConnector) ->
    x: node.x() + ((if inputConnector then 0 else flowchart.nodeWidth))
    y: node.y() + flowchart.computeConnectorY(connectorIndex)
  # View model for a connector.
  flowchart.ConnectorViewModel = (connectorDataModel, x, y, parentNode) ->
    @data = connectorDataModel
    @_parentNode = parentNode
    @_x = x
    @_y = y
    # The name of the connector.
    @name = ->
      @data.name
    # X coordinate of the connector.
    @x = ->
      @_x
    # Y coordinate of the connector.
    @y = ->
      @_y
    # The parent node that the connector is attached to.
    @parentNode = ->
      @_parentNode
    return

  # Create view model for a list of data models.
  createConnectorsViewModel = (connectorDataModels, x, parentNode) ->
    viewModels = []
    if connectorDataModels
      i = 0
      while i < connectorDataModels.length
        connectorViewModel = new flowchart.ConnectorViewModel(connectorDataModels[i], x, flowchart.computeConnectorY(i), parentNode)
        viewModels.push connectorViewModel
        ++i
    viewModels
  # View model for a node.
  flowchart.NodeViewModel = (nodeDataModel) ->
    @data = nodeDataModel
    @inputConnectors = createConnectorsViewModel(@data.inputConnectors, 0, this)
    @outputConnectors = createConnectorsViewModel(@data.outputConnectors, flowchart.nodeWidth, this)
    # Set to true when the node is selected.
    @_selected = false
    # Name of the node.
    @name = ->
      @data.name or ""
    # X coordinate of the node.
    @x = ->
      @data.x
    # Y coordinate of the node.
    @y = ->
      @data.y
    # Width of the node.
    @width = ->
      flowchart.nodeWidth
    # Height of the node.
    @height = ->
      numConnectors = Math.max(@inputConnectors.length, @outputConnectors.length)
      flowchart.computeConnectorY numConnectors
    # Select the node.
    @select = ->
      @_selected = true
      return
    # Deselect the node.
    @deselect = ->
      @_selected = false
      return
    # Toggle the selection state of the node.
    @toggleSelected = ->
      @_selected = not @_selected
      return
    # Returns true if the node is selected.
    @selected = ->
      @_selected
    # Internal function to add a connector.
    @_addConnector = (connectorDataModel, x, connectorsDataModel, connectorsViewModel) ->
      connectorViewModel = new flowchart.ConnectorViewModel(connectorDataModel, x, flowchart.computeConnectorY(connectorsViewModel.length), this)
      connectorsDataModel.push connectorDataModel
      # Add to node's view model.
      connectorsViewModel.push connectorViewModel
      return
    # Add an input connector to the node.
    @addInputConnector = (connectorDataModel) ->
      @data.inputConnectors = []  unless @data.inputConnectors
      @_addConnector connectorDataModel, 0, @data.inputConnectors, @inputConnectors
      return
    # Add an ouput connector to the node.
    @addOutputConnector = (connectorDataModel) ->
      @data.outputConnectors = []  unless @data.outputConnectors
      @_addConnector connectorDataModel, flowchart.nodeWidth, @data.outputConnectors, @outputConnectors
      return
    return
  # Wrap the nodes data-model in a view-model.
  createNodesViewModel = (nodesDataModel) ->
    nodesViewModel = []
    if nodesDataModel
      i = 0
      while i < nodesDataModel.length
        nodesViewModel.push new flowchart.NodeViewModel(nodesDataModel[i])
        ++i
    nodesViewModel
  # View model for a connection.
  flowchart.ConnectionViewModel = (connectionDataModel, sourceConnector, destConnector) ->
    @data = connectionDataModel
    @source = sourceConnector
    @dest = destConnector
    # Set to true when the connection is selected.
    @_selected = false
    @sourceCoordX = ->
      @source.parentNode().x() + @source.x()
    @sourceCoordY = ->
      @source.parentNode().y() + @source.y()
    @sourceCoord = ->
      x: @sourceCoordX()
      y: @sourceCoordY()
    @sourceTangentX = ->
      flowchart.computeConnectionSourceTangentX @sourceCoord(), @destCoord()
    @sourceTangentY = ->
      flowchart.computeConnectionSourceTangentY @sourceCoord(), @destCoord()
    @destCoordX = ->
      @dest.parentNode().x() + @dest.x()
    @destCoordY = ->
      @dest.parentNode().y() + @dest.y()
    @destCoord = ->
      x: @destCoordX()
      y: @destCoordY()
    @destTangentX = ->
      flowchart.computeConnectionDestTangentX @sourceCoord(), @destCoord()
    @destTangentY = ->
      flowchart.computeConnectionDestTangentY @sourceCoord(), @destCoord()
    # Select the connection.
    @select = ->
      @_selected = true
      return
    # Deselect the connection.
    @deselect = ->
      @_selected = false
      return
    # Toggle the selection state of the connection.
    @toggleSelected = ->
      @_selected = not @_selected
      return
    # Returns true if the connection is selected.
    @selected = ->
      @_selected
    return
  # Helper function.
  computeConnectionTangentOffset = (pt1, pt2) ->
    (pt2.x - pt1.x) / 2
  # Compute the tangent for the bezier curve.
  flowchart.computeConnectionSourceTangentX = (pt1, pt2) ->
    pt1.x + computeConnectionTangentOffset(pt1, pt2)
  # Compute the tangent for the bezier curve.
  flowchart.computeConnectionSourceTangentY = (pt1, pt2) ->
    pt1.y
  # Compute the tangent for the bezier curve.
  flowchart.computeConnectionSourceTangent = (pt1, pt2) ->
    x: flowchart.computeConnectionSourceTangentX(pt1, pt2)
    y: flowchart.computeConnectionSourceTangentY(pt1, pt2)
  # Compute the tangent for the bezier curve.
  flowchart.computeConnectionDestTangentX = (pt1, pt2) ->
    pt2.x - computeConnectionTangentOffset(pt1, pt2)
  # Compute the tangent for the bezier curve.
  flowchart.computeConnectionDestTangentY = (pt1, pt2) ->
    pt2.y
  # Compute the tangent for the bezier curve.
  flowchart.computeConnectionDestTangent = (pt1, pt2) ->
    x: flowchart.computeConnectionDestTangentX(pt1, pt2)
    y: flowchart.computeConnectionDestTangentY(pt1, pt2)
  # View model for the chart.
  flowchart.ChartViewModel = (chartDataModel) ->
    # Find a specific node within the chart.
    @findNode = (nodeID) ->
      i = 0
      while i < @nodes.length
        node = @nodes[i]
        return node if node.data.id is nodeID
        ++i
      throw new Error("Failed to find node " + nodeID)
      return
    # Find a specific input connector within the chart.
    @findInputConnector = (nodeID, connectorIndex) ->
      node = @findNode(nodeID)
      throw new Error("Node " + nodeID + " has invalid input connectors.")  if not node.inputConnectors or node.inputConnectors.length <= connectorIndex
      node.inputConnectors[connectorIndex]
    # Find a specific output connector within the chart.
    @findOutputConnector = (nodeID, connectorIndex) ->
      node = @findNode(nodeID)
      throw new Error("Node " + nodeID + " has invalid output connectors.")  if not node.outputConnectors or node.outputConnectors.length <= connectorIndex
      node.outputConnectors[connectorIndex]
    # Create a view model for connection from the data model.
    @_createConnectionViewModel = (connectionDataModel) ->
      sourceConnector = @findOutputConnector(connectionDataModel.source.nodeID, connectionDataModel.source.connectorIndex)
      destConnector = @findInputConnector(connectionDataModel.dest.nodeID, connectionDataModel.dest.connectorIndex)
      new flowchart.ConnectionViewModel(connectionDataModel, sourceConnector, destConnector)
    # Wrap the connections data-model in a view-model.
    @_createConnectionsViewModel = (connectionsDataModel) ->
      connectionsViewModel = []
      if connectionsDataModel
        i = 0

        while i < connectionsDataModel.length
          connectionsViewModel.push @_createConnectionViewModel(connectionsDataModel[i])
          ++i
      connectionsViewModel
    # Reference to the underlying data.
    @data = chartDataModel
    # Create a view-model for nodes.
    @nodes = createNodesViewModel(@data.nodes)
    # Create a view-model for connections.
    @connections = @_createConnectionsViewModel(@data.connections)
    # Create a view model for a new connection.
    @createNewConnection = (sourceConnector, destConnector) ->
      debug.assertObjectValid sourceConnector
      debug.assertObjectValid destConnector
      connectionsDataModel = @data.connections
      connectionsDataModel = @data.connections = []  unless connectionsDataModel
      connectionsViewModel = @connections
      connectionsViewModel = @connections = []  unless connectionsViewModel
      sourceNode = sourceConnector.parentNode()
      sourceConnectorIndex = sourceNode.outputConnectors.indexOf(sourceConnector)
      if sourceConnectorIndex is -1
        sourceConnectorIndex = sourceNode.inputConnectors.indexOf(sourceConnector)
        throw new Error("Failed to find source connector within either inputConnectors or outputConnectors of source node.")  if sourceConnectorIndex is -1
      destNode = destConnector.parentNode()
      destConnectorIndex = destNode.inputConnectors.indexOf(destConnector)
      if destConnectorIndex is -1
        destConnectorIndex = destNode.outputConnectors.indexOf(destConnector)
        throw new Error("Failed to find dest connector within inputConnectors or ouputConnectors of dest node.")  if destConnectorIndex is -1
      connectionDataModel =
        source:
          nodeID: sourceNode.data.id
          connectorIndex: sourceConnectorIndex
        dest:
          nodeID: destNode.data.id
          connectorIndex: destConnectorIndex
      connectionsDataModel.push connectionDataModel
      connectionViewModel = new flowchart.ConnectionViewModel(connectionDataModel, sourceConnector, destConnector)
      connectionsViewModel.push connectionViewModel
      return
    # Add a node to the view model.
    @addNode = (nodeDataModel) ->
      @data.nodes = []  unless @data.nodes
      # Update the data model.
      @data.nodes.push nodeDataModel
      # Update the view model.
      @nodes.push new flowchart.NodeViewModel(nodeDataModel)
      return
    # Select all nodes and connections in the chart.
    @selectAll = ->
      nodes = @nodes
      i = 0
      while i < nodes.length
        node = nodes[i]
        node.select()
        ++i
      connections = @connections
      i = 0
      while i < connections.length
        connection = connections[i]
        connection.select()
        ++i
      return
    # Deselect all nodes and connections in the chart.
    @deselectAll = ->
      nodes = @nodes
      i = 0
      while i < nodes.length
        node = nodes[i]
        node.deselect()
        ++i
      connections = @connections
      i = 0
      while i < connections.length
        connection = connections[i]
        connection.deselect()
        ++i
      return
    # Update the location of the node and its connectors.
    @updateSelectedNodesLocation = (deltaX, deltaY) ->
      selectedNodes = @getSelectedNodes()
      i = 0
      while i < selectedNodes.length
        node = selectedNodes[i]
        node.data.x += deltaX
        node.data.y += deltaY
        ++i
      return
    # Handle mouse click on a particular node.
    @handleNodeClicked = (node, ctrlKey) ->
      if ctrlKey
        node.toggleSelected()
      else
        @deselectAll()
        node.select()
      # Move node to the end of the list so it is rendered after all the other.
      # This is the way Z-order is done in SVG.
      nodeIndex = @nodes.indexOf(node)
      throw new Error("Failed to find node in view model!")  if nodeIndex is -1
      @nodes.splice nodeIndex, 1
      @nodes.push node
      return
    # Handle mouse down on a connection.
    @handleConnectionMouseDown = (connection, ctrlKey) ->
      if ctrlKey
        connection.toggleSelected()
      else
        @deselectAll()
        connection.select()
      return
    # Delete all nodes and connections that are selected.
    @deleteSelected = ->
      newNodeViewModels = []
      newNodeDataModels = []
      deletedNodeIds = []
      # Sort nodes into:
      #		nodes to keep and
      #		nodes to delete.
      nodeIndex = 0

      while nodeIndex < @nodes.length
        node = @nodes[nodeIndex]
        unless node.selected()
          # Only retain non-selected nodes.
          newNodeViewModels.push node
          newNodeDataModels.push node.data
        else
          # Keep track of nodes that were deleted, so their connections can also
          # be deleted.
          deletedNodeIds.push node.data.id
        ++nodeIndex
      newConnectionViewModels = []
      newConnectionDataModels = []

      # Remove connections that are selected.
      # Also remove connections for nodes that have been deleted.
      connectionIndex = 0

      while connectionIndex < @connections.length
        connection = @connections[connectionIndex]
        if not connection.selected() and deletedNodeIds.indexOf(connection.data.source.nodeID) is -1 and deletedNodeIds.indexOf(connection.data.dest.nodeID) is -1
          # The nodes this connection is attached to, where not deleted,
          # so keep the connection.
          newConnectionViewModels.push connection
          newConnectionDataModels.push connection.data
        ++connectionIndex

      # Update nodes and connections.
      @nodes = newNodeViewModels
      @data.nodes = newNodeDataModels
      @connections = newConnectionViewModels
      @data.connections = newConnectionDataModels
      return

    # Select nodes and connections that fall within the selection rect.
    @applySelectionRect = (selectionRect) ->
      @deselectAll()
      i = 0
      while i < @nodes.length
        node = @nodes[i]
        # Select nodes that are within the selection rect.
        node.select()  if node.x() >= selectionRect.x and node.y() >= selectionRect.y and node.x() + node.width() <= selectionRect.x + selectionRect.width and node.y() + node.height() <= selectionRect.y + selectionRect.height
        ++i
      i = 0

      while i < @connections.length
        connection = @connections[i]
        # Select the connection if both its parent nodes are selected.
        connection.select()  if connection.source.parentNode().selected() and connection.dest.parentNode().selected()
        ++i
      return

    # Get the array of nodes that are currently selected.
    @getSelectedNodes = ->
      selectedNodes = []
      i = 0
      while i < @nodes.length
        node = @nodes[i]
        selectedNodes.push node  if node.selected()
        ++i
      selectedNodes

    # Get the array of connections that are currently selected.
    @getSelectedConnections = ->
      selectedConnections = []
      i = 0
      while i < @connections.length
        connection = @connections[i]
        selectedConnections.push connection  if connection.selected()
        ++i
      selectedConnections
    return
  return
)()

angular.module("app", ["flowChart"]).factory("prompt", ->
  prompt
).controller "AppCtrl", [
  "$scope"
  "prompt"
  AppCtrl = ($scope, prompt) ->
    # Code for the delete key.
    deleteKeyCode = 46
    # Code for control key.
    ctrlKeyCode = 65
    # Set to true when the ctrl key is down.
    ctrlDown = false
    # Code for A key.
    aKeyCode = 17
    # Code for esc key.
    escKeyCode = 27
    # Selects the next node id.
    nextNodeID = 10
    # Setup the data-model for the chart.
    chartDataModel =
      nodes: [
        {
          name: "Example Node 1"
          id: 0
          x: 0
          y: 0
          inputConnectors: [
            {
              name: "A"
            }
            {
              name: "B"
            }
            {
              name: "C"
            }
          ]
          outputConnectors: [
            {
              name: "A"
            }
            {
              name: "B"
            }
            {
              name: "C"
            }
          ]
        }
        {
          name: "Example Node 2"
          id: 1
          x: 400
          y: 200
          inputConnectors: [
            {
              name: "A"
            }
            {
              name: "B"
            }
            {
              name: "C"
            }
          ]
          outputConnectors: [
            {
              name: "A"
            }
            {
              name: "B"
            }
            {
              name: "C"
            }
          ]
        }
      ]
      connections: [
        source:
          nodeID: 0
          connectorIndex: 1

        dest:
          nodeID: 1
          connectorIndex: 2
      ]

    # Event handler for key-down on the flowchart.
    $scope.keyDown = (evt) ->
      if evt.keyCode is ctrlKeyCode
        ctrlDown = true
        evt.stopPropagation()
        evt.preventDefault()
      return

    # Event handler for key-up on the flowchart.
    $scope.keyUp = (evt) ->
      # Delete key.
      $scope.chartViewModel.deleteSelected()  if evt.keyCode is deleteKeyCode
      # Ctrl + A
      $scope.chartViewModel.selectAll()  if evt.keyCode is aKeyCode and ctrlDown
      # Escape.
      $scope.chartViewModel.deselectAll()  if evt.keyCode is escKeyCode
      if evt.keyCode is ctrlKeyCode
        ctrlDown = false
        evt.stopPropagation()
        evt.preventDefault()
      return

    # Add a new node to the chart.
    $scope.addNewNode = ->
      nodeName = prompt("Enter a node name:", "New node")
      return  unless nodeName
      # Template for a new node.
      newNodeDataModel =
        name: nodeName
        id: nextNodeID++
        x: 0
        y: 0
        inputConnectors: [
          {
            name: "X"
          }
          {
            name: "Y"
          }
          {
            name: "Z"
          }
        ]
        outputConnectors: [
          {
            name: "1"
          }
          {
            name: "2"
          }
          {
            name: "3"
          }
        ]

      $scope.chartViewModel.addNode newNodeDataModel
      return

    # Add an input connector to selected nodes.
    $scope.addNewInputConnector = ->
      connectorName = prompt("Enter a connector name:", "New connector")
      return  unless connectorName
      selectedNodes = $scope.chartViewModel.getSelectedNodes()
      i = 0
      while i < selectedNodes.length
        node = selectedNodes[i]
        node.addInputConnector name: connectorName
        ++i
      return

    # Add an output connector to selected nodes.
    $scope.addNewOutputConnector = ->
      connectorName = prompt("Enter a connector name:", "New connector")
      return  unless connectorName
      selectedNodes = $scope.chartViewModel.getSelectedNodes()
      i = 0
      while i < selectedNodes.length
        node = selectedNodes[i]
        node.addOutputConnector name: connectorName
        ++i
      return

    # Delete selected nodes and connections.
    $scope.deleteSelected = ->
      $scope.chartViewModel.deleteSelected()
      return

    # Create the view-model for the chart and attach to the scope.
    $scope.chartViewModel = new flowchart.ChartViewModel(chartDataModel)
]

# Debug utilities.

(->
  throw new Error("debug object already defined!")  if typeof debug isnt "undefined"
  debug = {}
  # Assert that an object is valid.
  debug.assertObjectValid = (obj) ->
    throw new Exception("Invalid object!")  unless obj
    throw new Error("Input is not an object! It is a " + typeof (obj))  if $.isPlainObject(obj)
    return
  return
)()

removeClassSVG = (obj, remove) ->
  classes = obj.attr("class")
  return false  unless classes
  index = classes.search(remove)
  # if the class already doesn't exist, return false now
  if index is -1
    false
  else
    # string manipulation to remove the class
    classes = classes.substring(0, index) + classes.substring((index + remove.length), classes.length)
    # set the new string as the object's class
    obj.attr "class", classes
    true

hasClassSVG = (obj, has) ->
  classes = obj.attr("class")
  return false  unless classes
  index = classes.search(has)
  if index is -1
    false
  else
    true

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
    # Reference to the document and jQuery, can be overridden for testting.
    @document = document
    # Wrap jQuery so it can easily be  mocked for testing.
    @jQuery = (element) ->
      $ element
    # Init data-model variables.
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
    # Reference to the connection, connector or node that the mouse is currently over.
    $scope.mouseOverConnector = null
    $scope.mouseOverConnection = null
    $scope.mouseOverNode = null
    # The class for connections and connectors.
    @connectionClass = "connection"
    @connectorClass = "connector"
    @nodeClass = "node"
    # Search up the HTML element tree for an element the requested class.
    @searchUp = (element, parentClass) ->
      # Reached the root.
      return null  if not element? or element.length is 0
      # Check if the element has the class that identifies it as a connector.
      # Found the connector element.
      return element  if hasClassSVG(element, parentClass)
      # Recursively search parent elements.
      @searchUp element.parent(), parentClass
    # Hit test and retreive node and connector that was hit at the specified coordinates.
    @hitTest = (clientX, clientY) ->
      # Retreive the element the mouse is currently over.
      @document.elementFromPoint clientX, clientY
    # Hit test and retreive node and connector that was hit at the specified coordinates.
    @checkForHit = (mouseOverElement, whichClass) ->
      # Find the parent element, if any, that is a connector.
      hoverElement = @searchUp(@jQuery(mouseOverElement), whichClass)
      return null  unless hoverElement
      hoverElement.scope()
    # Translate the coordinates so they are relative to the svg element.
    @translateCoordinates = (x, y) ->
      svg_elem = $element.get(0)
      matrix = svg_elem.getScreenCTM()
      point = svg_elem.createSVGPoint()
      point.x = x
      point.y = y
      point.matrixTransform matrix.inverse()
    # Called on mouse down in the chart.
    $scope.mouseDown = (evt) ->
      $scope.chart.deselectAll()
      dragging.startDrag evt,
        # Commence dragging... setup variables to display the drag selection rect.
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
      # Update the drag selection rect while dragging continues.
        dragging: (x, y) ->
          startPoint = $scope.dragSelectionStartPoint
          curPoint = controller.translateCoordinates(x, y)
          $scope.dragSelectionRect =
            x: (if curPoint.x > startPoint.x then startPoint.x else curPoint.x)
            y: (if curPoint.y > startPoint.y then startPoint.y else curPoint.y)
            width: (if curPoint.x > startPoint.x then curPoint.x - startPoint.x else startPoint.x - curPoint.x)
            height: (if curPoint.y > startPoint.y then curPoint.y - startPoint.y else startPoint.y - curPoint.y)
          return
      # Dragging has ended... select all that are within the drag selection rect.
        dragEnded: ->
          $scope.dragSelecting = false
          $scope.chart.applySelectionRect $scope.dragSelectionRect
          delete $scope.dragSelectionStartPoint
          delete $scope.dragSelectionRect
          return
      return
    # Called for each mouse move on the svg element.
    $scope.mouseMove = (evt) ->
      # Clear out all cached mouse over elements.
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

    # Handle mousedown on a node.
    $scope.nodeMouseDown = (evt, node) ->
      chart = $scope.chart
      lastMouseCoords = undefined
      dragging.startDrag evt,
        # Node dragging has commenced.
        dragStarted: (x, y) ->
          lastMouseCoords = controller.translateCoordinates(x, y)
          # If nothing is selected when dragging starts,
          # at least select the node we are dragging.
          unless node.selected()
            chart.deselectAll()
            node.select()
          return

      # Dragging selected nodes... update their x,y coordinates.
        dragging: (x, y) ->
          curCoords = controller.translateCoordinates(x, y)
          deltaX = curCoords.x - lastMouseCoords.x
          deltaY = curCoords.y - lastMouseCoords.y
          chart.updateSelectedNodesLocation deltaX, deltaY
          lastMouseCoords = curCoords
          return

      # The node wasn't dragged... it was clicked.
        clicked: ->
          chart.handleNodeClicked node, evt.ctrlKey
          return
      return

    # Handle mousedown on a connection.
    $scope.connectionMouseDown = (evt, connection) ->
      chart = $scope.chart
      chart.handleConnectionMouseDown connection, evt.ctrlKey
      # Don't let the chart handle the mouse down.
      evt.stopPropagation()
      evt.preventDefault()
      return

    # Handle mousedown on an input connector.
    $scope.connectorMouseDown = (evt, node, connector, connectorIndex, isInputConnector) ->
      # Initiate dragging out of a connection.
      dragging.startDrag evt,
        # Called when the mouse has moved greater than the threshold distance
        # and dragging has commenced.
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
      # Called on mousemove while dragging out a connection.
        dragging: (x, y, evt) ->
          startCoords = controller.translateCoordinates(x, y)
          $scope.dragPoint1 = flowchart.computeConnectorPos(node, connectorIndex, isInputConnector)
          $scope.dragPoint2 =
            x: startCoords.x
            y: startCoords.y
          $scope.dragTangent1 = flowchart.computeConnectionSourceTangent($scope.dragPoint1, $scope.dragPoint2)
          $scope.dragTangent2 = flowchart.computeConnectionDestTangent($scope.dragPoint1, $scope.dragPoint2)
          return
      # Clean up when dragging has finished.
        dragEnded: ->
          # Dragging has ended...
          # The mouse is over a valid connector...
          # Create a new connection.
          $scope.chart.createNewConnection connector, $scope.mouseOverConnector  if $scope.mouseOverConnector and $scope.mouseOverConnector isnt connector
          $scope.draggingConnection = false
          delete $scope.dragPoint1
          delete $scope.dragTangent1
          delete $scope.dragPoint2
          delete $scope.dragTangent2
          return
      return
]