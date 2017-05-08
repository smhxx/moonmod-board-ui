describe "TableTypes", ->

  use "./libraries/moonmod-core/dist/moonmod-core.lua"

  dist ->
    use "./dist/moonmod-board-ui.lua"

  source ->
    use "./src/table/Table.moon"
    use "./src/table/RadialTable.moon"
    use "./src/table/GridTable.moon"
    use "./src/table/TableTypes.moon"

  it "enumerates the types of Table available in the game", ->
    assert.is.a.table TableTypes
    expectEntry = (name, type) ->
      assert.contains.key name, TableTypes
      assert.is.of.class type, TableTypes[name]
    expectEntry "SQUARE", RadialTable
    expectEntry "HEXAGON", RadialTable
    expectEntry "OCTAGON", RadialTable
    expectEntry "ROUND", RadialTable
    expectEntry "POKER", GridTable
    expectEntry "RECTANGLE", GridTable
    expectEntry "ROUND_GLASS", RadialTable
    expectEntry "CUSTOM_SQUARE", GridTable
    expectEntry "CUSTOM_RECTANGLE", GridTable
