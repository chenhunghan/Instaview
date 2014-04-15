#
# http://www.justinmccandless.com/blog/Patching+jQuery's+Lack+of+SVG+Support
#
# Functions to add and remove SVG classes because jQuery doesn't support this.
#

# jQuery's removeClass doesn't work for SVG, but this does!
# takes the object obj to remove from, and removes class removeD
# returns true if successful, false if remove does not exist in obj
removeClassSVG = (obj, remove) ->
  classes = obj.attr("class")
  return false  unless classes
  index = classes.search(remove)
  
  # if the class already doesn't exist, return false now
  if index is -1
    false
  else
    
    # string manipulation to remove the class
    classes = classes.substring(0, index) + classes.substring((index + remove.length), classes.length)
    
    # set the new string as the object's class
    obj.attr "class", classes
    true


# jQuery's hasClass doesn't work for SVG, but this does!
# takes an object obj and checks for class has
# returns true if the class exits in obj, false otherwise
hasClassSVG = (obj, has) ->
  classes = obj.attr("class")
  return false  unless classes
  index = classes.search(has)
  if index is -1
    false
  else
    true
