// Generated by CoffeeScript 1.6.3
(function() {
  var AppCtrl;

  angular.module("app", ['mgcrea.ngStrap', 'prompt', "flowchartDataModel", "flowChartController", "topo", "timeline"]).controller("AppCtrl", [
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
      $scope.random_nodedown = function() {
        var max, min, nodeindex;
        max = $scope.chartViewModel.data.nodes.length - 1;
        min = 0;
        nodeindex = Math.floor(Math.random() * (max - min + 1)) + min;
        return $scope.chartViewModel.data.nodes[nodeindex].nodeAlive = false;
      };
      $scope.random_nodewarn = function() {
        var max, min, nodeindex;
        max = $scope.chartViewModel.data.nodes.length - 1;
        min = 0;
        nodeindex = Math.floor(Math.random() * (max - min + 1)) + min;
        return $scope.chartViewModel.data.nodes[nodeindex].nodeWarning = true;
      };
      return $scope.random_portdown = function() {
        var connectorindex, max, min, nodeindex;
        max = $scope.chartViewModel.data.nodes.length - 1;
        min = 0;
        nodeindex = Math.floor(Math.random() * (max - min + 1)) + min;
        if ($scope.chartViewModel.data.nodes[nodeindex].outputConnectors.length > 0) {
          max = $scope.chartViewModel.data.nodes[nodeindex].outputConnectors.length - 1;
          connectorindex = Math.floor(Math.random() * (max - min + 1)) + min;
          $scope.chartViewModel.data.nodes[nodeindex].outputConnectors[connectorindex].linked = false;
        }
        if ($scope.chartViewModel.data.nodes[nodeindex].inputConnectors.length > 0) {
          max = $scope.chartViewModel.data.nodes[nodeindex].inputConnectors.length - 1;
          connectorindex = Math.floor(Math.random() * (max - min + 1)) + min;
          return $scope.chartViewModel.data.nodes[nodeindex].inputConnectors[connectorindex].linked = false;
        }
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
  });

}).call(this);

/*
//@ sourceMappingURL=app.map
*/
