
#
# Service used to acquire 'mouse capture' then receive dragging events while the mouse is captured.
#

#
# Element that the mouse capture applies to, defaults to 'document' 
# unless the 'mouse-capture' directive is used.
#

#
# Set when mouse capture is acquired to an object that contains 
# handlers for 'mousemove' and 'mouseup' events.
#

#
# Handler for mousemove events while the mouse is 'captured'.
#

#
# Handler for mouseup event while the mouse is 'captured'.
#

# 
# Register an element to use as the mouse capture element instead of 
# the default which is the document.
#

#
# Acquire the 'mouse capture'.
# After acquiring the mouse capture mousemove and mouseup events will be 
# forwarded to callbacks in 'config'.
#

#
# Release any prior mouse capture.
#

# 
# In response to the mousedown event register handlers for mousemove and mouseup 
# during 'mouse capture'.
#

#
# Release the 'mouse capture'.
#

#
# Let the client know that their 'mouse capture' has been released.
#

#
# Directive that marks the mouse capture element.
#
angular.module("mouseCapture", []).factory("mouseCapture", ($rootScope) ->
  $element = document
  mouseCaptureConfig = null
  mouseMove = (evt) ->
    if mouseCaptureConfig and mouseCaptureConfig.mouseMove
      mouseCaptureConfig.mouseMove evt
      $rootScope.$digest()
    return

  mouseUp = (evt) ->
    if mouseCaptureConfig and mouseCaptureConfig.mouseUp
      mouseCaptureConfig.mouseUp evt
      $rootScope.$digest()
    return

  registerElement: (element) ->
    $element = element
    return

  acquire: (evt, config) ->
    @release()
    mouseCaptureConfig = config
    $element.mousemove mouseMove
    $element.mouseup mouseUp
    return

  release: ->
    if mouseCaptureConfig
      mouseCaptureConfig.released()  if mouseCaptureConfig.released
      mouseCaptureConfig = null
    $element.unbind "mousemove", mouseMove
    $element.unbind "mouseup", mouseUp
    return
).directive "mouseCapture", ->
  restrict: "A"
  controller: ($scope, $element, $attrs, mouseCapture) ->
    
    # 
    # Register the directives element as the mouse capture element.
    #
    mouseCapture.registerElement $element
    return

