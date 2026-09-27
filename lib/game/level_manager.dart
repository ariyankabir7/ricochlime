import 'package:flutter/foundation.dart';
import 'package:ricochlime/game/models/level_config.dart';
import 'package:ricochlime/game/models/snowman_config.dart';
import 'package:ricochlime/utils/stows.dart';

/// Manages level progression, snowballs resource, and win/loss rules.
class LevelManager {
  LevelManager({int initialLevel = 1}) {
    loadLevel(initialLevel);
  }

  late LevelConfig _currentLevelConfig;
  LevelConfig get currentLevelConfig => _currentLevelConfig;

  int get currentLevel => _currentLevelConfig.levelNumber;

  /// Available snowballs for the current/upcoming turn.
  final ValueNotifier<int> availableSnowballs = ValueNotifier(3);

  /// Bonus snowballs earned during the current turn.
  int bonusSnowballsThisTurn = 0;

  /// Coins and snowballs earned in the current level session.
  int coinsEarnedThisLevel = 0;
  int snowballsEarnedThisLevel = 0;

  /// Remaining alive snowmen in the level.
  final ValueNotifier<int> remainingSnowmen = ValueNotifier(0);
  int totalSnowmen = 0;

  /// Loads a level by number.
  void loadLevel(int levelNumber) {
    _currentLevelConfig = LevelConfig.fromNumber(levelNumber);
    availableSnowballs.value = _currentLevelConfig.startingSnowballs;
    bonusSnowballsThisTurn = 0;
    coinsEarnedThisLevel = 0;
    snowballsEarnedThisLevel = 0;
    totalSnowmen = _currentLevelConfig.totalSnowmen;
    remainingSnowmen.value = totalSnowmen;
  }

  /// Called whenever a snowman is defeated.
  void onSnowmanDestroyed(SnowmanSpawnConfig config) {
    bonusSnowballsThisTurn += config.rewardSnowballs;
    snowballsEarnedThisLevel += config.rewardSnowballs;
    coinsEarnedThisLevel += config.rewardCoins;
    stows.addCoins(config.rewardCoins);

    remainingSnowmen.value =
        (remainingSnowmen.value - 1).clamp(0, totalSnowmen);
  }

  /// Resolves turn resource rewards.
  void resolveTurnResources() {
    if (bonusSnowballsThisTurn > 0) {
      availableSnowballs.value += bonusSnowballsThisTurn;
      bonusSnowballsThisTurn = 0;
    }
  }

  /// Advance to the next level.
  void nextLevel() {
    final next = currentLevel + 1;
    stows.currentLevel.value = next;
    if (next > stows.highestLevelUnlocked.value) {
      stows.highestLevelUnlocked.value = next;
    }
    loadLevel(next);
  }

  /// Restarts the current level.
  void restartLevel() {
    loadLevel(currentLevel);
  }

  /// Whether all snowmen in the level are defeated.
  bool get isLevelCompleted => remainingSnowmen.value <= 0;
}
