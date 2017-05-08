export TableTypes = {
  SQUARE: RadialTable {
    radius: 14.33
    players: { 1, 4, 6, 9 }
  }
  HEXAGON: RadialTable {
    radius: 15.60
    players: { 1, 3, 5, 6, 8, 10 }
  }
  OCTAGON: RadialTable {
    radius: 17.42
    players: { 1, 3, 4, 5, 6, 8, 9, 10 }
  }
  ROUND: RadialTable {
    radius: 21.57
    players: { 1, 3, 4, 5, 6, 8, 9, 10 }
  }
  POKER: GridTable {
    players: { 1, 3, 4, 5, 6, 8, 9, 10 }
    locations: {
      { 1, 2 }
      { 2, 1 }
      { 3, 3 }
      { 3, 4 }
      { 3, 5 }
      { 3, 6 }
      { 2, 8 }
      { 1, 7 }
    }
    rowPos: { -11.43, 5.76, 14.42 }
    colPos: { -34.81, -30.06, -21.66, -6.68, 6.68, 21.66, 30.06, 34.81 }
    rowRot: { 0, 0, 180 }
    colRot: { 293.5, 216.5, 180, 180, 180, 180, 143.5, 66.5 }
  }
  RECTANGLE: GridTable {
    players: { 1, 3, 4, 5, 6, 8, 9, 10 }
    locations: {
      { 1, 3 }
      { 1, 2 }
      { 2, 1 }
      { 3, 1 }
      { 4, 2 }
      { 4, 3 }
      { 3, 4 }
      { 2, 4 }
    }
    rowPos: { -20.12, -8.64, 9.88, 19.81 }
    colPos: { -30.23, -15.17, 15.34, 30.18 }
    rowRot: { 180, 0, 0, 0 }
    colRot: { 270, 0, 0, 90 }
  }
  ROUND_GLASS: RadialTable {
    radius: 24.84
    players: { 1, 3, 4, 5, 6, 8, 9, 10 }
  }
  CUSTOM_SQUARE: GridTable {
    players: { 1, 3, 4, 5, 6, 8, 9, 10 }
    locations: {
      { 1, 3 }
      { 1, 2 }
      { 2, 1 }
      { 3, 1 }
      { 4, 2 }
      { 4, 3 }
      { 3, 4 }
      { 2, 4 }
    }
    rowPos: { -28.58, -9.54, 9.48, 28.67 }
    colPos: { -28.62, -9.90, 10.66, 28.57 }
    rowRot: { 180, 0, 0, 0 }
    colRot: { 270, 0, 0, 90 }
  }
  CUSTOM_RECTANGLE: GridTable {
    players: { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
    locations: {
      { 1, 4 }
      { 1, 3 }
      { 1, 2 }
      { 2, 1 }
      { 3, 1 }
      { 4, 2 }
      { 4, 3 }
      { 4, 4 }
      { 3, 5 }
      { 2, 5 }
    }
    rowPos: { -34.43, -11.73, 11.73, 34.45 }
    colPos: { -51.66, -23.67, 0, 23.67, 51.61 }
    rowRot: { 180, 0, 0, 0 }
    colRot: { 270, 0, 0, 0, 90 }
  }
}
