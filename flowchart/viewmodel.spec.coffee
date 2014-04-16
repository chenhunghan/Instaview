describe "flowchart-viewmodel", ->
  
  #
  # Create a mock data model from a simple definition.
  #
  createMockDataModel = (nodeIds, connections) ->
    nodeDataModels = null
    if nodeIds
      nodeDataModels = []
      i = 0

      while i < nodeIds.length
        nodeDataModels.push
          id: nodeIds[i]
          x: 0
          y: 0
          inputConnectors: [
            {
              {}
            }
            {
              {}
            }
            {
              {}
            }
          ]
          outputConnectors: [
            {
              {}
            }
            {
              {}
            }
            {
              {}
            }
          ]

        ++i
    connectionDataModels = null
    if connections
      connectionDataModels = []
      i = 0

      while i < connections.length
        connectionDataModels.push
          source:
            nodeID: connections[i][0][0]
            connectorIndex: connections[i][0][1]

          dest:
            nodeID: connections[i][1][0]
            connectorIndex: connections[i][1][1]

        ++i
    dataModel = {}
    dataModel.nodes = nodeDataModels  if nodeDataModels
    dataModel.connections = connectionDataModels  if connectionDataModels
    dataModel

  it "compute computeConnectorPos", ->
    mockNode =
      x: ->
        10

      y: ->
        15

    flowchart.computeConnectorPos mockNode, 0, true
    flowchart.computeConnectorPos mockNode, 1, true
    flowchart.computeConnectorPos mockNode, 2, true
    return

  it "construct ConnectorViewModel", ->
    mockDataModel = name: "Fooey"
    new flowchart.ConnectorViewModel(mockDataModel, 0, 10, 0)
    new flowchart.ConnectorViewModel(mockDataModel, 0, 10, 1)
    new flowchart.ConnectorViewModel(mockDataModel, 0, 10, 2)
    return

  it "ConnectorViewModel has reference to parent node", ->
    mockDataModel = name: "Fooey"
    mockParentNodeViewModel = {}
    testObject = new flowchart.ConnectorViewModel(mockDataModel, 0, 10, mockParentNodeViewModel)
    expect(testObject.parentNode()).toBe mockParentNodeViewModel
    return

  it "construct NodeViewModel with no connectors", ->
    mockDataModel =
      x: 10
      y: 12
      name: "Woot"

    new flowchart.NodeViewModel(mockDataModel)
    return

  it "construct NodeViewModel with empty connectors", ->
    mockDataModel =
      x: 10
      y: 12
      name: "Woot"
      inputConnectors: []
      outputConnectors: []

    new flowchart.NodeViewModel(mockDataModel)
    return

  it "construct NodeViewModel with connectors", ->
    mockInputConnector = name: "Input"
    mockOutputConnector = name: "Output"
    mockDataModel =
      x: 10
      y: 12
      name: "Woot"
      inputConnectors: [mockInputConnector]
      outputConnectors: [mockOutputConnector]

    new flowchart.NodeViewModel(mockDataModel)
    return

  it "test name of NodeViewModel", ->
    mockDataModel = name: "Woot"
    testObject = new flowchart.NodeViewModel(mockDataModel)
    expect(testObject.name()).toBe mockDataModel.name
    return

  it "test name of NodeViewModel defaults to empty string", ->
    mockDataModel = {}
    testObject = new flowchart.NodeViewModel(mockDataModel)
    expect(testObject.name()).toBe ""
    return

  it "test node is deselected by default", ->
    mockDataModel = {}
    testObject = new flowchart.NodeViewModel(mockDataModel)
    expect(testObject.selected()).toBe false
    return

  it "test node can be selected", ->
    mockDataModel = {}
    testObject = new flowchart.NodeViewModel(mockDataModel)
    testObject.select()
    expect(testObject.selected()).toBe true
    return

  it "test node can be deselected", ->
    mockDataModel = {}
    testObject = new flowchart.NodeViewModel(mockDataModel)
    testObject.select()
    testObject.deselect()
    expect(testObject.selected()).toBe false
    return

  it "test node can be selection can be toggled", ->
    mockDataModel = {}
    testObject = new flowchart.NodeViewModel(mockDataModel)
    testObject.toggleSelected()
    expect(testObject.selected()).toBe true
    testObject.toggleSelected()
    expect(testObject.selected()).toBe false
    return

  it "test can add input connector to node", ->
    mockDataModel = {}
    testObject = new flowchart.NodeViewModel(mockDataModel)
    name1 = "Connector1"
    name2 = "Connector2"
    data1 = name: name1
    data2 = name: name2
    testObject.addInputConnector data1
    testObject.addInputConnector data2
    expect(testObject.inputConnectors.length).toBe 2
    expect(testObject.inputConnectors[0].data).toBe data1
    expect(testObject.inputConnectors[1].data).toBe data2
    expect(testObject.data.inputConnectors.length).toBe 2
    expect(testObject.data.inputConnectors[0]).toBe data1
    expect(testObject.data.inputConnectors[1]).toBe data2
    return

  it "test can add output connector to node", ->
    mockDataModel = {}
    testObject = new flowchart.NodeViewModel(mockDataModel)
    name1 = "Connector1"
    name2 = "Connector2"
    data1 = name: name1
    data2 = name: name2
    testObject.addOutputConnector data1
    testObject.addOutputConnector data2
    expect(testObject.outputConnectors.length).toBe 2
    expect(testObject.outputConnectors[0].data).toBe data1
    expect(testObject.outputConnectors[1].data).toBe data2
    expect(testObject.data.outputConnectors.length).toBe 2
    expect(testObject.data.outputConnectors[0]).toBe data1
    expect(testObject.data.outputConnectors[1]).toBe data2
    return

  it "construct ChartViewModel with no nodes or connections", ->
    mockDataModel = {}
    new flowchart.ChartViewModel(mockDataModel)
    return

  it "construct ChartViewModel with empty nodes and connections", ->
    mockDataModel =
      nodes: []
      connections: []

    new flowchart.ChartViewModel(mockDataModel)
    return

  it "construct ConnectionViewModel", ->
    mockDataModel = {}
    mockSourceConnector = {}
    mockDestConnector = {}
    new flowchart.ConnectionViewModel(mockDataModel, mockSourceConnector, mockDestConnector)
    return

  it "retreive source and dest coordinates", ->
    mockDataModel = {}
    mockSourceParentNode =
      x: ->
        5

      y: ->
        10

    mockSourceConnector =
      parentNode: ->
        mockSourceParentNode

      x: ->
        5

      y: ->
        15

    mockDestParentNode =
      x: ->
        50

      y: ->
        30

    mockDestConnector =
      parentNode: ->
        mockDestParentNode

      x: ->
        25

      y: ->
        35

    testObject = new flowchart.ConnectionViewModel(mockDataModel, mockSourceConnector, mockDestConnector)
    testObject.sourceCoord()
    expect(testObject.sourceCoordX()).toBe 10
    expect(testObject.sourceCoordY()).toBe 25
    testObject.sourceTangentX()
    testObject.sourceTangentY()
    testObject.destCoord()
    expect(testObject.destCoordX()).toBe 75
    expect(testObject.destCoordY()).toBe 65
    testObject.destTangentX()
    testObject.destTangentY()
    return

  it "test connection is deselected by default", ->
    mockDataModel = {}
    testObject = new flowchart.ConnectionViewModel(mockDataModel)
    expect(testObject.selected()).toBe false
    return

  it "test connection can be selected", ->
    mockDataModel = {}
    testObject = new flowchart.ConnectionViewModel(mockDataModel)
    testObject.select()
    expect(testObject.selected()).toBe true
    return

  it "test connection can be deselected", ->
    mockDataModel = {}
    testObject = new flowchart.ConnectionViewModel(mockDataModel)
    testObject.select()
    testObject.deselect()
    expect(testObject.selected()).toBe false
    return

  it "test connection can be selection can be toggled", ->
    mockDataModel = {}
    testObject = new flowchart.ConnectionViewModel(mockDataModel)
    testObject.toggleSelected()
    expect(testObject.selected()).toBe true
    testObject.toggleSelected()
    expect(testObject.selected()).toBe false
    return

  it "construct ChartViewModel with a node", ->
    mockDataModel = createMockDataModel([1])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.nodes.length).toBe 1
    expect(testObject.nodes[0].data).toBe mockDataModel.nodes[0]
    return

  it "data model with existing connection creates a connection view model", ->
    mockDataModel = createMockDataModel([
      5
      12
    ], [[
      [
        5
        0
      ]
      [
        12
        1
      ]
    ]])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.connections.length).toBe 1
    expect(testObject.connections[0].data).toBe mockDataModel.connections[0]
    expect(testObject.connections[0].source.data).toBe mockDataModel.nodes[0].outputConnectors[0]
    expect(testObject.connections[0].dest.data).toBe mockDataModel.nodes[1].inputConnectors[1]
    return

  it "test can add new node", ->
    mockDataModel = createMockDataModel()
    testObject = new flowchart.ChartViewModel(mockDataModel)
    nodeDataModel = {}
    testObject.addNode nodeDataModel
    expect(testObject.nodes.length).toBe 1
    expect(testObject.nodes[0].data).toBe nodeDataModel
    expect(testObject.data.nodes.length).toBe 1
    expect(testObject.data.nodes[0]).toBe nodeDataModel
    return

  it "test can select all", ->
    mockDataModel = createMockDataModel([
      1
      2
    ], [[
      [
        1
        0
      ]
      [
        2
        1
      ]
    ]])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node1 = testObject.nodes[0]
    node2 = testObject.nodes[1]
    connection = testObject.connections[0]
    testObject.selectAll()
    expect(node1.selected()).toBe true
    expect(node2.selected()).toBe true
    expect(connection.selected()).toBe true
    return

  it "test can deselect all nodes", ->
    mockDataModel = createMockDataModel([
      1
      2
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node1 = testObject.nodes[0]
    node2 = testObject.nodes[1]
    node1.select()
    node2.select()
    testObject.deselectAll()
    expect(node1.selected()).toBe false
    expect(node2.selected()).toBe false
    return

  it "test can deselect all connections", ->
    mockDataModel = createMockDataModel([
      5
      12
    ], [
      [
        [
          5
          0
        ]
        [
          12
          1
        ]
      ]
      [
        [
          5
          0
        ]
        [
          12
          1
        ]
      ]
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    connection1 = testObject.connections[0]
    connection2 = testObject.connections[1]
    connection1.select()
    connection2.select()
    testObject.deselectAll()
    expect(connection1.selected()).toBe false
    expect(connection2.selected()).toBe false
    return

  it "test mouse down deselects nodes other than the one clicked", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node1 = testObject.nodes[0]
    node2 = testObject.nodes[1]
    node3 = testObject.nodes[2]
    
    # Fake out the nodes as selected.
    node1.select()
    node2.select()
    node3.select()
    testObject.handleNodeClicked node2 # Doesn't matter which node is actually clicked.
    expect(node1.selected()).toBe false
    expect(node2.selected()).toBe true
    expect(node3.selected()).toBe false
    return

  it "test mouse down selects the clicked node", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node1 = testObject.nodes[0]
    node2 = testObject.nodes[1]
    node3 = testObject.nodes[2]
    testObject.handleNodeClicked node3 # Doesn't matter which node is actually clicked.
    expect(node1.selected()).toBe false
    expect(node2.selected()).toBe false
    expect(node3.selected()).toBe true
    return

  it "test mouse down brings node to front", ->
    mockDataModel = createMockDataModel([
      1
      2
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node1 = testObject.nodes[0]
    node2 = testObject.nodes[1]
    testObject.handleNodeClicked node1
    expect(testObject.nodes[0]).toBe node2 # Mock node 2 should be bought to front.
    expect(testObject.nodes[1]).toBe node1
    return

  it "test control + mouse down toggles node selection", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node1 = testObject.nodes[0]
    node2 = testObject.nodes[1]
    node3 = testObject.nodes[2]
    node1.select() # Mark node 1 as already selected.
    testObject.handleNodeClicked node2, true
    expect(node1.selected()).toBe true # This node remains selected.
    expect(node2.selected()).toBe true # This node is being toggled.
    expect(node3.selected()).toBe false # This node remains unselected.
    testObject.handleNodeClicked node2, true
    expect(node1.selected()).toBe true # This node remains selected.
    expect(node2.selected()).toBe false # This node is being toggled.
    expect(node3.selected()).toBe false # This node remains unselected.
    testObject.handleNodeClicked node2, true
    expect(node1.selected()).toBe true # This node remains selected.
    expect(node2.selected()).toBe true # This node is being toggled.
    expect(node3.selected()).toBe false # This node remains unselected.
    return

  it "test mouse down deselects connections other than the one clicked", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ], [
      [
        [
          1
          0
        ]
        [
          3
          0
        ]
      ]
      [
        [
          2
          1
        ]
        [
          3
          2
        ]
      ]
      [
        [
          1
          2
        ]
        [
          3
          0
        ]
      ]
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    connection1 = testObject.connections[0]
    connection2 = testObject.connections[1]
    connection3 = testObject.connections[2]
    
    # Fake out the connections as selected.
    connection1.select()
    connection2.select()
    connection3.select()
    testObject.handleConnectionMouseDown connection2
    expect(connection1.selected()).toBe false
    expect(connection2.selected()).toBe true
    expect(connection3.selected()).toBe false
    return

  it "test node mouse down selects the clicked connection", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ], [
      [
        [
          1
          0
        ]
        [
          3
          0
        ]
      ]
      [
        [
          2
          1
        ]
        [
          3
          2
        ]
      ]
      [
        [
          1
          2
        ]
        [
          3
          0
        ]
      ]
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    connection1 = testObject.connections[0]
    connection2 = testObject.connections[1]
    connection3 = testObject.connections[2]
    testObject.handleConnectionMouseDown connection3
    expect(connection1.selected()).toBe false
    expect(connection2.selected()).toBe false
    expect(connection3.selected()).toBe true
    return

  it "test control + mouse down toggles connection selection", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ], [
      [
        [
          1
          0
        ]
        [
          3
          0
        ]
      ]
      [
        [
          2
          1
        ]
        [
          3
          2
        ]
      ]
      [
        [
          1
          2
        ]
        [
          3
          0
        ]
      ]
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    connection1 = testObject.connections[0]
    connection2 = testObject.connections[1]
    connection3 = testObject.connections[2]
    connection1.select() # Mark connection 1 as already selected.
    testObject.handleConnectionMouseDown connection2, true
    expect(connection1.selected()).toBe true # This connection remains selected.
    expect(connection2.selected()).toBe true # This connection is being toggle.
    expect(connection3.selected()).toBe false # This connection remains unselected.
    testObject.handleConnectionMouseDown connection2, true
    expect(connection1.selected()).toBe true # This connection remains selected.
    expect(connection2.selected()).toBe false # This connection is being toggle.
    expect(connection3.selected()).toBe false # This connection remains unselected.
    testObject.handleConnectionMouseDown connection2, true
    expect(connection1.selected()).toBe true # This connection remains selected.
    expect(connection2.selected()).toBe true # This connection is being toggle.
    expect(connection3.selected()).toBe false # This connection remains unselected.
    return

  it "test data-model is wrapped in view-model", ->
    mockDataModel = createMockDataModel([
      1
      2
    ], [[
      [
        1
        0
      ]
      [
        2
        0
      ]
    ]])
    mockNode = mockDataModel.nodes[0]
    mockInputConnector = mockNode.inputConnectors[0]
    mockOutputConnector = mockNode.outputConnectors[0]
    testObject = new flowchart.ChartViewModel(mockDataModel)
    
    # Chart
    expect(testObject).toBeDefined()
    expect(testObject).toNotBe mockDataModel
    expect(testObject.data).toBe mockDataModel
    expect(testObject.nodes).toBeDefined()
    expect(testObject.nodes.length).toBe 2
    
    # Node
    node = testObject.nodes[0]
    expect(node).toNotBe mockNode
    expect(node.data).toBe mockNode
    
    # Connectors
    expect(node.inputConnectors.length).toBe 3
    expect(node.inputConnectors[0].data).toBe mockInputConnector
    expect(node.outputConnectors.length).toBe 3
    expect(node.outputConnectors[0].data).toBe mockOutputConnector
    
    # Connection
    expect(testObject.connections.length).toBe 1
    expect(testObject.connections[0].source).toBe testObject.nodes[0].outputConnectors[0]
    expect(testObject.connections[0].dest).toBe testObject.nodes[1].inputConnectors[0]
    return

  it "test can delete 1st selected node", ->
    mockDataModel = createMockDataModel([
      1
      2
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.nodes.length).toBe 2
    testObject.nodes[0].select()
    mockNode2 = mockDataModel.nodes[1]
    testObject.deleteSelected()
    expect(testObject.nodes.length).toBe 1
    expect(mockDataModel.nodes.length).toBe 1
    expect(testObject.nodes[0].data).toBe mockNode2
    return

  it "test can delete 2nd selected nodes", ->
    mockDataModel = createMockDataModel([
      1
      2
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.nodes.length).toBe 2
    testObject.nodes[1].select()
    mockNode1 = mockDataModel.nodes[0]
    testObject.deleteSelected()
    expect(testObject.nodes.length).toBe 1
    expect(mockDataModel.nodes.length).toBe 1
    expect(testObject.nodes[0].data).toBe mockNode1
    return

  it "test can delete multiple selected nodes", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
      4
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.nodes.length).toBe 4
    testObject.nodes[1].select()
    testObject.nodes[2].select()
    mockNode1 = mockDataModel.nodes[0]
    mockNode4 = mockDataModel.nodes[3]
    testObject.deleteSelected()
    expect(testObject.nodes.length).toBe 2
    expect(mockDataModel.nodes.length).toBe 2
    expect(testObject.nodes[0].data).toBe mockNode1
    expect(testObject.nodes[1].data).toBe mockNode4
    return

  it "deleting a node also deletes its connections", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ], [
      [
        [
          1
          0
        ]
        [
          2
          0
        ]
      ]
      [
        [
          2
          0
        ]
        [
          3
          0
        ]
      ]
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.connections.length).toBe 2
    
    # Select the middle node.
    testObject.nodes[1].select()
    testObject.deleteSelected()
    expect(testObject.connections.length).toBe 0
    return

  it "deleting a node doesnt delete other connections", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ], [[
      [
        1
        0
      ]
      [
        3
        0
      ]
    ]])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.connections.length).toBe 1
    
    # Select the middle node.
    testObject.nodes[1].select()
    testObject.deleteSelected()
    expect(testObject.connections.length).toBe 1
    return

  it "test can delete 1st selected connection", ->
    mockDataModel = createMockDataModel([
      1
      2
    ], [
      [
        [
          1
          0
        ]
        [
          2
          0
        ]
      ]
      [
        [
          2
          1
        ]
        [
          1
          2
        ]
      ]
    ])
    mockRemainingConnectionDataModel = mockDataModel.connections[1]
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.connections.length).toBe 2
    testObject.connections[0].select()
    testObject.deleteSelected()
    expect(testObject.connections.length).toBe 1
    expect(mockDataModel.connections.length).toBe 1
    expect(testObject.connections[0].data).toBe mockRemainingConnectionDataModel
    return

  it "test can delete 2nd selected connection", ->
    mockDataModel = createMockDataModel([
      1
      2
    ], [
      [
        [
          1
          0
        ]
        [
          2
          0
        ]
      ]
      [
        [
          2
          1
        ]
        [
          1
          2
        ]
      ]
    ])
    mockRemainingConnectionDataModel = mockDataModel.connections[0]
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.connections.length).toBe 2
    testObject.connections[1].select()
    testObject.deleteSelected()
    expect(testObject.connections.length).toBe 1
    expect(mockDataModel.connections.length).toBe 1
    expect(testObject.connections[0].data).toBe mockRemainingConnectionDataModel
    return

  it "test can delete multiple selected connections", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ], [
      [
        [
          1
          0
        ]
        [
          2
          0
        ]
      ]
      [
        [
          2
          1
        ]
        [
          1
          2
        ]
      ]
      [
        [
          1
          1
        ]
        [
          3
          0
        ]
      ]
      [
        [
          3
          2
        ]
        [
          2
          1
        ]
      ]
    ])
    mockRemainingConnectionDataModel1 = mockDataModel.connections[0]
    mockRemainingConnectionDataModel2 = mockDataModel.connections[3]
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.connections.length).toBe 4
    testObject.connections[1].select()
    testObject.connections[2].select()
    testObject.deleteSelected()
    expect(testObject.connections.length).toBe 2
    expect(mockDataModel.connections.length).toBe 2
    expect(testObject.connections[0].data).toBe mockRemainingConnectionDataModel1
    expect(testObject.connections[1].data).toBe mockRemainingConnectionDataModel2
    return

  it "can select nodes via selection rect", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ])
    mockDataModel.nodes[0].x = 0
    mockDataModel.nodes[0].y = 0
    mockDataModel.nodes[1].x = 1020
    mockDataModel.nodes[1].y = 1020
    mockDataModel.nodes[2].x = 3000
    mockDataModel.nodes[2].y = 3000
    testObject = new flowchart.ChartViewModel(mockDataModel)
    testObject.nodes[0].select() # Select a nodes, to ensure it is correctly deselected.
    testObject.applySelectionRect
      x: 1000
      y: 1000
      width: 1000
      height: 1000

    expect(testObject.nodes[0].selected()).toBe false
    expect(testObject.nodes[1].selected()).toBe true
    expect(testObject.nodes[2].selected()).toBe false
    return

  it "can select connections via selection rect", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
      4
    ], [
      [
        [
          1
          0
        ]
        [
          2
          0
        ]
      ]
      [
        [
          2
          1
        ]
        [
          3
          2
        ]
      ]
      [
        [
          3
          2
        ]
        [
          4
          1
        ]
      ]
    ])
    mockDataModel.nodes[0].x = 0
    mockDataModel.nodes[0].y = 0
    mockDataModel.nodes[1].x = 1020
    mockDataModel.nodes[1].y = 1020
    mockDataModel.nodes[2].x = 1500
    mockDataModel.nodes[2].y = 1500
    mockDataModel.nodes[3].x = 3000
    mockDataModel.nodes[3].y = 3000
    testObject = new flowchart.ChartViewModel(mockDataModel)
    testObject.connections[0].select() # Select a connection, to ensure it is correctly deselected.
    testObject.applySelectionRect
      x: 1000
      y: 1000
      width: 1000
      height: 1000

    expect(testObject.connections[0].selected()).toBe false
    expect(testObject.connections[1].selected()).toBe true
    expect(testObject.connections[2].selected()).toBe false
    return

  it "test update selected nodes location", ->
    mockDataModel = createMockDataModel([1])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node = testObject.nodes[0]
    node.select()
    xInc = 5
    yInc = 15
    testObject.updateSelectedNodesLocation xInc, yInc
    expect(node.x()).toBe xInc
    expect(node.y()).toBe yInc
    return

  it "test update selected nodes location, ignores unselected nodes", ->
    mockDataModel = createMockDataModel([1])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node = testObject.nodes[0]
    xInc = 5
    yInc = 15
    testObject.updateSelectedNodesLocation xInc, yInc
    expect(node.x()).toBe 0
    expect(node.y()).toBe 0
    return

  it "test find node throws when there are no nodes", ->
    mockDataModel = createMockDataModel()
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findNode 150
      return
    ).toThrow()
    return

  it "test find node throws when node is not found", ->
    mockDataModel = createMockDataModel([
      5
      25
      15
      30
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findNode 150
      return
    ).toThrow()
    return

  it "test find node retreives correct node", ->
    mockDataModel = createMockDataModel([
      5
      25
      15
      30
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.findNode(15)).toBe testObject.nodes[2]
    return

  it "test find input connector throws when there are no nodes", ->
    mockDataModel = createMockDataModel()
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findInputConnector 150, 1
      return
    ).toThrow()
    return

  it "test find input connector throws when the node is not found", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findInputConnector 150, 1
      return
    ).toThrow()
    return

  it "test find input connector throws when there are no connectors", ->
    mockDataModel = createMockDataModel([1])
    mockDataModel.nodes[0].inputConnectors = []
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findInputConnector 1, 1
      return
    ).toThrow()
    return

  it "test find input connector throws when connector is not found", ->
    mockDataModel = createMockDataModel([5])
    mockDataModel.nodes[0].inputConnectors = [{}] # Only 1 input connector.
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findInputConnector 5, 1
      return
    ).toThrow()
    return

  it "test find input connector retreives correct connector", ->
    mockDataModel = createMockDataModel([
      5
      25
      15
      30
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.findInputConnector(15, 1)).toBe testObject.nodes[2].inputConnectors[1]
    return

  it "test find output connector throws when there are no nodes", ->
    mockDataModel = createMockDataModel()
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findOutputConnector 150, 1
      return
    ).toThrow()
    return

  it "test find output connector throws when the node is not found", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findOutputConnector 150, 1
      return
    ).toThrow()
    return

  it "test find output connector throws when there are no connectors", ->
    mockDataModel = createMockDataModel([1])
    mockDataModel.nodes[0].outputConnectors = []
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findOutputConnector 1, 1
      return
    ).toThrow()
    return

  it "test find output connector throws when connector is not found", ->
    mockDataModel = createMockDataModel([5])
    mockDataModel.nodes[0].outputConnectors = [{}] # Only 1 input connector.
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(->
      testObject.findOutputConnector 5, 1
      return
    ).toThrow()
    return

  it "test find output connector retreives correct connector", ->
    mockDataModel = createMockDataModel([
      5
      25
      15
      30
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    expect(testObject.findOutputConnector(15, 1)).toBe testObject.nodes[2].outputConnectors[1]
    return

  it "test create new connection", ->
    mockDataModel = createMockDataModel([
      5
      25
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    sourceConnector = testObject.nodes[0].outputConnectors[0]
    destConnector = testObject.nodes[1].inputConnectors[1]
    testObject.createNewConnection sourceConnector, destConnector
    expect(testObject.connections.length).toBe 1
    connection = testObject.connections[0]
    expect(connection.source).toBe sourceConnector
    expect(connection.dest).toBe destConnector
    expect(testObject.data.connections.length).toBe 1
    connectionData = testObject.data.connections[0]
    expect(connection.data).toBe connectionData
    expect(connectionData.source.nodeID).toBe 5
    expect(connectionData.source.connectorIndex).toBe 0
    expect(connectionData.dest.nodeID).toBe 25
    expect(connectionData.dest.connectorIndex).toBe 1
    return

  it "test get selected nodes results in empty array when there are no nodes", ->
    mockDataModel = createMockDataModel()
    testObject = new flowchart.ChartViewModel(mockDataModel)
    selectedNodes = testObject.getSelectedNodes()
    expect(selectedNodes.length).toBe 0
    return

  it "test get selected nodes results in empty array when none selected", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
      4
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    selectedNodes = testObject.getSelectedNodes()
    expect(selectedNodes.length).toBe 0
    return

  it "test can get selected nodes", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
      4
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    node1 = testObject.nodes[0]
    node2 = testObject.nodes[1]
    node3 = testObject.nodes[2]
    node4 = testObject.nodes[3]
    node2.select()
    node3.select()
    selectedNodes = testObject.getSelectedNodes()
    expect(selectedNodes.length).toBe 2
    expect(selectedNodes[0]).toBe node2
    expect(selectedNodes[1]).toBe node3
    return

  it "test can get selected connections", ->
    mockDataModel = createMockDataModel([
      1
      2
      3
    ], [
      [
        [
          1
          0
        ]
        [
          2
          0
        ]
      ]
      [
        [
          2
          1
        ]
        [
          1
          2
        ]
      ]
      [
        [
          1
          1
        ]
        [
          3
          0
        ]
      ]
      [
        [
          3
          2
        ]
        [
          2
          1
        ]
      ]
    ])
    testObject = new flowchart.ChartViewModel(mockDataModel)
    connection1 = testObject.connections[0]
    connection2 = testObject.connections[1]
    connection3 = testObject.connections[2]
    connection4 = testObject.connections[3]
    connection2.select()
    connection3.select()
    selectedConnections = testObject.getSelectedConnections()
    expect(selectedConnections.length).toBe 2
    expect(selectedConnections[0]).toBe connection2
    expect(selectedConnections[1]).toBe connection3
    return

  return

