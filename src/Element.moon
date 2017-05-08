actions = { }
actionPrefix = "resultAction"

newAction = (element, board) ->
  ->
    element\triggerCallbacks element.resultValue, board

bindNewAction = (board) =>
  for i = 1, #actions + 1
    if actions[i] == nil
      actions[i] = true
      _G[actionPrefix .. i] = newAction @, board
      return i

unbindAction = (i) ->
  return unless i
  _G[actionPrefix .. i] = nil
  actions[i] = nil

export class Element extends CallbackHandler
  x: 0
  y: 0
  width: 400
  height: 400
  text: ""
  fontSize: 8
  enabled: true

  new: (options) =>
    super!
    @actions = { }
    if (type options) == "table"
      if options.callback != nil
        @addCallback options.callback, options.callbackOwner
      @x = options.x
      @y = options.y
      @width = options.width
      @height = options.height
      @text = options.text
      @fontSize = options.fontSize
      @enabled = options.enabled
      @board = options.board
      @resultValue = (options.resultValue == nil) and @ or options.resultValue
    else
      @resultValue = @

  draw: (board, overrides) =>
    return if not @enabled
    board = board or @board
    @erase board
    action = bindNewAction @, board
    @actions[board] = action
    overrides = overrides or { }
    overrides.callback = actionPrefix .. action
    board\addElement @, overrides

  erase: (board) =>
    board = board or @board
    return false unless @actions[board]
    unbindAction @actions[board]
    @actions[board] = nil
    board\removeElement @

  update: (board, overrides) =>
    board = board or @board
    return false unless @actions[board]
    overrides = overrides or { }
    overrides.callback = actionPrefix .. @actions[board]
    board\updateElement @, overrides
