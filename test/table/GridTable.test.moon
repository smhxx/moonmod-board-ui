describe "GridTable", ->

  use "./libraries/moonmod-core/dist/moonmod-core.lua"

  dist ->
    use "./dist/moonmod-board-ui.lua"

  source ->
    use "./src/table/Table.moon"
    use "./src/table/GridTable.moon"

  describe ":new()", ->

    it "calls the Table superconstructor with its options", ->
      super = stub Table, "__init"
      options = { }
      table = GridTable options
      super\revert!
      assert.stub(super).was.called.with table, options

    it "creates an empty array for the player seat Transforms", ->
      table = GridTable { players: { } }
      assert.are.same { }, table.transforms

  describe ":calculateSeatTransform", ->

    it "creates a Transform representing the position & rotation of the player's hand", ->
      options = {
        players: { 1, 2, 3, 4 }
        locations: {
          { 1, 1 }
          { 2, 3 }
          { 2, 2 }
          { 3, 1 }
        }
        rowPos: { 1, 2, 3, 4 }
        colPos: { 4, 3, 2, 1 }
        rowRot: { 45, 90, 135, 270 }
        colRot: { 90, 90, 90, 90 }
      }
      table = GridTable options
      transform = table\calculateSeatTransform(3, options)
      assert.equals 3, transform.position.data.x
      assert.equals Table.boardHeight, transform.position.data.y
      assert.equals 2, transform.position.data.z
      assert.equals 0, transform.rotation.data.x
      assert.equals 180, transform.rotation.data.y
      assert.equals 0, transform.rotation.data.z
