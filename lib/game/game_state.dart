/// The current state of the Snowball Smash gameplay loop.
enum SnowballGameState {
  /// Waiting for player input (aiming allowed).
  idle,

  /// Player is currently dragging to aim.
  aiming,

  /// Snowballs are actively being launched and flying around the arena.
  shooting,

  /// Waiting for snowballs to finish and tallying turn rewards.
  resolvingTurn,

  /// Surviving snowmen are moving downward towards the danger line.
  movingSnowmen,

  /// All snowmen in the level have been defeated. Celebration active!
  levelComplete,

  /// A snowman crossed the danger line.
  gameOver,

  /// The game is paused.
  paused,
}

extension SnowballGameStateX on SnowballGameState {
  bool get isAimAllowed =>
      this == SnowballGameState.idle || this == SnowballGameState.aiming;
  bool get isInteractive =>
      this == SnowballGameState.idle || this == SnowballGameState.aiming;
  bool get isFinished =>
      this == SnowballGameState.levelComplete ||
      this == SnowballGameState.gameOver;
}
