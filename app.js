// Generated by CoffeeScript 1.6.3
(function() {
  var AppCtrl, debug;

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

  angular.module("app", ["flowChart", 'mgcrea.ngStrap', 'topo']).service("node", [
    function() {
      var node;
      node = this;
      node.width = 60;
      node.padding = 15;
      node.nodeNameHeight = 50;
    }
  ]).service("connector", [
    "node", function(node) {
      var connector;
      connector = this;
      connector.connectorHeight = 46;
      connector.ConnectorViewModel = function(connectorDataModel, x, y, parentNode) {
        if (x === 0) {
          x = x + node.padding;
        } else {
          x = x - node.padding;
        }
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
    }
  ]).service("flowchartDataModel", [
    "node", "connector", function(node, connector) {
      var computeConnectionTangentOffset, createNodesViewModel, flowchart;
      flowchart = this;
      flowchart.width = 1300;
      flowchart.height = 600;
      flowchart.nodeWidth = node.width;
      flowchart.padding = node.padding;
      flowchart.nodeNameHeight = node.nodeNameHeight;
      flowchart.connectorHeight = connector.connectorHeight;
      flowchart.computeConnectorY = function(connectorIndex) {
        return flowchart.nodeNameHeight + (connectorIndex * flowchart.connectorHeight);
      };
      flowchart.computeConnectorPos = function(node, connectorIndex, inputConnector) {
        return {
          x: node.x() + (inputConnector ? flowchart.padding : flowchart.nodeWidth - flowchart.padding),
          y: node.y() + flowchart.computeConnectorY(connectorIndex)
        };
      };
      flowchart.NodeViewModel = function(nodeDataModel) {
        var createConnectorsViewModel;
        createConnectorsViewModel = function(connectorDataModels, x, parentNode) {
          var connectorViewModel, i, viewModels;
          viewModels = [];
          if (connectorDataModels) {
            i = 0;
            while (i < connectorDataModels.length) {
              connectorViewModel = new connector.ConnectorViewModel(connectorDataModels[i], x, flowchart.computeConnectorY(i), parentNode);
              viewModels.push(connectorViewModel);
              ++i;
            }
          }
          return viewModels;
        };
        this.data = nodeDataModel;
        this.inputConnectors = createConnectorsViewModel(this.data.inputConnectors, 0, this);
        this.outputConnectors = createConnectorsViewModel(this.data.outputConnectors, flowchart.nodeWidth, this);
        this._selected = false;
        this.data.nodeAlive = true;
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
          return flowchart.computeConnectorY(numConnectors) - 25;
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
        this.nodeAlive = function() {
          return this.data.nodeAlive;
        };
        this._addConnector = function(connectorDataModel, x, connectorsDataModel, connectorsViewModel) {
          var connectorViewModel;
          connectorViewModel = new connector.ConnectorViewModel(connectorDataModel, x, flowchart.computeConnectorY(connectorsViewModel.length), this);
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
          if (this.source) {
            return this.source.parentNode().x() + this.source.x();
          }
        };
        this.sourceCoordY = function() {
          if (this.source) {
            return this.source.parentNode().y() + this.source.y();
          }
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
          if (this.dest) {
            return this.dest.parentNode().x() + this.dest.x();
          }
        };
        this.destCoordY = function() {
          if (this.dest) {
            return this.dest.parentNode().y() + this.dest.y();
          }
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
        this.distance = function() {
          var dd, dx, dy;
          dd = function(a) {
            return a * a;
          };
          dx = this.destCoordX() - this.sourceCoordX();
          dy = this.destCoordY() - this.sourceCoordY();
          return Math.sqrt(dd(dx) + dd(dy));
        };
        this.opacity = 0.2;
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
        this.data.connectionAlive = true;
        this.data.connectionNotBlocked = true;
        this.connectionAlive = function() {
          return this.data.connectionAlive;
        };
        this.connectionNotBlocked = function() {
          return this.data.connectionNotBlocked;
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
        this.width = flowchart.width;
        this.height = flowchart.height;
        this.findNode = function(nodeID) {
          var i;
          i = 0;
          while (i < this.nodes.length) {
            node = this.nodes[i];
            if (node.data.id === nodeID) {
              return node;
            }
            ++i;
          }
          throw new Error("Failed to find node " + nodeID);
          return false;
        };
        this.findConnector = function(nodeID, connectorIndex) {
          var i, j, n, nin, nout;
          node = this.findNode(nodeID);
          i = 0;
          while (i < node.inputConnectors.length) {
            nin = node.inputConnectors[i];
            if (nin.data.name === connectorIndex) {
              n = nin;
              i = node.inputConnectors.length;
            } else {
              i++;
            }
          }
          j = 0;
          while (j < node.outputConnectors.length) {
            nout = node.outputConnectors[j];
            if (nout.data.name === connectorIndex) {
              n = nout;
              j = node.outputConnectors.length;
            } else {
              j++;
            }
          }
          return n;
        };
        this._createConnectionViewModel = function(connectionDataModel) {
          var destConnector, sourceConnector;
          sourceConnector = this.findConnector(connectionDataModel.source.nodeID, connectionDataModel.sourceport);
          destConnector = this.findConnector(connectionDataModel.dest.nodeID, connectionDataModel.targetport);
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
          var connection, connections, i, nodes;
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
          var connection, connections, i, nodes;
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
          var i, selectedNodes;
          selectedNodes = this.getSelectedNodes();
          i = 0;
          while (i < selectedNodes.length) {
            node = selectedNodes[i];
            node.data.x += deltaX;
            node.data.y += deltaY;
            ++i;
          }
        };
        this.handleNodeClicked = function(node, evt) {
          var nodeIndex;
          if (evt) {
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
          var connection, connectionIndex, deletedNodeIds, newConnectionDataModels, newConnectionViewModels, newNodeDataModels, newNodeViewModels, nodeIndex;
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
          var connection, i;
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
          var i, selectedNodes;
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
    }
  ]).service("prompt", [
    "$modal", function($modal) {
      return this.show = function(title, value, $scope, cb) {
        var Modal;
        $scope.title = title;
        Modal = $modal({
          scope: $scope,
          animation: "am-fade-and-scale",
          template: "modal_input.html"
        });
        Modal.hide = function() {
          $(".modal").hide();
          return $(".modal-backdrop").hide();
        };
        $scope.hide = function() {
          return Modal.hide();
        };
        $scope.printdata = function() {
          return console.log($scope.newValue);
        };
        Modal.$promise.then(function() {
          return Modal.show();
        });
        return $scope.confirm = function() {
          $scope.hide();
          return cb();
        };
      };
    }
  ]).controller("AppCtrl", [
    "$scope", "$http", "prompt", "flowchartDataModel", "topoAlgorithm", AppCtrl = function($scope, $http, prompt, flowchartDataModel, topoAlgorithm) {
      var ADown, InitialNodeX, InitialNodeY, aKeyCode, ctrlDown, ctrlKeyCode, ctrlKeyCodeMac, deleteKeyCode, deleteKeyCodeMac, escKeyCode, nextNodeID, preventDefaultAction;
      $http.get('resource/topo_for_debug.json').success(function(topd) {
        var cb, dev, ip, noPoscb, raw;
        raw = (function() {
          var _results;
          _results = [];
          for (ip in topd) {
            dev = topd[ip];
            _results.push(dev);
          }
          return _results;
        })();
        cb = function(data) {
          var chartDataModel;
          chartDataModel = {
            nodes: [
              {
                name: "IS-084",
                id: 0,
                x: 0,
                y: 0,
                inputConnectors: [
                  {
                    name: "P1"
                  }, {
                    name: "P2"
                  }, {
                    name: "P3"
                  }, {
                    name: "P4"
                  }
                ],
                outputConnectors: [
                  {
                    name: "P5"
                  }, {
                    name: "P6"
                  }, {
                    name: "P7"
                  }, {
                    name: "P8"
                  }
                ]
              }, {
                name: "IS-085",
                id: 1,
                x: 400,
                y: 200,
                inputConnectors: [
                  {
                    name: "P1"
                  }, {
                    name: "P2"
                  }, {
                    name: "P3"
                  }, {
                    name: "P4"
                  }
                ],
                outputConnectors: [
                  {
                    name: "P5"
                  }, {
                    name: "P6"
                  }, {
                    name: "P7"
                  }, {
                    name: "P8"
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
          return $scope.chartViewModel = new flowchartDataModel.ChartViewModel(data);
        };
        noPoscb = function(data) {
          return $scope.nodelist = data.nodes;
        };
        topoAlgorithm.preProcess(raw, noPoscb, 'noPos');
        return topoAlgorithm.preProcess(raw, cb);
      });
      deleteKeyCode = 46;
      deleteKeyCodeMac = 8;
      ctrlKeyCode = 17;
      ctrlKeyCodeMac = 91;
      ctrlDown = false;
      ADown = false;
      aKeyCode = 65;
      escKeyCode = 27;
      nextNodeID = 0;
      InitialNodeX = 50;
      InitialNodeY = 50;
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
          $scope.chartViewModel.selectAll();
        }
        if (ctrlDown) {
          return console.log('control down');
        }
      };
      $scope.keyUp = function(evt) {
        if ((evt.keyCode === deleteKeyCode) || (evt.keyCode === deleteKeyCodeMac)) {
          $scope.chartViewModel.deleteSelected();
        }
        if (evt.keyCode === escKeyCode) {
          $scope.chartViewModel.deselectAll();
        }
        if ((evt.keyCode === ctrlKeyCode) || (evt.keyCode === ctrlKeyCodeMac)) {
          ctrlDown = false;
        }
        if (evt.keyCode === aKeyCode) {
          return ADown = false;
        }
      };
      $scope.nodelistMouseDown = function(evt, node) {
        if ($scope.chartViewModel.findNode(node.id) != null) {
          $scope.chartViewModel.findNode(node.id).toggleSelected();
          return console.log($scope.chartViewModel.findNode(node.id));
        } else {
          node.x = evt.clientX + 100;
          node.y = evt.clientY;
          return $scope.chartViewModel.addNode(node);
        }
      };
      $scope.addNewNode = function() {
        var cb;
        InitialNodeX = InitialNodeX + 15;
        InitialNodeY = InitialNodeY + 15;
        $scope.mutinode = false;
        $scope.targetNode = {
          name: "New Node",
          id: nextNodeID++,
          x: InitialNodeX,
          y: InitialNodeY,
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
        $scope.newValue = $scope.targetNode.name;
        cb = function() {
          $scope.targetNode.name = $scope.newValue;
          return $scope.chartViewModel.addNode($scope.targetNode);
        };
        return prompt("Enter a node name:", "New node", $scope, cb);
      };
      $scope.addNewInputConnector = function() {
        var cb, i, selectedNodes, _i, _len;
        $scope.newValue = "New connector";
        selectedNodes = $scope.chartViewModel.getSelectedNodes();
        if (selectedNodes.length > 1) {
          $scope.mutinode = true;
          $scope.targetNodes = [];
          for (_i = 0, _len = selectedNodes.length; _i < _len; _i++) {
            i = selectedNodes[_i];
            $scope.targetNodes.push(i.data.name);
          }
        } else {
          $scope.targetNode = selectedNodes[0].data;
        }
        cb = function() {
          var node;
          i = 0;
          while (i < selectedNodes.length) {
            node = selectedNodes[i];
            node.addInputConnector({
              name: $scope.newValue
            });
            ++i;
          }
        };
        return prompt("Enter a connector name:", "", $scope, cb);
      };
      $scope.addNewOutputConnector = function() {
        var cb, i, selectedNodes, _i, _len;
        $scope.newValue = "New connector";
        selectedNodes = $scope.chartViewModel.getSelectedNodes();
        if (selectedNodes.length > 1) {
          $scope.mutinode = true;
          $scope.targetNodes = [];
          for (_i = 0, _len = selectedNodes.length; _i < _len; _i++) {
            i = selectedNodes[_i];
            $scope.targetNodes.push(i.data.name);
          }
        } else {
          $scope.targetNode = selectedNodes[0].data;
        }
        cb = function() {
          var node;
          i = 0;
          while (i < selectedNodes.length) {
            node = selectedNodes[i];
            node.addOutputConnector({
              name: $scope.newValue
            });
            ++i;
          }
        };
        return prompt("Enter a connector name:", "", $scope, cb);
      };
      $scope.deleteSelected = function() {
        $scope.chartViewModel.deleteSelected();
      };
      $scope.random_connectiondown = function() {
        var linkindex, max, min;
        max = $scope.chartViewModel.data.connections.length - 1;
        min = 0;
        linkindex = Math.floor(Math.random() * (max - min + 1)) + min;
        return $scope.chartViewModel.data.connections[linkindex].connectionAlive = false;
      };
      $scope.random_connectionblock = function() {
        var linkindex, max, min;
        max = $scope.chartViewModel.data.connections.length - 1;
        min = 0;
        linkindex = Math.floor(Math.random() * (max - min + 1)) + min;
        return $scope.chartViewModel.data.connections[linkindex].connectionNotBlocked = false;
      };
      return $scope.random_nodedown = function() {
        var max, min, nodeindex;
        max = $scope.chartViewModel.data.nodes.length - 1;
        min = 0;
        nodeindex = Math.floor(Math.random() * (max - min + 1)) + min;
        return $scope.chartViewModel.data.nodes[nodeindex].nodeAlive = false;
      };
    }
  ]).directive("ngRightClick", function($parse) {
    return function(scope, element, attrs) {
      var fn;
      fn = $parse(attrs.ngRightClick);
      return element.bind("contextmenu", function(event) {
        return scope.$apply(function() {
          event.preventDefault();
          return fn(scope, {
            $event: event
          });
        });
      });
    };
  }).directive("machine", function() {
    return {
      restrict: "E",
      templateUrl: "flowchart/machine.html",
      replace: true
    };
  });

}).call(this);

/*
//@ sourceMappingURL=app.map
*/
