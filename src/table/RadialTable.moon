export class RadialTable extends Table
  new: (options) =>
    super options

  calculateSeatTransform: (index, options) =>
    angle = @calculateSeatDirection(index, #@players)
    Transform {
      xPos: options.radius * math.sin math.rad angle
      yPos: @@boardHeight
      zPos: options.radius * math.cos math.rad angle
      yRot: angle
    }

  calculateSeatDirection: (index, numPlayers) =>
    ((360 * (index - 1) / numPlayers) + 180) % 360
