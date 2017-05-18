describe "Board", ->

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
    export element = Element {
      x: 2250
      y: 500
      width: 3000
      height: 2000
      text: "foo"
      fontSize: 12
    }

  describe ":new()", ->

    it "assumes the correct defaults if no options are provided", ->
      assert.equals 0.59, board.drawDepth
      assert.equals 4000, board.heightResolution
      assert.are.same board.offset, Transform { zPos: 2.5 }
      assert.equals TableTypes.CUSTOM_RECTANGLE, board.tableType
      assert.equals false, board.tileMode
      assert.equals 1, board.widthRatio

    it "takes on any values provided in the options argument", ->
      options = {
        context: "blah"
        heightResolution: 6000
        offset: Transform { zPos: 6.0 }
        tableType: TableTypes.OCTAGON
        tileMode: true
        widthRatio: 2.5
      }
      board = Board options
      for k, v in pairs options
        assert.equals v, board[k]

    it "creates a new unique table to hold its child elements", ->
      anotherBoard = Board { context: api }
      assert.are.same { }, board.elements
      assert.are.same { }, anotherBoard.elements
      assert.not.equal board.elements, anotherBoard.elements

  describe ":clear()", ->

    it "calls the erase() method of each Element currently displayed", ->
      elements = { }
      eraseMethods = { }
      for i = 1, 10
        elements[i] = Element!
        elements[i]\draw board
        eraseMethods[i] = spy.on elements[i], "erase"
      board\clear!
      for _, method in ipairs eraseMethods
        method\revert!
      for i = 1, 10
        assert.spy(eraseMethods[i]).was.called!
        assert.spy(eraseMethods[i]).returned.with true

  describe ":addElement()", ->

    before_each ->
      export board = Board { context: api, heightResolution: 2000, widthRatio: 1.5 }

    it "throws an error if the API context has not been defined", ->
      board = Board!
      assert.has.error ->
        board\addElement element

    it "calls API.createButton() with a table of button properties", ->
      apiCall = spy.on api, "createButton"
      board\addElement element
      apiCall\revert!
      assert.spy(apiCall).was.called!
      assert.is.a.table api.buttons[1]

    it "adds the specified Element to its own elements table", ->
      board\addElement element
      assert.are.equal element, board.elements[1]

    it "calculates the correct final width of the Element", ->
      board\addElement element
      assert.equals 8000, api.buttons[1].width

    it "accepts the width of the Element as an override", ->
      board\addElement element, { width: 1500 }
      assert.equals 4000, api.buttons[1].width

    it "calculates the correct final height of the Element", ->
      board\addElement element
      assert.equals 8000, api.buttons[1].height

    it "accepts the height of the Element as an override", ->
      board\addElement element, { height: 1000 }
      assert.equals 4000, api.buttons[1].height

    it "calculates the correct final position of the element", ->
      board\addElement element
      assert.equals 4.15, api.buttons[1].position[1]
      assert.equals -4.15, api.buttons[1].position[3]

    it "uses the overridden position if one is provided as an argument", ->
      board\addElement element, { position: { 1500, 1000 } }
      assert.equals 0, api.buttons[1].position[1]
      assert.equals 0, api.buttons[1].position[3]

    it "uses the overridden x property if provided as an argument", ->
      board\addElement element, { x: 1500 }
      assert.equals 0, api.buttons[1].position[1]
      assert.equals -4.15, api.buttons[1].position[3]

    it "uses the overridden y property if provided as an argument", ->
      board\addElement element, { y: 1000 }
      assert.equals 4.15, api.buttons[1].position[1]
      assert.equals 0, api.buttons[1].position[3]

    it "determines the button's global y position based on drawDepth", ->
      board.drawDepth = 4
      board\addElement element
      assert.equals 4, api.buttons[1].position[2]

    it "calculates the Element's width correctly in tile mode", ->
      board.tileMode = true
      board\addElement element
      assert.equals 1500, api.buttons[1].width

    it "calculates the Element's height correctly in tile mode", ->
      board.tileMode = true
      board\addElement element
      assert.equals 1000, api.buttons[1].height

    it "calculates the Element's x position correctly in tile mode", ->
      board.tileMode = true
      board\addElement element
      assert.equals 0.75, api.buttons[1].position[1]

    it "calculates the Element's y position correctly in tile mode", ->
      board.tileMode = true
      board\addElement element
      assert.equals -0.5, api.buttons[1].position[3]

    it "includes the Element's text/label property", ->
      board\addElement element
      assert.equals "foo", api.buttons[1].label

    it "accepts the text/label of the Element as an override", ->
      board\addElement element, { text: "bar" }
      assert.equals "bar", api.buttons[1].label

    it "includes the Element's font size property", ->
      board\addElement element
      assert.equals 1200, api.buttons[1].font_size

    it "accepts the font size of the Element as an override", ->
      board\addElement element, { fontSize: 16 }
      assert.equals 1600, api.buttons[1].font_size

    it "accepts the callback name of the Element as an override", ->
      board\addElement element, { callback: "wingdings" }
      assert.equals "wingdings", api.buttons[1].click_function

    it "passes the object context as the callback's owner if loaded on an object script", ->
      if useDistMode!
        use "./dist/moonmod-board-ui.lua", api
      else
        use "./src/Board.moon", api
      board = Board { context: api }
      board\addElement element
      assert.equals api, api.buttons[1].function_owner

    it "passes nil as the callback's owner if loaded on the global script", ->
      if useDistMode!
        use "./dist/moonmod-board-ui.lua"
      else
        use "./src/Board.moon"
      board = Board { context: api }
      board\addElement element
      assert.is.Nil api.buttons[1].function_owner

  describe ":removeElement()", ->

    it "throws an error if the API context has not been defined", ->
      board = Board!
      assert.has.error ->
        board\removeElement element

    it "returns false if the Element is not drawn to the board", ->
      ret = board\removeElement element
      assert.equals false, ret

    it "calls API.removeButton() with the Element's index", ->
      apiCall = spy.on api, "removeButton"
      board\addElement element
      board\removeElement element
      apiCall\revert!
      assert.spy(apiCall).was.called.with 0

    it "removes the Element from its own elements table", ->
      board\addElement element
      board\removeElement element
      assert.are.same { }, board.elements

    it "updates the indices of the remaining Elements appropriately", ->
      anotherElement = Element!
      board\addElement element
      board\addElement anotherElement
      board\removeElement element
      assert.equals anotherElement, board.elements[1]

    it "returns true if the operation was successful", ->
      board\addElement element
      ret = board\removeElement element
      assert.equals true, ret

  describe ":updateElement()", ->

    it "throws an error if the API context has not been defined", ->
      board = Board!
      assert.has.error ->
        board\updateElement element

    it "returns false if the Element is not drawn to the board", ->
      ret = board\updateElement element
      assert.equals false, ret

    it "calls API.editButton() with the properties and index of the Element", ->
      apiCall = spy.on api, "editButton"
      board\addElement element
      element.fontSize = 24
      board\updateElement element
      assert.equals 2400, api.buttons[1].font_size

    it "returns true if the operation was successful", ->
      board\addElement element
      ret = board\updateElement element
      assert.equals true, ret

  describe ":setPosition()", ->

    it "throws an error if the API context has not been defined", ->
      board = Board!
      assert.has.error ->
        board\setPosition { 10, 20, 30 }

    it "accepts the new position as a table", ->
      board\setPosition { 10, 20, 30 }
      assert.are.same { 10, 20, 30 }, api.position

    it "accepts the new position as a Vector", ->
      board\setPosition Vector { x: 10, y: 20, z: 30 }
      assert.are.same { 10, 20, 30 }, api.position

  describe ":setRotation()", ->

    it "throws an error if the API context has not been defined", ->
      board = Board!
      assert.has.error ->
        board\setRotation { 45, 90, 135 }

    it "accepts the new rotation as a table", ->
      board\setRotation { 45, 90, 135 }
      assert.are.same { 45, 90, 135 }, api.rotation

    it "accepts the new rotation as a Vector", ->
      board\setRotation Vector { x: 45, y: 90, z: 135 }
      assert.are.same { 45, 90, 135 }, api.rotation

  describe ":destroy()", ->

    it "throws an error if the API context has not been defined", ->
      board = Board!
      assert.has.error ->
        board.destroy!

    it "calls the destruct() API method to delete the parent object", ->
      call = spy.on api, "destruct"
      board\destroy!
      call\revert!
      assert.spy(call).was.called!

    it "sets the context reference to nil so that future calls throw an appropriate error", ->
      board\destroy!
      assert.is.Nil board.context

  describe ":sendToPlayer()", ->

    it "throws an error if attempting to send to an invalid player", ->
      board = Board { context: api, tableType: TableTypes.SQUARE }
      assert.has.error ->
        board\sendToPlayer 2

    it "sends the Board to the correct player's seat", ->
      board = Board { context: api, tableType: TableTypes.SQUARE, offset: Transform! }
      board\sendToPlayer 4
      assert.about.equal -23.455, api.position[1]
      assert.about.equal 1, api.position[2]
      assert.about.equal 0, api.position[3]
      assert.about.equal 0, api.rotation[1]
      assert.about.equal 270, api.rotation[2]
      assert.about.equal 0, api.rotation[3]

    it "incorporates the Board's offset Transform if there is one", ->
      board = Board { context: api, tableType: TableTypes.SQUARE, offset: Transform { zPos: 6 } }
      board\sendToPlayer 1
      assert.about.equal 0, api.position[1]
      assert.about.equal 1, api.position[2]
      assert.about.equal -29.455, api.position[3]
      assert.about.equal 0, api.rotation[1]
      assert.about.equal 180, api.rotation[2]
      assert.about.equal 0, api.rotation[3]

      board\sendToPlayer 4
      assert.about.equal -29.455, api.position[1]
      assert.about.equal 1, api.position[2]
      assert.about.equal 0, api.position[3]
      assert.about.equal 0, api.rotation[1]
      assert.about.equal 270, api.rotation[2]
      assert.about.equal 0, api.rotation[3]

    it "incorporates the Board's height correctly if its widthRatio is not the default", ->
      board = Board { context: api, tableType: TableTypes.SQUARE, offset: Transform!, widthRatio: 2.5 }
      board\sendToPlayer 9
      assert.about.equal 17.98, api.position[1]
      assert.about.equal 1, api.position[2]
      assert.about.equal 0, api.position[3]
      assert.about.equal 0, api.rotation[1]
      assert.about.equal 90, api.rotation[2]
      assert.about.equal 0, api.rotation[3]

    it "incorporates the Board's angle towards the player if one is included in the offset", ->
      board = Board { context: api, tableType: TableTypes.SQUARE, offset: Transform { xRot: 45 } }
      board\sendToPlayer 1
      assert.about.equal 0, api.position[1]
      assert.about.equal 1, api.position[2]
      assert.about.equal -23.455, api.position[3]
      assert.about.equal 45, api.rotation[1]
      assert.about.equal 180, api.rotation[2]
      assert.about.equal 0, api.rotation[3]
