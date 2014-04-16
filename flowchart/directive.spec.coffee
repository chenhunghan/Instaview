describe "flowchart-directive", ->
  testObject = undefined
  mockScope = undefined
  mockDragging = undefined
  mockSvgElement = undefined
  
  #
  # Bring in the flowChart module before each test.
  #
  beforeEach module("flowChart")
  
  #
  # Helper function to create the controller for each test.
  #
  createController = ($rootScope, $controller) ->
    mockScope = $rootScope.$new()
    mockDragging = createMockDragging()
    mockSvgElement = get: ->
      createMockSvgElement()

    testObject = $controller("FlowChartController",
      $scope: mockScope
      dragging: mockDragging
      $element: mockSvgElement
    )
    return

  
  #
  # Setup the controller before each test.
  #
  beforeEach inject(($rootScope, $controller) ->
    createController $rootScope, $controller
    return
  )
  
  # 
  # Create a mock DOM element.
  #
  createMockElement = (attr, parent, scope) ->
    attr: ->
      attr

    parent: ->
      parent

    scope: ->
      scope or {}

  
  #
  # Create a mock node data model.
  #
  createMockNode = (inputConnectors, outputConnectors) ->
    x: ->
      0

    y: ->
      0

    inputConnectors: inputConnectors or []
    outputConnectors: outputConnectors or []
    select: jasmine.createSpy()
    selected: ->
      false

  
  #
  # Create a mock chart.
  #
  createMockChart = (mockNodes, mockConnections) ->
    nodes: mockNodes
    connections: mockConnections
    handleNodeClicked: jasmine.createSpy()
    handleConnectionMouseDown: jasmine.createSpy()
    updateSelectedNodesLocation: jasmine.createSpy()
    deselectAll: jasmine.createSpy()
    createNewConnection: jasmine.createSpy()
    applySelectionRect: jasmine.createSpy()

  
  #
  # Create a mock dragging service.
  #
  createMockDragging = ->
    mockDragging = startDrag: (evt, config) ->
      mockDragging.evt = evt
      mockDragging.config = config
      return

    mockDragging

  
  #
  # Create a mock version of the SVG element.
  #
  createMockSvgElement = ->
    getScreenCTM: ->
      inverse: ->
        this

    createSVGPoint: ->
      x: 0
      y: 0
      matrixTransform: ->
        this

  it "searchUp returns null when at root 1", ->
    expect(testObject.searchUp(null, "some-class")).toBe null
    return

  it "searchUp returns null when at root 2", ->
    expect(testObject.searchUp([], "some-class")).toBe null
    return

  it "searchUp returns element when it has requested class", ->
    whichClass = "some-class"
    mockElement = createMockElement(whichClass)
    expect(testObject.searchUp(mockElement, whichClass)).toBe mockElement
    return

  it "searchUp returns parent when it has requested class", ->
    whichClass = "some-class"
    mockParent = createMockElement(whichClass)
    mockElement = createMockElement("", mockParent)
    expect(testObject.searchUp(mockElement, whichClass)).toBe mockParent
    return

  it "hitTest returns result of elementFromPoint", ->
    mockElement = {}
    
    # Mock out the document.
    testObject.document = elementFromPoint: ->
      mockElement

    expect(testObject.hitTest(12, 30)).toBe mockElement
    return

  it "checkForHit returns null when the hit element has no parent with requested class", ->
    mockElement = createMockElement(null, null)
    testObject.jQuery = (input) ->
      input

    expect(testObject.checkForHit(mockElement, "some-class")).toBe null
    return

  it "checkForHit returns the result of searchUp when found", ->
    mockConnectorScope = {}
    whichClass = "some-class"
    mockElement = createMockElement(whichClass, null, mockConnectorScope)
    testObject.jQuery = (input) ->
      input

    expect(testObject.checkForHit(mockElement, whichClass)).toBe mockConnectorScope
    return

  it "checkForHit returns null when searchUp fails", ->
    mockElement = createMockElement(null, null, null)
    testObject.jQuery = (input) ->
      input

    expect(testObject.checkForHit(mockElement, "some-class")).toBe null
    return

  it "test node dragging is started on node mouse down", ->
    mockDragging.startDrag = jasmine.createSpy()
    mockEvt = {}
    mockNode = createMockNode()
    mockScope.nodeMouseDown mockEvt, mockNode
    expect(mockDragging.startDrag).toHaveBeenCalled()
    return

  it "test node click handling is forwarded to view model", ->
    mockScope.chart = createMockChart([mockNode])
    mockEvt = ctrlKey: false
    mockNode = createMockNode()
    mockScope.nodeMouseDown mockEvt, mockNode
    mockDragging.config.clicked()
    expect(mockScope.chart.handleNodeClicked).toHaveBeenCalledWith mockNode, false
    return

  it "test control + node click handling is forwarded to view model", ->
    mockNode = createMockNode()
    mockScope.chart = createMockChart([mockNode])
    mockEvt = ctrlKey: true
    mockScope.nodeMouseDown mockEvt, mockNode
    mockDragging.config.clicked()
    expect(mockScope.chart.handleNodeClicked).toHaveBeenCalledWith mockNode, true
    return

  it "test node dragging updates selected nodes location", ->
    mockEvt = {}
    mockScope.chart = createMockChart([createMockNode()])
    mockScope.nodeMouseDown mockEvt, mockScope.chart.nodes[0]
    xIncrement = 5
    yIncrement = 15
    mockDragging.config.dragStarted 0, 0
    mockDragging.config.dragging xIncrement, yIncrement
    expect(mockScope.chart.updateSelectedNodesLocation).toHaveBeenCalledWith xIncrement, yIncrement
    return

  it "test node dragging doesnt modify selection when node is already selected", ->
    mockNode1 = createMockNode()
    mockNode2 = createMockNode()
    mockScope.chart = createMockChart([
      mockNode1
      mockNode2
    ])
    mockNode2.selected = ->
      true

    mockEvt = {}
    mockScope.nodeMouseDown mockEvt, mockNode2
    mockDragging.config.dragStarted 0, 0
    expect(mockScope.chart.deselectAll).not.toHaveBeenCalled()
    return

  it "test node dragging selects node, when the node is not already selected", ->
    mockNode1 = createMockNode()
    mockNode2 = createMockNode()
    mockScope.chart = createMockChart([
      mockNode1
      mockNode2
    ])
    mockEvt = {}
    mockScope.nodeMouseDown mockEvt, mockNode2
    mockDragging.config.dragStarted 0, 0
    expect(mockScope.chart.deselectAll).toHaveBeenCalled()
    expect(mockNode2.select).toHaveBeenCalled()
    return

  it "test connection click handling is forwarded to view model", ->
    mockNode = createMockNode()
    mockEvt =
      stopPropagation: jasmine.createSpy()
      preventDefault: jasmine.createSpy()
      ctrlKey: false

    mockConnection = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.connectionMouseDown mockEvt, mockConnection
    expect(mockScope.chart.handleConnectionMouseDown).toHaveBeenCalledWith mockConnection, false
    expect(mockEvt.stopPropagation).toHaveBeenCalled()
    expect(mockEvt.preventDefault).toHaveBeenCalled()
    return

  it "test control + connection click handling is forwarded to view model", ->
    mockNode = createMockNode()
    mockEvt =
      stopPropagation: jasmine.createSpy()
      preventDefault: jasmine.createSpy()
      ctrlKey: true

    mockConnection = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.connectionMouseDown mockEvt, mockConnection
    expect(mockScope.chart.handleConnectionMouseDown).toHaveBeenCalledWith mockConnection, true
    return

  it "test selection is cleared when background is clicked", ->
    mockEvt = {}
    mockScope.chart = createMockChart([createMockNode()])
    mockScope.chart.nodes[0].selected = true
    mockScope.mouseDown mockEvt
    expect(mockScope.chart.deselectAll).toHaveBeenCalled()
    return

  it "test background mouse down commences selection dragging", ->
    mockNode = createMockNode()
    mockConnector = {}
    mockEvt = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.mouseDown mockEvt
    mockDragging.config.dragStarted 0, 0
    expect(mockScope.dragSelecting).toBe true
    return

  it "test can end selection dragging", ->
    mockNode = createMockNode()
    mockConnector = {}
    mockEvt = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.mouseDown mockEvt
    mockDragging.config.dragStarted 0, 0, mockEvt
    mockDragging.config.dragging 0, 0, mockEvt
    mockDragging.config.dragEnded()
    expect(mockScope.dragSelecting).toBe false
    return

  it "test selection dragging ends by selecting nodes", ->
    mockNode = createMockNode()
    mockConnector = {}
    mockEvt = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.mouseDown mockEvt
    mockDragging.config.dragStarted 0, 0, mockEvt
    mockDragging.config.dragging 0, 0, mockEvt
    selectionRect =
      x: 1
      y: 2
      width: 3
      height: 4

    mockScope.dragSelectionRect = selectionRect
    mockDragging.config.dragEnded()
    expect(mockScope.chart.applySelectionRect).toHaveBeenCalledWith selectionRect
    return

  it "test mouse down commences connection dragging", ->
    mockNode = createMockNode()
    mockConnector = {}
    mockEvt = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.connectorMouseDown mockEvt, mockScope.chart.nodes[0], mockScope.chart.nodes[0].inputConnectors[0], 0, false
    mockDragging.config.dragStarted 0, 0
    expect(mockScope.draggingConnection).toBe true
    return

  it "test can end connection dragging", ->
    mockNode = createMockNode()
    mockConnector = {}
    mockEvt = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.connectorMouseDown mockEvt, mockScope.chart.nodes[0], mockScope.chart.nodes[0].inputConnectors[0], 0, false
    mockDragging.config.dragStarted 0, 0, mockEvt
    mockDragging.config.dragging 0, 0, mockEvt
    mockDragging.config.dragEnded()
    expect(mockScope.draggingConnection).toBe false
    return

  it "test can make a connection by dragging", ->
    mockNode = createMockNode()
    mockDraggingConnector = {}
    mockDragOverConnector = {}
    mockEvt = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.connectorMouseDown mockEvt, mockScope.chart.nodes[0], mockDraggingConnector, 0, false
    mockDragging.config.dragStarted 0, 0, mockEvt
    mockDragging.config.dragging 0, 0, mockEvt
    
    # Fake out the mouse over connector.
    mockScope.mouseOverConnector = mockDragOverConnector
    mockDragging.config.dragEnded()
    expect(mockScope.chart.createNewConnection).toHaveBeenCalledWith mockDraggingConnector, mockDragOverConnector
    return

  it "test connection creation by dragging is cancelled when dragged over invalid connector", ->
    mockNode = createMockNode()
    mockDraggingConnector = {}
    mockDragOverConnector = {}
    mockEvt = {}
    mockScope.chart = createMockChart([mockNode])
    mockScope.connectorMouseDown mockEvt, mockScope.chart.nodes[0], mockDraggingConnector, 0, false
    mockDragging.config.dragStarted 0, 0, mockEvt
    mockDragging.config.dragging 0, 0, mockEvt
    
    # Fake out the invalid connector.
    mockScope.mouseOverConnector = null
    mockDragging.config.dragEnded()
    expect(mockScope.chart.createNewConnection).not.toHaveBeenCalled()
    return

  it "mouse move over connection caches the connection", ->
    mockElement = {}
    mockConnection = {}
    mockConnectionScope = connection: mockConnection
    mockEvent = {}
    
    #
    # Fake out the function that check if a connection has been hit.
    #
    testObject.checkForHit = (element, whichClass) ->
      return mockConnectionScope  if whichClass is testObject.connectionClass
      null

    testObject.hitTest = ->
      mockElement

    mockScope.mouseMove mockEvent
    expect(mockScope.mouseOverConnection).toBe mockConnection
    return

  it "test mouse over connection clears mouse over connector and node", ->
    mockElement = {}
    mockConnection = {}
    mockConnectionScope = connection: mockConnection
    mockEvent = {}
    
    #
    # Fake out the function that check if a connection has been hit.
    #
    testObject.checkForHit = (element, whichClass) ->
      return mockConnectionScope  if whichClass is testObject.connectionClass
      null

    testObject.hitTest = ->
      mockElement

    mockScope.mouseOverConnector = {}
    mockScope.mouseOverNode = {}
    mockScope.mouseMove mockEvent
    expect(mockScope.mouseOverConnector).toBe null
    expect(mockScope.mouseOverNode).toBe null
    return

  it "test mouseMove handles mouse over connector", ->
    mockElement = {}
    mockConnector = {}
    mockConnectorScope = connector: mockConnector
    mockEvent = {}
    
    #
    # Fake out the function that check if a connector has been hit.
    #
    testObject.checkForHit = (element, whichClass) ->
      return mockConnectorScope  if whichClass is testObject.connectorClass
      null

    testObject.hitTest = ->
      mockElement

    mockScope.mouseMove mockEvent
    expect(mockScope.mouseOverConnector).toBe mockConnector
    return

  it "test mouseMove handles mouse over node", ->
    mockElement = {}
    mockNode = {}
    mockNodeScope = node: mockNode
    mockEvent = {}
    
    #
    # Fake out the function that check if a connector has been hit.
    #
    testObject.checkForHit = (element, whichClass) ->
      return mockNodeScope  if whichClass is testObject.nodeClass
      null

    testObject.hitTest = ->
      mockElement

    mockScope.mouseMove mockEvent
    expect(mockScope.mouseOverNode).toBe mockNode
    return

  return

