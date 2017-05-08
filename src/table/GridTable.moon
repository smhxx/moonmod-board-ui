export class GridTable extends Table
  new: (options) =>
    super options

  calculateSeatTransform: (index, options) =>
    row = options.locations[index][1]
    col = options.locations[index][2]
    Transform {
      xPos: options.colPos[col]
      yPos: @@boardHeight
      zPos: options.rowPos[row]
      yRot: options.rowRot[row] + options.colRot[col]
    }
