describe "Table", ->

  use "./libraries/moonmod-core/dist/moonmod-core.lua"

  dist ->
    use "./dist/moonmod-board-ui.lua"

  source ->
    use "./src/table/Table.moon"

  describe ":new()", ->

    it "takes the provided table of player IDs", ->
      players = { }
      table = Table { :players }
      assert.equal players, table.players

    it "creates an empty array for the player seat Transforms", ->
      table = Table { players: { } }
      assert.are.same { }, table.transforms

    it "calls calculateSeatTransform to populate its Transforms table", ->
      cst = stub Table.__base, "calculateSeatTransform"
      options = { players: { 1, 2, 4 } }
      table = Table options
      cst\revert!
      assert.stub(cst).was.called.with table, 1, options
      assert.stub(cst).was.called.with table, 2, options
      assert.stub(cst).was.called.with table, 3, options
      assert.stub(cst).was.not.called.with table, 4, options

  describe ":calculateSeatTransform()", ->

    it "throws an error if called directly (not from a subclass)", ->
      assert.has.error ->
        Table.calculateSeatTransform { }
