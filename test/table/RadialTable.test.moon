describe "RadialTable", ->

  use "./libraries/moonmod-core/dist/moonmod-core.lua"

  dist ->
    use "./dist/moonmod-board-ui.lua"

  source ->
    use "./src/table/Table.moon"
    use "./src/table/RadialTable.moon"

  describe ":new()", ->

    it "calls the Table superconstructor with its options", ->
      super = stub Table, "__init"
      options = { }
      table = RadialTable options
      super\revert!
      assert.stub(super).was.called.with table, options

    it "creates an empty array for the player seat Transforms", ->
      table = RadialTable { players: { } }
      assert.are.same { }, table.transforms

  describe ":calculateSeatDirection", ->

    it "returns the y-axis rotation from the player's seat to the center", ->
      table = RadialTable { players: { } }
      assert.equals 180, (table\calculateSeatDirection 1, 4)
      assert.equals 270, (table\calculateSeatDirection 2, 4)
      assert.equals 0, (table\calculateSeatDirection 3, 4)
      assert.equals 90, (table\calculateSeatDirection 4, 4)
      assert.equals 240, (table\calculateSeatDirection 2, 6)
      assert.equals 300, (table\calculateSeatDirection 3, 6)

  describe ":calculateSeatTransform", ->

    it "creates a Transform representing the position & rotation of the player's hand", ->
      options = { radius: (math.sqrt 2), players: { 1, 2, 3, 4, 5, 6, 7, 8 } }
      table = RadialTable options
      transform = table\calculateSeatTransform(6, options)
      assert.about.equal 1, transform.position.data.x
      assert.equal Table.boardHeight, transform.position.data.y
      assert.about.equal 1, transform.position.data.z
      assert.equals 0, transform.rotation.data.x
      assert.equals 45, transform.rotation.data.y
      assert.equals 0, transform.rotation.data.z
