
# Debug utilities.
throw new Error("debug object already defined!")  if typeof debug isnt "undefined"
debug = {}

# Assert that an object is valid.
debug.assertObjectValid = (obj) ->
  throw new Exception("Invalid object!")  unless obj
  throw new Error("Input is not an object! It is a " + typeof (obj))  if $.isPlainObject(obj)

ngapp = angular.module("app", ["flowChart", 'mgcrea.ngStrap', 'topo'])

ngapp.service "flowchartDataModel", [ ()->
  flowchart = this
  # Width of a node.
  flowchart.nodeWidth = 125
  flowchart.padding = 22
  # Amount of space reserved for displaying the node's name.
  flowchart.nodeNameHeight = 70
  # Height of a connector in a node.
  flowchart.connectorHeight = 56
  # Compute the Y coordinate of a connector, given its index.
  flowchart.computeConnectorY = (connectorIndex) ->
    flowchart.nodeNameHeight + (connectorIndex * flowchart.connectorHeight)
  # Compute the position of a connector in the graph.
  flowchart.computeConnectorPos = (node, connectorIndex, inputConnector) ->
    x: node.x() + (if inputConnector then flowchart.padding else (flowchart.nodeWidth - flowchart.padding))
    y: node.y() + flowchart.computeConnectorY(connectorIndex)
  # View model for a connector.
  flowchart.ConnectorViewModel = (connectorDataModel, x, y, parentNode) ->
    if x is 0
      x = x + flowchart.padding
    else
      x = x - flowchart.padding
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
    #padding = 18 #padding space for each connector
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
      if @source
        @source.parentNode().x() + @source.x()
    @sourceCoordY = ->
      if @source
        @source.parentNode().y() + @source.y()
    @sourceCoord = ->
      x: @sourceCoordX()
      y: @sourceCoordY()
    @sourceTangentX = ->
      flowchart.computeConnectionSourceTangentX @sourceCoord(), @destCoord()
    @sourceTangentY = ->
      flowchart.computeConnectionSourceTangentY @sourceCoord(), @destCoord()
    @destCoordX = ->
      if @dest
        @dest.parentNode().x() + @dest.x()
    @destCoordY = ->
      if @dest
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
      ###
      node = @findNode(nodeID)

      for co in node.inputConnectors
        if node.inputConnectors.indexOf(co) is connectorIndex
          #console.log co
          return co
      if not node.inputConnectors or node.inputConnectors.length <= connectorIndex
        throw new Error("Node " + nodeID + " has invalid input connectors.")
      node.inputConnectors[connectorIndex]
      ###
      node = @findNode(nodeID)
      for co in node.inputConnectors
        #console.log co
        if co.data.name is connectorIndex
          n = co
      for co in node.outputConnectors
        #console.log co
        if co.data.name is connectorIndex
          n = co
      n
    # Find a specific output connector within the chart.
    @findOutputConnector = (nodeID, connectorIndex) ->
      #if not node.outputConnectors or node.outputConnectors.length <= connectorIndex
      #  throw new Error("Node " + nodeID + " has invalid output connectors.")
      node = @findNode(nodeID)
      for co in node.outputConnectors
        #console.log co
        if co.data.name is connectorIndex
          n = co
      for co in node.inputConnectors
        #console.log co
        if co.data.name is connectorIndex
          n = co
          #return co
      #n = node.outputConnectors[connectorIndex]
      #console.log 'node.outputConnectors[connectorIndex]'
      #console.log n
      console.log connectorIndex if n is undefined
      console.log node.outputConnectors if n is undefined
      console.log node.inputConnectors if n is undefined
      n
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
    @handleNodeClicked = (node, evt) ->
      if evt
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
]
ngapp.service "prompt", ["$modal", ($modal) ->
  @show = (title, value, $scope, cb) ->
    $scope.title = title
    Modal = $modal
      scope: $scope
      animation: "am-fade-and-scale"
      template: "modal_input.html"
    #The original Modal does not work properly, we have to change it as this:
    Modal.hide = () ->
      $(".modal").hide()
      $(".modal-backdrop").hide()
    $scope.hide = () ->
      Modal.hide()
    $scope.printdata = () ->
      console.log $scope.newValue
    Modal.$promise.then ->
      Modal.show()
    $scope.confirm = () ->
      $scope.hide()
      cb()
]
ngapp.controller "AppCtrl", [
  "$scope"
  "$http"
  "prompt"
  "flowchartDataModel"
  "topoAlgorithm"
  AppCtrl = ($scope, $http, prompt, flowchartDataModel, topoAlgorithm) ->
    $http.get('resource/wonju_topd.json').success (topd) ->
      raw = (dev for ip,dev of topd)
      cb = (data) ->
        chartDataModel =
          nodes: [
            {
              name: "IS-084"
              id: 0
              x: 0
              y: 0
              inputConnectors: [
                {
                  name: "P1"
                }
                {
                  name: "P2"
                }
                {
                  name: "P3"
                }
                {
                  name: "P4"
                }
              ]
              outputConnectors: [
                {
                  name: "P5"
                }
                {
                  name: "P6"
                }
                {
                  name: "P7"
                }
                {
                  name: "P8"
                }
              ]
            }
            {
              name: "IS-085"
              id: 1
              x: 400
              y: 200
              inputConnectors: [
                {
                  name: "P1"
                }
                {
                  name: "P2"
                }
                {
                  name: "P3"
                }
                {
                  name: "P4"
                }
              ]
              outputConnectors: [
                {
                  name: "P5"
                }
                {
                  name: "P6"
                }
                {
                  name: "P7"
                }
                {
                  name: "P8"
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
        $scope.chartViewModel = new flowchartDataModel.ChartViewModel(data)
        #console.log 'this is callback'
      topoAlgorithm.preProcess(raw, cb)
  # Code for the delete key.
    deleteKeyCode = 46
    deleteKeyCodeMac = 8
    # Code for control key.
    ctrlKeyCode = 17
    ctrlKeyCodeMac = 91
    # Set to true when the ctrl key is down.
    ctrlDown = false
    ADown = false
    # Code for A key.
    aKeyCode = 65
    # Code for esc key.
    escKeyCode = 27
    # Selects the next node id.
    nextNodeID = 0
    #initail node pos
    InitialNodeX = 50
    InitialNodeY = 50
    # Setup the data-model for the chart.
    $scope.print = () ->
      console.log $scope.chartViewModel.data
    # Event handler for key-down on the flowchart.
    preventDefaultAction = (evt) ->
      #stop event bubbles
      evt.stopPropagation()
      #stop native event from happening
      evt.preventDefault()
    $scope.keyDown = (evt) ->
      if (evt.keyCode is ctrlKeyCode) or (evt.keyCode is ctrlKeyCodeMac)
        preventDefaultAction(evt)
        ctrlDown = true
      if evt.keyCode is aKeyCode
        preventDefaultAction(evt)
        ADown = true
      if evt.keyCode is deleteKeyCodeMac
        preventDefaultAction(evt)
      # Ctrl + A
      if ADown and ctrlDown then $scope.chartViewModel.selectAll()
      if ctrlDown
        console.log 'control down'
        #MUTIPLY SELECTION
        #console.log $scope.chartViewModel
    # Event handler for key-up on the flowchart.
    $scope.keyUp = (evt) ->
      # Delete key.
      if (evt.keyCode is deleteKeyCode) or (evt.keyCode is deleteKeyCodeMac)
        $scope.chartViewModel.deleteSelected()
      # Escape.
      $scope.chartViewModel.deselectAll()  if evt.keyCode is escKeyCode
      if (evt.keyCode is ctrlKeyCode) or (evt.keyCode is ctrlKeyCodeMac)
        ctrlDown = false
      if evt.keyCode is aKeyCode
        ADown = false
    # Add a new node to the chart.

    $scope.addNewNode = ->
      InitialNodeX = InitialNodeX + 15
      InitialNodeY = InitialNodeY + 15
      $scope.mutinode = false
      # Template for a new node.
      $scope.targetNode =
        name: "New Node"
        id: nextNodeID++
        x: InitialNodeX
        y: InitialNodeY
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
      $scope.newValue = $scope.targetNode.name
      cb = () ->
        $scope.targetNode.name = $scope.newValue
        $scope.chartViewModel.addNode $scope.targetNode
      prompt("Enter a node name:", "New node", $scope, cb)
    # Add an input connector to selected nodes.
    $scope.addNewInputConnector = ->
      $scope.newValue = "New connector"
      selectedNodes = $scope.chartViewModel.getSelectedNodes()
      if selectedNodes.length > 1
        $scope.mutinode = true
        $scope.targetNodes = []
        for i in selectedNodes
          $scope.targetNodes.push i.data.name
      else
        $scope.targetNode = selectedNodes[0].data
      cb = () ->
        i = 0
        while i < selectedNodes.length
          node = selectedNodes[i]
          node.addInputConnector name: $scope.newValue
          ++i
        return
      prompt("Enter a connector name:", "", $scope, cb)
    # Add an output connector to selected nodes.
    $scope.addNewOutputConnector = ->
      $scope.newValue = "New connector"
      selectedNodes = $scope.chartViewModel.getSelectedNodes()
      if selectedNodes.length > 1
        $scope.mutinode = true
        $scope.targetNodes = []
        for i in selectedNodes
          $scope.targetNodes.push i.data.name
      else
        $scope.targetNode = selectedNodes[0].data
      cb = () ->
        i = 0
        while i < selectedNodes.length
          node = selectedNodes[i]
          node.addOutputConnector name: $scope.newValue
          ++i
        return
      prompt("Enter a connector name:", "", $scope, cb)
    # Delete selected nodes and connections.
    $scope.deleteSelected = ->
      $scope.chartViewModel.deleteSelected()
      return
    # Create the view-model for the chart and attach to the scope.
    #$scope.chartViewModel = new flowchartDataModel.ChartViewModel(chartDataModel)
]

ngapp.directive "ngRightClick", ($parse) ->
  (scope, element, attrs) ->
    fn = $parse(attrs.ngRightClick)
    element.bind "contextmenu", (event) ->
      scope.$apply ->
        event.preventDefault()
        fn scope,
          $event: event

ngapp.directive "machine", ->
  restrict: "E"
  templateUrl: "flowchart/machine.html"
  replace: true