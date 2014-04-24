// Generated by CoffeeScript 1.6.3
(function() {
  var FlowChartController, hasClassSVG, removeClassSVG;

  removeClassSVG = function(obj, remove) {
    var classes, index;
    classes = obj.attr("class");
    if (!classes) {
      return false;
    }
    index = classes.search(remove);
    if (index === -1) {
      return false;
    } else {
      classes = classes.substring(0, index) + classes.substring(index + remove.length, classes.length);
      obj.attr("class", classes);
      return true;
    }
  };

  hasClassSVG = function(obj, has) {
    var classes, index;
    classes = obj.attr("class");
    if (!classes) {
      return false;
    }
    index = classes.search(has);
    if (index === -1) {
      return false;
    } else {
      return true;
    }
  };

  angular.module("flowChart", ["dragging"]).directive("flowChart", function() {
    return {
      restrict: "E",
      templateUrl: "flowchart/machine.html",
      replace: true,
      scope: {
        chart: "=chart"
      },
      controller: "FlowChartController"
    };
  }).controller("FlowChartController", [
    "$scope", "dragging", "$element", "flowchartDataModel", FlowChartController = function($scope, dragging, $element, flowchartDataModel) {
      var controller;
      controller = this;
      this.document = document;
      this.jQuery = function(element) {
        return $(element);
      };
      $scope.draggingConnection = false;
      $scope.connectorSize = 10;
      $scope.dragSelecting = false;
      $scope.mouseOverConnector = null;
      $scope.mouseOverConnection = null;
      $scope.mouseOverNode = null;
      this.connectionClass = "connection";
      this.connectorClass = "connector";
      this.nodeClass = "node";
      this.searchUp = function(element, parentClass) {
        if ((element == null) || element.length === 0) {
          return null;
        }
        if (hasClassSVG(element, parentClass)) {
          return element;
        }
        return this.searchUp(element.parent(), parentClass);
      };
      this.hitTest = function(clientX, clientY) {
        return this.document.elementFromPoint(clientX, clientY);
      };
      this.checkForHit = function(mouseOverElement, whichClass) {
        var hoverElement;
        hoverElement = this.searchUp(this.jQuery(mouseOverElement), whichClass);
        if (!hoverElement) {
          return null;
        }
        return hoverElement.scope();
      };
      this.translateCoordinates = function(x, y) {
        var matrix, point, svg_elem;
        svg_elem = $element.get(0);
        matrix = svg_elem.getScreenCTM();
        point = svg_elem.createSVGPoint();
        point.x = x;
        point.y = y;
        return point.matrixTransform(matrix.inverse());
      };
      $scope.mouseDown = function(evt) {
        switch (evt.button) {
          case 0:
            $scope.chart.deselectAll();
            return dragging.startDrag(evt, {
              dragStarted: function(x, y) {
                var startPoint;
                $scope.dragSelecting = true;
                startPoint = controller.translateCoordinates(x, y);
                $scope.dragSelectionStartPoint = startPoint;
                $scope.dragSelectionRect = {
                  x: startPoint.x,
                  y: startPoint.y,
                  width: 0,
                  height: 0
                };
              },
              dragging: function(x, y) {
                var curPoint, startPoint;
                startPoint = $scope.dragSelectionStartPoint;
                curPoint = controller.translateCoordinates(x, y);
                $scope.dragSelectionRect = {
                  x: (curPoint.x > startPoint.x ? startPoint.x : curPoint.x),
                  y: (curPoint.y > startPoint.y ? startPoint.y : curPoint.y),
                  width: (curPoint.x > startPoint.x ? curPoint.x - startPoint.x : startPoint.x - curPoint.x),
                  height: (curPoint.y > startPoint.y ? curPoint.y - startPoint.y : startPoint.y - curPoint.y)
                };
              },
              dragEnded: function() {
                $scope.dragSelecting = false;
                $scope.chart.applySelectionRect($scope.dragSelectionRect);
                delete $scope.dragSelectionStartPoint;
                delete $scope.dragSelectionRect;
              }
            });
          case 2:
            if (evt.target.nodeName && evt.target.nodeName === 'svg') {
              return console.log('right click on flowchart.');
            }
        }
      };
      $scope.mouseMove = function(evt) {
        var mouseOverElement, scope;
        $scope.mouseOverConnection = null;
        $scope.mouseOverConnector = null;
        $scope.mouseOverNode = null;
        mouseOverElement = controller.hitTest(evt.clientX, evt.clientY);
        if (mouseOverElement == null) {
          return;
        }
        if (!$scope.draggingConnection) {
          scope = controller.checkForHit(mouseOverElement, controller.connectionClass);
          $scope.mouseOverConnection = (scope && scope.connection ? scope.connection : null);
          if ($scope.mouseOverConnection) {
            return;
          }
        }
        scope = controller.checkForHit(mouseOverElement, controller.connectorClass);
        $scope.mouseOverConnector = (scope && scope.connector ? scope.connector : null);
        if ($scope.mouseOverConnector) {
          return;
        }
        scope = controller.checkForHit(mouseOverElement, controller.nodeClass);
        $scope.mouseOverNode = (scope && scope.node ? scope.node : null);
      };
      $scope.nodeMouseDown = function(evt, node) {
        var chart, lastMouseCoords;
        if (evt.shiftKey || evt.ctrlKey) {
          $scope.chart.handleNodeClicked(node, true);
        } else {
          if (!node.selected()) {
            $scope.chart.deselectAll();
            node.select();
          }
        }
        switch (evt.button) {
          case 0:
            chart = $scope.chart;
            lastMouseCoords = void 0;
            dragging.startDrag(evt, {
              dragStarted: function(x, y) {
                return lastMouseCoords = controller.translateCoordinates(x, y);
              },
              dragging: function(x, y) {
                var curCoords, deltaX, deltaY;
                curCoords = controller.translateCoordinates(x, y);
                deltaX = curCoords.x - lastMouseCoords.x;
                deltaY = curCoords.y - lastMouseCoords.y;
                chart.updateSelectedNodesLocation(deltaX, deltaY);
                lastMouseCoords = curCoords;
              },
              clicked: function() {}
            });
            break;
          case 2:
            if (node.selected()) {
              console.log('rihgt click on node');
              return console.log(node.data);
            }
        }
      };
      $scope.connectionMouseDown = function(evt, connection) {
        evt.stopPropagation();
        evt.preventDefault();
        if (evt.shiftKey || evt.ctrlKey) {
          $scope.chart.handleConnectionMouseDown(connection, true);
        } else {
          if (!connection.selected()) {
            $scope.chart.deselectAll();
            connection.select();
          }
        }
        switch (evt.button) {
          case 0:
            return console.log('left click on connection');
          case 2:
            console.log('rihgt click on connection');
            return console.log(connection.data);
        }
      };
      $scope.connectedConnectorMouseDown = function(evt, connection) {
        var connector, connectorIndex, dd, isInputConnector, node, sd;
        if (!connection.selected()) {
          $scope.chart.deselectAll();
          connection.select();
        }
        sd = Math.abs(event.x - connection.sourceCoordX()) + Math.abs(event.y - connection.sourceCoordY());
        dd = Math.abs(event.x - connection.destCoordX()) + Math.abs(event.y - connection.destCoordY());
        isInputConnector = function(connector) {
          if (connector.x() === flowchartDataModel.nodeWidth) {
            return false;
          } else {
            return true;
          }
        };
        node = function(connector) {
          return connector.parentNode();
        };
        connectorIndex = function(connector) {
          var i, n, _i, _j, _len, _len1, _ref, _ref1;
          switch (isInputConnector(connector)) {
            case true:
              _ref = node(connector).inputConnectors;
              for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
                n = _ref[i];
                if (angular.equals(n, connector)) {
                  return i;
                }
              }
              break;
            case false:
              _ref1 = node(connector).outputConnectors;
              for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
                n = _ref1[i];
                if (angular.equals(n, connector)) {
                  return i;
                }
              }
          }
        };
        if (sd < 35) {
          connector = connection.dest;
          $scope.connectorMouseDown(evt, node(connector), connector, connectorIndex(connector), isInputConnector(connector));
          $scope.chart.deleteSelected();
        }
        if (dd < 35) {
          connector = connection.source;
          $scope.connectorMouseDown(evt, node(connector), connector, connectorIndex(connector), isInputConnector(connector));
          return $scope.chart.deleteSelected();
        }
      };
      return $scope.connectorMouseDown = function(evt, node, connector, connectorIndex, isInputConnector) {
        dragging.startDrag(evt, {
          dragStarted: function(x, y) {
            var curCoords;
            curCoords = controller.translateCoordinates(x, y);
            $scope.draggingConnection = true;
            $scope.dragPoint1 = flowchartDataModel.computeConnectorPos(node, connectorIndex, isInputConnector);
            $scope.dragPoint2 = {
              x: curCoords.x,
              y: curCoords.y
            };
            $scope.dragTangent1 = flowchartDataModel.computeConnectionSourceTangent($scope.dragPoint1, $scope.dragPoint2);
            $scope.dragTangent2 = flowchartDataModel.computeConnectionDestTangent($scope.dragPoint1, $scope.dragPoint2);
          },
          dragging: function(x, y, evt) {
            var startCoords;
            startCoords = controller.translateCoordinates(x, y);
            $scope.dragPoint1 = flowchartDataModel.computeConnectorPos(node, connectorIndex, isInputConnector);
            $scope.dragPoint2 = {
              x: startCoords.x,
              y: startCoords.y
            };
            $scope.dragTangent1 = flowchartDataModel.computeConnectionSourceTangent($scope.dragPoint1, $scope.dragPoint2);
            $scope.dragTangent2 = flowchartDataModel.computeConnectionDestTangent($scope.dragPoint1, $scope.dragPoint2);
          },
          dragEnded: function() {
            if ($scope.mouseOverConnector && $scope.mouseOverConnector !== connector) {
              $scope.chart.createNewConnection(connector, $scope.mouseOverConnector);
            }
            $scope.draggingConnection = false;
            delete $scope.dragPoint1;
            delete $scope.dragTangent1;
            delete $scope.dragPoint2;
            delete $scope.dragTangent2;
          }
        });
      };
    }
  ]);

}).call(this);

/*
//@ sourceMappingURL=flowchart.map
*/
