
#
# Define the 'app' module.
#

#
# Simple service to create a prompt.
#

# Uncomment the following to test that the prompt service is working as expected.
#	return function () {
#		return "Test!";
#	}
#	

# Return the browsers prompt function.

#
# Application controller.
#
angular.module("app", ["flowChart"]).factory("prompt", ->
  prompt
).controller "AppCtrl", [
  "$scope"
  "prompt"
  AppCtrl = ($scope, prompt) ->
    
    #
    # Code for the delete key.
    #
    deleteKeyCode = 46
    
    #
    # Code for control key.
    #
    ctrlKeyCode = 65
    
    #
    # Set to true when the ctrl key is down.
    #
    ctrlDown = false
    
    #
    # Code for A key.
    #
    aKeyCode = 17
    
    #
    # Code for esc key.
    #
    escKeyCode = 27
    
    #
    # Selects the next node id.
    #
    nextNodeID = 10
    
    #
    # Setup the data-model for the chart.
    #
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

    
    #
    # Event handler for key-down on the flowchart.
    #
    $scope.keyDown = (evt) ->
      if evt.keyCode is ctrlKeyCode
        ctrlDown = true
        evt.stopPropagation()
        evt.preventDefault()
      return

    
    #
    # Event handler for key-up on the flowchart.
    #
    $scope.keyUp = (evt) ->
      
      #
      # Delete key.
      #
      $scope.chartViewModel.deleteSelected()  if evt.keyCode is deleteKeyCode
      
      # 
      # Ctrl + A
      #
      $scope.chartViewModel.selectAll()  if evt.keyCode is aKeyCode and ctrlDown
      
      # Escape.
      $scope.chartViewModel.deselectAll()  if evt.keyCode is escKeyCode
      if evt.keyCode is ctrlKeyCode
        ctrlDown = false
        evt.stopPropagation()
        evt.preventDefault()
      return

    
    #
    # Add a new node to the chart.
    #
    $scope.addNewNode = ->
      nodeName = prompt("Enter a node name:", "New node")
      return  unless nodeName
      
      #
      # Template for a new node.
      #
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

    
    #
    # Add an input connector to selected nodes.
    #
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

    
    #
    # Add an output connector to selected nodes.
    #
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

    
    #
    # Delete selected nodes and connections.
    #
    $scope.deleteSelected = ->
      $scope.chartViewModel.deleteSelected()
      return

    
    #
    # Create the view-model for the chart and attach to the scope.
    #
    $scope.chartViewModel = new flowchart.ChartViewModel(chartDataModel)
]
#
# Debug utilities.
#
(->
  throw new Error("debug object already defined!")  if typeof debug isnt "undefined"
  debug = {}
  
  #
  # Assert that an object is valid.
  #
  debug.assertObjectValid = (obj) ->
    throw new Exception("Invalid object!")  unless obj
    throw new Error("Input is not an object! It is a " + typeof (obj))  if $.isPlainObject(obj)
    return

  return
)()
#
# Simple nodejs server for running the sample.
#
# http://stackoverflow.com/questions/6084360/node-js-as-a-simple-web-server
#
http = require("http")
url = require("url")
path = require("path")
fs = require("fs")
port = process.argv[2] or 8888
http.createServer((request, response) ->
  uri = url.parse(request.url).pathname
  filename = path.join(process.cwd(), uri)
  path.exists filename, (exists) ->
    unless exists
      response.writeHead 404,
        "Content-Type": "text/plain"

      response.write "404 Not Found\n"
      response.end()
      return
    filename += "/index.html"  if fs.statSync(filename).isDirectory()
    fs.readFile filename, "binary", (err, file) ->
      if err
        response.writeHead 500,
          "Content-Type": "text/plain"

        response.write err + "\n"
        response.end()
        return
      contentType = "text/plain"
      ext = path.extname(filename)
      switch ext
        when ".html"
          contentType = "text/html"
        when ".css"
          contentType = "text/css"
        when ".js"
          contentType = "text/javascript"
      console.log "Incoming ext: " + ext + ", content: " + contentType
      response.writeHead 200,
        "Content-Type": contentType

      response.write file, "binary"
      response.end()
      return

    return

  return
).listen parseInt(port, 10)
console.log "Static file server running at\n  => http://localhost:" + port + "/\nCTRL + C to shutdown"
