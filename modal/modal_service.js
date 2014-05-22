// Generated by CoffeeScript 1.6.3
(function() {
  angular.module("prompt", []).service("prompt", [
    "$modal", function($modal) {
      return this.show = function(title, value, $scope, cb) {
        var Modal;
        $scope.title = title;
        Modal = $modal({
          scope: $scope,
          animation: "am-fade-and-scale",
          template: "modal/modal_input.html"
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
  ]);

}).call(this);

/*
//@ sourceMappingURL=modal_service.map
*/
