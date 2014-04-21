// Generated by CoffeeScript 1.6.3
(function() {
  var AppCtrl, debug, ngapp;

  if (typeof debug !== "undefined") {
    throw new Error("debug object already defined!");
  }

  debug = {};

  debug.assertObjectValid = function(obj) {
    if (!obj) {
      throw new Exception("Invalid object!");
    }
    if ($.isPlainObject(obj)) {
      throw new Error("Input is not an object! It is a " + typeof obj);
    }
  };

  ngapp = angular.module("app", ["flowChart"]);

  ngapp.service("flowchartDataModel", function() {
    var computeConnectionTangentOffset, createConnectorsViewModel, createNodesViewModel, flowchart;
    flowchart = this;
    flowchart.nodeWidth = 250;
    flowchart.nodeNameHeight = 40;
    flowchart.connectorHeight = 35;
    flowchart.computeConnectorY = function(connectorIndex) {
      return flowchart.nodeNameHeight + (connectorIndex * flowchart.connectorHeight);
    };
    flowchart.computeConnectorPos = function(node, connectorIndex, inputConnector) {
      return {
        x: node.x() + (inputConnector ? 0 : flowchart.nodeWidth),
        y: node.y() + flowchart.computeConnectorY(connectorIndex)
      };
    };
    flowchart.ConnectorViewModel = function(connectorDataModel, x, y, parentNode) {
      this.data = connectorDataModel;
      this._parentNode = parentNode;
      this._x = x;
      this._y = y;
      this.name = function() {
        return this.data.name;
      };
      this.x = function() {
        return this._x;
      };
      this.y = function() {
        return this._y;
      };
      this.parentNode = function() {
        return this._parentNode;
      };
    };
    createConnectorsViewModel = function(connectorDataModels, x, parentNode) {
      var connectorViewModel, i, viewModels;
      viewModels = [];
      if (connectorDataModels) {
        i = 0;
        while (i < connectorDataModels.length) {
          connectorViewModel = new flowchart.ConnectorViewModel(connectorDataModels[i], x, flowchart.computeConnectorY(i), parentNode);
          viewModels.push(connectorViewModel);
          ++i;
        }
      }
      return viewModels;
    };
    flowchart.NodeViewModel = function(nodeDataModel) {
      this.data = nodeDataModel;
      this.inputConnectors = createConnectorsViewModel(this.data.inputConnectors, 0, this);
      this.outputConnectors = createConnectorsViewModel(this.data.outputConnectors, flowchart.nodeWidth, this);
      this._selected = false;
      this.name = function() {
        return this.data.name || "";
      };
      this.x = function() {
        return this.data.x;
      };
      this.y = function() {
        return this.data.y;
      };
      this.width = function() {
        return flowchart.nodeWidth;
      };
      this.height = function() {
        var numConnectors;
        numConnectors = Math.max(this.inputConnectors.length, this.outputConnectors.length);
        return flowchart.computeConnectorY(numConnectors);
      };
      this.select = function() {
        this._selected = true;
      };
      this.deselect = function() {
        this._selected = false;
      };
      this.toggleSelected = function() {
        this._selected = !this._selected;
      };
      this.selected = function() {
        return this._selected;
      };
      this._addConnector = function(connectorDataModel, x, connectorsDataModel, connectorsViewModel) {
        var connectorViewModel;
        connectorViewModel = new flowchart.ConnectorViewModel(connectorDataModel, x, flowchart.computeConnectorY(connectorsViewModel.length), this);
        connectorsDataModel.push(connectorDataModel);
        connectorsViewModel.push(connectorViewModel);
      };
      this.addInputConnector = function(connectorDataModel) {
        if (!this.data.inputConnectors) {
          this.data.inputConnectors = [];
        }
        this._addConnector(connectorDataModel, 0, this.data.inputConnectors, this.inputConnectors);
      };
      this.addOutputConnector = function(connectorDataModel) {
        if (!this.data.outputConnectors) {
          this.data.outputConnectors = [];
        }
        this._addConnector(connectorDataModel, flowchart.nodeWidth, this.data.outputConnectors, this.outputConnectors);
      };
    };
    createNodesViewModel = function(nodesDataModel) {
      var i, nodesViewModel;
      nodesViewModel = [];
      if (nodesDataModel) {
        i = 0;
        while (i < nodesDataModel.length) {
          nodesViewModel.push(new flowchart.NodeViewModel(nodesDataModel[i]));
          ++i;
        }
      }
      return nodesViewModel;
    };
    flowchart.ConnectionViewModel = function(connectionDataModel, sourceConnector, destConnector) {
      this.data = connectionDataModel;
      this.source = sourceConnector;
      this.dest = destConnector;
      this._selected = false;
      this.sourceCoordX = function() {
        return this.source.parentNode().x() + this.source.x();
      };
      this.sourceCoordY = function() {
        return this.source.parentNode().y() + this.source.y();
      };
      this.sourceCoord = function() {
        return {
          x: this.sourceCoordX(),
          y: this.sourceCoordY()
        };
      };
      this.sourceTangentX = function() {
        return flowchart.computeConnectionSourceTangentX(this.sourceCoord(), this.destCoord());
      };
      this.sourceTangentY = function() {
        return flowchart.computeConnectionSourceTangentY(this.sourceCoord(), this.destCoord());
      };
      this.destCoordX = function() {
        return this.dest.parentNode().x() + this.dest.x();
      };
      this.destCoordY = function() {
        return this.dest.parentNode().y() + this.dest.y();
      };
      this.destCoord = function() {
        return {
          x: this.destCoordX(),
          y: this.destCoordY()
        };
      };
      this.destTangentX = function() {
        return flowchart.computeConnectionDestTangentX(this.sourceCoord(), this.destCoord());
      };
      this.destTangentY = function() {
        return flowchart.computeConnectionDestTangentY(this.sourceCoord(), this.destCoord());
      };
      this.select = function() {
        this._selected = true;
      };
      this.deselect = function() {
        this._selected = false;
      };
      this.toggleSelected = function() {
        this._selected = !this._selected;
      };
      this.selected = function() {
        return this._selected;
      };
    };
    computeConnectionTangentOffset = function(pt1, pt2) {
      return (pt2.x - pt1.x) / 2;
    };
    flowchart.computeConnectionSourceTangentX = function(pt1, pt2) {
      return pt1.x + computeConnectionTangentOffset(pt1, pt2);
    };
    flowchart.computeConnectionSourceTangentY = function(pt1, pt2) {
      return pt1.y;
    };
    flowchart.computeConnectionSourceTangent = function(pt1, pt2) {
      return {
        x: flowchart.computeConnectionSourceTangentX(pt1, pt2),
        y: flowchart.computeConnectionSourceTangentY(pt1, pt2)
      };
    };
    flowchart.computeConnectionDestTangentX = function(pt1, pt2) {
      return pt2.x - computeConnectionTangentOffset(pt1, pt2);
    };
    flowchart.computeConnectionDestTangentY = function(pt1, pt2) {
      return pt2.y;
    };
    flowchart.computeConnectionDestTangent = function(pt1, pt2) {
      return {
        x: flowchart.computeConnectionDestTangentX(pt1, pt2),
        y: flowchart.computeConnectionDestTangentY(pt1, pt2)
      };
    };
    flowchart.ChartViewModel = function(chartDataModel) {
      this.findNode = function(nodeID) {
        var i, node;
        i = 0;
        while (i < this.nodes.length) {
          node = this.nodes[i];
          if (node.data.id === nodeID) {
            return node;
          }
          ++i;
        }
        throw new Error("Failed to find node " + nodeID);
      };
      this.findInputConnector = function(nodeID, connectorIndex) {
        var node;
        node = this.findNode(nodeID);
        if (!node.inputConnectors || node.inputConnectors.length <= connectorIndex) {
          throw new Error("Node " + nodeID + " has invalid input connectors.");
        }
        return node.inputConnectors[connectorIndex];
      };
      this.findOutputConnector = function(nodeID, connectorIndex) {
        var node;
        node = this.findNode(nodeID);
        if (!node.outputConnectors || node.outputConnectors.length <= connectorIndex) {
          throw new Error("Node " + nodeID + " has invalid output connectors.");
        }
        return node.outputConnectors[connectorIndex];
      };
      this._createConnectionViewModel = function(connectionDataModel) {
        var destConnector, sourceConnector;
        sourceConnector = this.findOutputConnector(connectionDataModel.source.nodeID, connectionDataModel.source.connectorIndex);
        destConnector = this.findInputConnector(connectionDataModel.dest.nodeID, connectionDataModel.dest.connectorIndex);
        return new flowchart.ConnectionViewModel(connectionDataModel, sourceConnector, destConnector);
      };
      this._createConnectionsViewModel = function(connectionsDataModel) {
        var connectionsViewModel, i;
        connectionsViewModel = [];
        if (connectionsDataModel) {
          i = 0;
          while (i < connectionsDataModel.length) {
            connectionsViewModel.push(this._createConnectionViewModel(connectionsDataModel[i]));
            ++i;
          }
        }
        return connectionsViewModel;
      };
      this.data = chartDataModel;
      this.nodes = createNodesViewModel(this.data.nodes);
      this.connections = this._createConnectionsViewModel(this.data.connections);
      this.createNewConnection = function(sourceConnector, destConnector) {
        var connectionDataModel, connectionViewModel, connectionsDataModel, connectionsViewModel, destConnectorIndex, destNode, sourceConnectorIndex, sourceNode;
        debug.assertObjectValid(sourceConnector);
        debug.assertObjectValid(destConnector);
        connectionsDataModel = this.data.connections;
        if (!connectionsDataModel) {
          connectionsDataModel = this.data.connections = [];
        }
        connectionsViewModel = this.connections;
        if (!connectionsViewModel) {
          connectionsViewModel = this.connections = [];
        }
        sourceNode = sourceConnector.parentNode();
        sourceConnectorIndex = sourceNode.outputConnectors.indexOf(sourceConnector);
        if (sourceConnectorIndex === -1) {
          sourceConnectorIndex = sourceNode.inputConnectors.indexOf(sourceConnector);
          if (sourceConnectorIndex === -1) {
            throw new Error("Failed to find source connector within either inputConnectors or outputConnectors of source node.");
          }
        }
        destNode = destConnector.parentNode();
        destConnectorIndex = destNode.inputConnectors.indexOf(destConnector);
        if (destConnectorIndex === -1) {
          destConnectorIndex = destNode.outputConnectors.indexOf(destConnector);
          if (destConnectorIndex === -1) {
            throw new Error("Failed to find dest connector within inputConnectors or ouputConnectors of dest node.");
          }
        }
        connectionDataModel = {
          source: {
            nodeID: sourceNode.data.id,
            connectorIndex: sourceConnectorIndex
          },
          dest: {
            nodeID: destNode.data.id,
            connectorIndex: destConnectorIndex
          }
        };
        connectionsDataModel.push(connectionDataModel);
        connectionViewModel = new flowchart.ConnectionViewModel(connectionDataModel, sourceConnector, destConnector);
        connectionsViewModel.push(connectionViewModel);
      };
      this.addNode = function(nodeDataModel) {
        if (!this.data.nodes) {
          this.data.nodes = [];
        }
        this.data.nodes.push(nodeDataModel);
        this.nodes.push(new flowchart.NodeViewModel(nodeDataModel));
      };
      this.selectAll = function() {
        var connection, connections, i, node, nodes;
        nodes = this.nodes;
        i = 0;
        while (i < nodes.length) {
          node = nodes[i];
          node.select();
          ++i;
        }
        connections = this.connections;
        i = 0;
        while (i < connections.length) {
          connection = connections[i];
          connection.select();
          ++i;
        }
      };
      this.deselectAll = function() {
        var connection, connections, i, node, nodes;
        nodes = this.nodes;
        i = 0;
        while (i < nodes.length) {
          node = nodes[i];
          node.deselect();
          ++i;
        }
        connections = this.connections;
        i = 0;
        while (i < connections.length) {
          connection = connections[i];
          connection.deselect();
          ++i;
        }
      };
      this.updateSelectedNodesLocation = function(deltaX, deltaY) {
        var i, node, selectedNodes;
        selectedNodes = this.getSelectedNodes();
        i = 0;
        while (i < selectedNodes.length) {
          node = selectedNodes[i];
          node.data.x += deltaX;
          node.data.y += deltaY;
          ++i;
        }
      };
      this.handleNodeClicked = function(node, ctrlKey) {
        var nodeIndex;
        if (ctrlKey) {
          node.toggleSelected();
        } else {
          this.deselectAll();
          node.select();
        }
        nodeIndex = this.nodes.indexOf(node);
        if (nodeIndex === -1) {
          throw new Error("Failed to find node in view model!");
        }
        this.nodes.splice(nodeIndex, 1);
        this.nodes.push(node);
      };
      this.handleConnectionMouseDown = function(connection, ctrlKey) {
        if (ctrlKey) {
          connection.toggleSelected();
        } else {
          this.deselectAll();
          connection.select();
        }
      };
      this.deleteSelected = function() {
        var connection, connectionIndex, deletedNodeIds, newConnectionDataModels, newConnectionViewModels, newNodeDataModels, newNodeViewModels, node, nodeIndex;
        newNodeViewModels = [];
        newNodeDataModels = [];
        deletedNodeIds = [];
        nodeIndex = 0;
        while (nodeIndex < this.nodes.length) {
          node = this.nodes[nodeIndex];
          if (!node.selected()) {
            newNodeViewModels.push(node);
            newNodeDataModels.push(node.data);
          } else {
            deletedNodeIds.push(node.data.id);
          }
          ++nodeIndex;
        }
        newConnectionViewModels = [];
        newConnectionDataModels = [];
        connectionIndex = 0;
        while (connectionIndex < this.connections.length) {
          connection = this.connections[connectionIndex];
          if (!connection.selected() && deletedNodeIds.indexOf(connection.data.source.nodeID) === -1 && deletedNodeIds.indexOf(connection.data.dest.nodeID) === -1) {
            newConnectionViewModels.push(connection);
            newConnectionDataModels.push(connection.data);
          }
          ++connectionIndex;
        }
        this.nodes = newNodeViewModels;
        this.data.nodes = newNodeDataModels;
        this.connections = newConnectionViewModels;
        this.data.connections = newConnectionDataModels;
      };
      this.applySelectionRect = function(selectionRect) {
        var connection, i, node;
        this.deselectAll();
        i = 0;
        while (i < this.nodes.length) {
          node = this.nodes[i];
          if (node.x() >= selectionRect.x && node.y() >= selectionRect.y && node.x() + node.width() <= selectionRect.x + selectionRect.width && node.y() + node.height() <= selectionRect.y + selectionRect.height) {
            node.select();
          }
          ++i;
        }
        i = 0;
        while (i < this.connections.length) {
          connection = this.connections[i];
          if (connection.source.parentNode().selected() && connection.dest.parentNode().selected()) {
            connection.select();
          }
          ++i;
        }
      };
      this.getSelectedNodes = function() {
        var i, node, selectedNodes;
        selectedNodes = [];
        i = 0;
        while (i < this.nodes.length) {
          node = this.nodes[i];
          if (node.selected()) {
            selectedNodes.push(node);
          }
          ++i;
        }
        return selectedNodes;
      };
      this.getSelectedConnections = function() {
        var connection, i, selectedConnections;
        selectedConnections = [];
        i = 0;
        while (i < this.connections.length) {
          connection = this.connections[i];
          if (connection.selected()) {
            selectedConnections.push(connection);
          }
          ++i;
        }
        return selectedConnections;
      };
    };
  });

  ngapp.factory("prompt", function() {
    return prompt;
  });

  ngapp.controller("AppCtrl", [
    "$scope", "prompt", "flowchartDataModel", AppCtrl = function($scope, prompt, flowchartDataModel) {
      var ADown, aKeyCode, chartDataModel, ctrlDown, ctrlKeyCode, ctrlKeyCodeMac, deleteKeyCode, deleteKeyCodeMac, escKeyCode, nextNodeID, preventDefaultAction;
      deleteKeyCode = 46;
      deleteKeyCodeMac = 8;
      ctrlKeyCode = 17;
      ctrlKeyCodeMac = 91;
      ctrlDown = false;
      ADown = false;
      aKeyCode = 65;
      escKeyCode = 27;
      nextNodeID = 10;
      chartDataModel = {
        nodes: [
          {
            name: "Example Node 1",
            id: 0,
            x: 0,
            y: 0,
            inputConnectors: [
              {
                name: "A"
              }, {
                name: "B"
              }, {
                name: "C"
              }
            ],
            outputConnectors: [
              {
                name: "A"
              }, {
                name: "B"
              }, {
                name: "C"
              }
            ]
          }, {
            name: "Example Node 2",
            id: 1,
            x: 400,
            y: 200,
            inputConnectors: [
              {
                name: "A"
              }, {
                name: "B"
              }, {
                name: "C"
              }
            ],
            outputConnectors: [
              {
                name: "A"
              }, {
                name: "B"
              }, {
                name: "C"
              }
            ]
          }
        ],
        connections: [
          {
            source: {
              nodeID: 0,
              connectorIndex: 1
            },
            dest: {
              nodeID: 1,
              connectorIndex: 2
            }
          }
        ]
      };
      $scope.print = function() {
        return console.log($scope.chartViewModel.data);
      };
      preventDefaultAction = function(evt) {
        evt.stopPropagation();
        return evt.preventDefault();
      };
      $scope.keyDown = function(evt) {
        if ((evt.keyCode === ctrlKeyCode) || (evt.keyCode === ctrlKeyCodeMac)) {
          preventDefaultAction(evt);
          ctrlDown = true;
        }
        if (evt.keyCode === aKeyCode) {
          preventDefaultAction(evt);
          ADown = true;
        }
        if (evt.keyCode === deleteKeyCodeMac) {
          preventDefaultAction(evt);
        }
        if (ADown && ctrlDown) {
          return $scope.chartViewModel.selectAll();
        }
      };
      $scope.keyUp = function(evt) {
        if ((evt.keyCode === deleteKeyCode) || (evt.keyCode === deleteKeyCodeMac)) {
          preventDefaultAction(evt);
          $scope.chartViewModel.deleteSelected();
        }
        if (evt.keyCode === escKeyCode) {
          $scope.chartViewModel.deselectAll();
        }
        if ((evt.keyCode === ctrlKeyCode) || (evt.keyCode === ctrlKeyCodeMac)) {
          preventDefaultAction(evt);
          ctrlDown = false;
        }
        if (evt.keyCode === aKeyCode) {
          preventDefaultAction(evt);
          return ADown = false;
        }
      };
      $scope.addNewNode = function() {
        var newNodeDataModel, nodeName;
        nodeName = prompt("Enter a node name:", "New node");
        if (!nodeName) {
          return;
        }
        newNodeDataModel = {
          name: nodeName,
          id: nextNodeID++,
          x: 50,
          y: 50,
          inputConnectors: [
            {
              name: "X"
            }, {
              name: "Y"
            }, {
              name: "Z"
            }
          ],
          outputConnectors: [
            {
              name: "1"
            }, {
              name: "2"
            }, {
              name: "3"
            }
          ]
        };
        $scope.chartViewModel.addNode(newNodeDataModel);
      };
      $scope.addNewInputConnector = function() {
        var connectorName, i, node, selectedNodes;
        connectorName = prompt("Enter a connector name:", "New connector");
        if (!connectorName) {
          return;
        }
        selectedNodes = $scope.chartViewModel.getSelectedNodes();
        i = 0;
        while (i < selectedNodes.length) {
          node = selectedNodes[i];
          node.addInputConnector({
            name: connectorName
          });
          ++i;
        }
      };
      $scope.addNewOutputConnector = function() {
        var connectorName, i, node, selectedNodes;
        connectorName = prompt("Enter a connector name:", "New connector");
        if (!connectorName) {
          return;
        }
        selectedNodes = $scope.chartViewModel.getSelectedNodes();
        i = 0;
        while (i < selectedNodes.length) {
          node = selectedNodes[i];
          node.addOutputConnector({
            name: connectorName
          });
          ++i;
        }
      };
      $scope.deleteSelected = function() {
        $scope.chartViewModel.deleteSelected();
      };
      return $scope.chartViewModel = new flowchartDataModel.ChartViewModel(chartDataModel);
    }
  ]);

}).call(this);

/*
//@ sourceMappingURL=app.map
*/
