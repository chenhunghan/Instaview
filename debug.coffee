#
# Debug utilities.
# S
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
