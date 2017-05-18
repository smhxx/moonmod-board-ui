export doNothing = ->

getHorizontalSizeScale = =>
  @tileMode and (1000 * @widthRatio) or 8000

getVerticalSizeScale = =>
  @tileMode and 1000 or 8000

getHorizontalPosScale = =>
  @tileMode and @widthRatio or 8.3

getVerticalPosScale = =>
  @tileMode and 1 or 8.3

convertElementPosition = (x, y) =>
  halfHeightResolution = @heightResolution / 2
  halfWidthResolution = halfHeightResolution * @widthRatio
  x = (getHorizontalPosScale @) * (x - halfWidthResolution) / halfWidthResolution
  y = (getVerticalPosScale @) * (y - halfHeightResolution) / halfHeightResolution
  { x, @drawDepth, y }

createElementProps = (element, overrides) =>
  overrides = overrides or { }
  widthResolution = @heightResolution * @widthRatio
  rawPosition = overrides.position or { overrides.x or element.x, overrides.y or element.y }
  {
    width: (getHorizontalSizeScale @) * (overrides.width or element.width) / widthResolution
    height: (getVerticalSizeScale @) * (overrides.height or element.height) / @heightResolution
    position: convertElementPosition @, rawPosition[1], rawPosition[2]
    label: overrides.text or element.text
    font_size: (overrides.fontSize or element.fontSize) * 100
    click_function: overrides.callback or "doNothing"
    function_owner: not Element.isOnGlobalScript and @context or nil
  }

getElementIndex = (element) =>
  for i, e in ipairs @elements
    return i - 1 if e == element

stripVectorXYZ = (vector) ->
  (vector.__class == Vector) and (vector\strip { "x", "y", "z" }) or vector

standardBoardHeight = 9.125

export class Board
  drawDepth: 59/100
  heightResolution: 4000
  offset: Transform { zPos: 2.5 }
  tableType: TableTypes.CUSTOM_RECTANGLE
  tileMode: false
  widthRatio: 1

  new: (options) =>
    @elements = { }
    if (type options) == "table"
      @context = options.context
      @drawDepth = options.drawDepth
      @heightResolution = options.heightResolution
      @offset = options.offset
      @tableType = options.tableType
      @tileMode = options.tileMode
      @widthRatio = options.widthRatio

  clear: =>
    for i = #@elements, 1, -1
      @elements[i]\erase @

  addElement: (element, overrides) =>
    assert @context != nil, "tts-board-ui: Attempted to call Board:addElement() but no API context was specified."
    table.insert @elements, element
    @context.createButton (createElementProps @, element, overrides)

  removeElement: (element) =>
    assert @context != nil, "tts-board-ui: Attempted to call Board:removeElement() but no API context was specified."
    index = getElementIndex @, element
    return false unless index
    table.remove @elements, index + 1
    @context.removeButton index

  updateElement: (element, overrides) =>
    assert @context != nil, "tts-board-ui: Attempted to call Board:updateElement() but no API context was specified."
    index = getElementIndex @, element
    return false unless index
    props = createElementProps @, element, overrides
    props.index = index
    @context.editButton props

  setPosition: (position) =>
    assert @context != nil, "tts-board-ui: Attempted to call Board:setPosition() but no API context was specified."
    @context.setPosition stripVectorXYZ position

  setRotation: (rotation) =>
    assert @context != nil, "tts-board-ui: Attempted to call Board:setRotation() but no API context was specified."
    @context.setRotation stripVectorXYZ rotation

  destroy: =>
    assert @context != nil, "tts-board-ui: Attempted to call Board:destroy() but no API context was specified."
    @context.destruct!
    @context = nil

  sendToPlayer: (playerId) =>
    seatTransform = @tableType.transforms[playerId]
    assert seatTransform != nil,
      "tts-board-ui: Attempted to send board to player #{playerId} but this table does not include that player."
    offsetTransform = Transform @offset
    offsetTransform.position.data.z += standardBoardHeight / @widthRatio
    offsetTransform\rotateAboutYAxis seatTransform.rotation.data.y
    offsetTransform\translate seatTransform.position
    @setPosition offsetTransform.position
    @setRotation offsetTransform.rotation
