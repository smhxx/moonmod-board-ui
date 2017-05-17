export class Widget extends CallbackHandler
  new: (options) =>
    super!
    if (type options) == "table"
      if options.callback != nil
        @addCallback options.callback, options.callbackOwner
      @elements = options.elements or { }
      @board = options.board
    else
      @elements = { }

  draw: (board) =>
    board = board or @board
    for _, element in ipairs @elements
      element\addCallback @triggerCallbacks, @
      element\draw board

  erase: (board) =>
    board = board or @board
    for _, element in ipairs @elements
      element\removeCallback @triggerCallbacks, @
      element\erase board
