export class Table
  @boardHeight = 1

  new: (options) =>
    @players = options.players
    @transforms = { }
    for i = 1, #@players
      @transforms[@players[i]] = @calculateSeatTransform i, options

  calculateSeatTransform: (index, options) =>
    error "tts-board-ui: Attempt to call abstract method calculateSeatTransform directly."
