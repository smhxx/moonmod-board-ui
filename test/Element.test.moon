describe "Element", ->

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

  before_each ->
    export api = ApiContext!
    export board = Board { context: api }
    export element = Element!

  describe ":new()", ->

    it "assumes the correct defaults if no options are provided", ->
      assert.equals 0, element.x
      assert.equals 0, element.y
      assert.equals 400, element.width
      assert.equals 400, element.height
      assert.equals "", element.text
      assert.equals 8, element.fontSize
      assert.equals true, element.enabled
      assert.equals element, element.resultValue
      assert.is.Nil element.board

    it "uses the CallbackHandler class to initiate its callbacks table", ->
      assert.are.same { }, element.callbacks
      assert.is.not.inherited element, "callbacks"

    it "takes on any values provided in the options argument", ->
      owner = {
        method: =>
      }
      options = {
        x: 200
        y: 200
        width: 1000
        height: 1000
        text: "Hello!"
        fontSize: 16
        enabled: false
        callback: owner.method
        callbackOwner: owner
        board: board
        resultValue: 4
      }
      element = Element options
      assert.equals 200, element.x
      assert.equals 200, element.y
      assert.equals 1000, element.width
      assert.equals 1000, element.height
      assert.equals "Hello!", element.text
      assert.equals 16, element.fontSize
      assert.equals false, element.enabled
      assert.equals 4, element.resultValue
      assert.equals board, element.board
      assert.are.same {{ fn: owner.method, :owner }}, element.callbacks

    it "takes on the resultValue if it is not nil, even if it is falsy", ->
      options = {
        resultValue: false
      }
      element = Element options
      assert.equals false, element.resultValue

    it "leaves the owner field nil if no callbackOwner option is given", ->
      callback = ->
      element = Element { :callback }
      assert.are.same {{ fn: callback }}, element.callbacks

  describe ":draw()", ->

    it "draws the Element to the specified Board", ->
      call = spy.on board, "addElement"
      element\draw board
      call\revert!
      assert.spy(call).was.called!
      assert.equals board, call.calls[1].refs[1]
      assert.equals element, call.calls[1].refs[2]

    it "erases the Element and redraws if already drawn to the same board", ->
      element\draw board
      addCall = spy.on board, "addElement"
      eraseCall = spy.on element, "erase"
      element\draw board
      addCall\revert!
      eraseCall\revert!
      assert.spy(eraseCall).was.called!
      assert.equals element, eraseCall.calls[1].refs[1]
      assert.equals board, eraseCall.calls[1].refs[2]
      assert.spy(addCall).was.called!
      assert.equals board, addCall.calls[1].refs[1]
      assert.equals element, addCall.calls[1].refs[2]

    it "draws the Element to the previously specified board if none is passed", ->
      element.board = board
      call = spy.on board, "addElement"
      element\draw!
      call\revert!
      assert.spy(call).was.called!
      assert.equals board, call.calls[1].refs[1]
      assert.equals element, call.calls[1].refs[2]

    it "passes a table of override values if one is provided", ->
      overrides = { x: 600 }
      call = spy.on board, "addElement"
      element\draw board, overrides
      call\revert!
      assert.spy(call).was.called!
      assert.equals board, call.calls[1].refs[1]
      assert.equals element, call.calls[1].refs[2]
      assert.equals overrides, call.calls[1].refs[3]

    it "creates a function in global scope to trigger the Element's callback(s)", ->
      apiCall = spy.on api, "createButton"
      element\draw board
      apiCall\revert!
      callbackName = apiCall.calls[1].refs[1].click_function
      assert.equals "string", type callbackName
      assert.is.a.function _G[callbackName]

    it "reuses the name of callbacks previously used by now-erased elements", ->
      element2 = Element!
      element3 = Element!
      apiCall = spy.on api, "createButton"
      element\draw board
      element2\draw board
      element\erase board
      element3\draw board
      callbackName1 = apiCall.calls[1].refs[1].click_function
      callbackName2 = apiCall.calls[3].refs[1].click_function
      assert.equals callbackName1, callbackName2

    it "does nothing if the enabled property is set to false", ->
      element.enabled = false
      apiCall = spy.on api, "createButton"
      element\draw board
      assert.spy(apiCall).was.not.called!

  describe ":erase()", ->

    it "returns false if the Element is not drawn to the Board", ->
      ret = element\erase board
      assert.equals false, ret

    it "removes the Element from the specified Board", ->
      element\draw board
      call = spy.on board, "removeElement"
      element\erase board
      call\revert!
      assert.spy(call).was.called!
      assert.equals board, call.calls[1].refs[1]
      assert.equals element, call.calls[1].refs[2]

    it "removes the Element from the previously specified Board if none is passed", ->
      element.board = board
      element\draw!
      call = spy.on board, "removeElement"
      element\erase!
      call\revert!
      assert.spy(call).was.called!
      assert.equals board, call.calls[1].refs[1]
      assert.equals element, call.calls[1].refs[2]

    it "destroys the global function created to trigger the Element's callback(s)", ->
      apiCall = spy.on api, "createButton"
      element\draw board
      element\erase board
      apiCall\revert!
      callbackName = apiCall.calls[1].refs[1].click_function
      assert.equals "string", type callbackName
      assert.is.Nil _G[callbackName]

    it "removes the Element's reference to the now-destroyed function", ->
      element\draw board
      assert.not.Nil element.actions[board]
      element\erase board
      assert.is.Nil element.actions[board]

    it "returns true if the operation was successful", ->
      element\draw board
      ret = element\erase board
      assert.equals true, ret

  describe ":update()", ->

    it "returns false if the Element is not drawn to the Board", ->
      ret = element\update board
      assert.equals false, ret

    it "updates the properties of the Element on the specified Board", ->
      element\draw board
      call = spy.on board, "updateElement"
      element\update board
      call\revert!
      assert.spy(call).was.called!
      assert.equals board, call.calls[1].refs[1]
      assert.equals element, call.calls[1].refs[2]

    it "updates the properties of the Element on the previously specified Board if none is passed", ->
      element.board = board
      element\draw!
      call = spy.on board, "updateElement"
      element\update!
      call\revert!
      assert.spy(call).was.called!
      assert.equals board, call.calls[1].refs[1]
      assert.equals element, call.calls[1].refs[2]

    it "resupplies the name of the global function created to trigger the Element's callback", ->
      createCall = spy.on api, "createButton"
      editCall = spy.on api, "editButton"
      element\draw board
      element\update board
      createCall\revert!
      editCall\revert!
      originalCallbackName = createCall.calls[1].refs[1].click_function
      editedCallbackName = editCall.calls[1].refs[1].click_function
      assert.equals originalCallbackName, editedCallbackName

    it "returns true if the operation was successful", ->
      element\draw board
      ret = element\update board
      assert.equals true, ret

  describe ":triggerCallbacks()", ->

    before_each ->
      apiCall = spy.on api, "createButton"
      element\draw board
      apiCall\revert!
      export resultCall = spy.on element, "triggerCallbacks"
      export callbackName = apiCall.calls[1].refs[1].click_function

    it "is triggered when the Element's global callback helper is called", ->
      _G[callbackName]!
      resultCall\revert!
      assert.spy(resultCall).was.called!
      assert.equals element, resultCall.calls[1].refs[1]

    it "passes the Element's result value as the first argument to the callbacks", ->
      element.resultValue = "hello"
      _G[callbackName]!
      resultCall\revert!
      assert.spy(resultCall).was.called!
      assert.equals element, resultCall.calls[1].refs[1]
      assert.equals "hello", resultCall.calls[1].vals[2]

    it "passes the Board the element was triggered on as the second argument to the callbacks", ->
      _G[callbackName]!
      resultCall\revert!
      assert.spy(resultCall).was.called!
      assert.equals element, resultCall.calls[1].refs[1]
      assert.equals board, resultCall.calls[1].refs[3]
