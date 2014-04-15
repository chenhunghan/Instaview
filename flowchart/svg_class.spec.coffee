describe "svg_class", ->
  it "removeClassSVG returns false when there is no classes attr", ->
    mockElement = attr: ->
      null

    testClass = "foo"
    expect(removeClassSVG(mockElement, testClass)).toBe false
    return

  it "removeClassSVG returns false when the element doesnt already have the class", ->
    mockElement = attr: ->
      "smeg"

    testClass = "foo"
    expect(removeClassSVG(mockElement, testClass)).toBe false
    return

  it "removeClassSVG returns true and removes the class when the element does have the class", ->
    testClass = "foo"
    mockElement = attr: ->
      testClass

    spyOn(mockElement, "attr").andCallThrough()
    expect(removeClassSVG(mockElement, testClass)).toBe true
    expect(mockElement.attr).toHaveBeenCalledWith "class", ""
    return

  it "hasClassSVG returns false when attr returns null", ->
    mockElement = attr: ->
      null

    testClass = "foo"
    expect(hasClassSVG(mockElement, testClass)).toBe false
    return

  it "hasClassSVG returns false when element has no class", ->
    mockElement = attr: ->
      ""

    testClass = "foo"
    expect(hasClassSVG(mockElement, testClass)).toBe false
    return

  it "hasClassSVG returns false when element has wrong class", ->
    mockElement = attr: ->
      "smeg"

    testClass = "foo"
    expect(hasClassSVG(mockElement, testClass)).toBe false
    return

  it "hasClassSVG returns true when element has correct class", ->
    testClass = "foo"
    mockElement = attr: ->
      testClass

    expect(hasClassSVG(mockElement, testClass)).toBe true
    return

  it "hasClassSVG returns true when element 1 correct class of many ", ->
    testClass = "foo"
    mockElement = attr: ->
      "whar " + testClass + " smeg"

    expect(hasClassSVG(mockElement, testClass)).toBe true
    return

  return

