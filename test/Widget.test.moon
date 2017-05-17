describe "Widget", ->

  use "./libraries/moonmod-core/test/mock/API.moon"
  use "./libraries/moonmod-core/dist/moonmod-core.lua"

  dist ->
    use "./dist/moonmod-board-ui.lua"

  source ->
    use "./src/table/Table.moon"
    use "./src/table/RadialTable.moon"
    use "./src/table/GridTable.moon"
    use "./src/table/TableTypes.moon"
    use "./src/Element.moon"
    use "./src/Board.moon"
    use "./src/Widget.moon"

  before_each ->
    export api = ApiContext!
    export board = Board { context: api }
    export element1 = Element!
    export element2 = Element!
    export widget = Widget { elements: { element1, element2 } }

  describe ":new()", ->

    it "takes on the table of Elements provided to it", ->
      assert.are.same { element1, element2 }, widget.elements

    it "creates an empty table for Elements if none is provided", ->
      widget = Widget!
      assert.are.same { }, widget.elements
      assert.is.not.inherited widget, "elements"

    it "takes on a default board option if one is provided", ->
      widget = Widget { :board }
      assert.equals board, widget.board

    it "uses the CallbackHandler class to initiate its callbacks table", ->
      assert.are.same { }, widget.callbacks
      assert.is.not.inherited widget, "callbacks"

    it "adds an initial callback if one is passed as an option", ->
      callbackOwner = {
        fn: ->
      }
      widget = Widget { callback: callbackOwner.fn, :callbackOwner }
      assert.are.same { { fn: callbackOwner.fn, owner: callbackOwner } }, widget.callbacks

  describe ":draw()", ->

    it "draws all of its elements to the specified board", ->
      call1 = spy.on element1, "draw"
      call2 = spy.on element2, "draw"
      widget\draw board
      call1\revert!
      call2\revert!
      assert.spy(call1).was.called!
      assert.equals element1, call1.calls[1].refs[1]
      assert.equals board, call1.calls[1].refs[2]
      assert.spy(call2).was.called!
      assert.equals element2, call2.calls[1].refs[1]
      assert.equals board, call2.calls[1].refs[2]

    it "draws all of its elements to the previously specified board if none is passed", ->
      widget.board = board
      call1 = spy.on element1, "draw"
      call2 = spy.on element2, "draw"
      widget\draw!
      call1\revert!
      call2\revert!
      assert.spy(call1).was.called!
      assert.equals element1, call1.calls[1].refs[1]
      assert.equals board, call1.calls[1].refs[2]
      assert.spy(call2).was.called!
      assert.equals element2, call2.calls[1].refs[1]
      assert.equals board, call2.calls[1].refs[2]

    it "adds its own triggerCallbacks method as a callback for each Element drawn", ->
      widget\draw board
      assert.are.same { fn: widget.triggerCallbacks, owner: widget }, element1.callbacks[1]
      assert.are.same { fn: widget.triggerCallbacks, owner: widget }, element2.callbacks[1]

  describe ":erase()", ->

    it "erases all of its elements from the specified board", ->
      widget\draw board
      call1 = spy.on element1, "erase"
      call2 = spy.on element2, "erase"
      widget\erase board
      call1\revert!
      call2\revert!
      assert.spy(call1).was.called!
      assert.equals element1, call1.calls[1].refs[1]
      assert.equals board, call1.calls[1].refs[2]
      assert.spy(call2).was.called!
      assert.equals element2, call2.calls[1].refs[1]
      assert.equals board, call2.calls[1].refs[2]

    it "erases all of its elements from the previously specified board if none is passed", ->
      widget.board = board
      widget\draw!
      call1 = spy.on element1, "erase"
      call2 = spy.on element2, "erase"
      widget\erase!
      call1\revert!
      call2\revert!
      assert.spy(call1).was.called!
      assert.equals element1, call1.calls[1].refs[1]
      assert.equals board, call1.calls[1].refs[2]
      assert.spy(call2).was.called!
      assert.equals element2, call2.calls[1].refs[1]
      assert.equals board, call2.calls[1].refs[2]

    it "removes its previously registered callback from each Element erased", ->
      widget\draw board
      widget\erase board
      assert.are.same { }, element1.callbacks
      assert.are.same { }, element2.callbacks

  describe ":triggerCallbacks()", ->

    before_each ->
      apiCall = spy.on api, "createButton"
      export resultCall = spy.on widget, "triggerCallbacks"
      widget\draw board
      apiCall\revert!
      export callbackName = apiCall.calls[1].refs[1].click_function

    it "is triggered when a child Element's global callback helper is called", ->
      _G[callbackName]!
      resultCall\revert!
      assert.spy(resultCall).was.called!
      assert.equals widget, resultCall.calls[1].refs[1]

    it "is invoked with the appropriate resultValue when an Element is triggered", ->
      element1.resultValue = "hello"
      _G[callbackName]!
      resultCall\revert!
      assert.spy(resultCall).was.called!
      assert.equals widget, resultCall.calls[1].refs[1]
      assert.equals "hello", resultCall.calls[1].vals[2]
      assert.equals board, resultCall.calls[1].refs[3]

    it "is invoked with the appropriate board when an Element is triggered", ->
      otherBoard = Board { context: api }
      apiCall = spy.on api, "createButton"
      element2\draw otherBoard
      apiCall\revert!
      callbackName = apiCall.calls[1].refs[1].click_function
      _G[callbackName]!
      resultCall\revert!
      assert.spy(resultCall).was.called!
      assert.equals widget, resultCall.calls[1].refs[1]
      assert.equals otherBoard, resultCall.calls[1].refs[3]

    it "follows the entire callback path, from Element result through to Widget's listeners", ->
      callback = spy.new ->
      widget\addCallback callback
      element1.resultValue = "hello"
      _G[callbackName]!
      resultCall\revert!
      assert.spy(callback).was.called!
      assert.equals "hello", callback.calls[1].vals[1]
      assert.equals board, callback.calls[1].refs[2]
