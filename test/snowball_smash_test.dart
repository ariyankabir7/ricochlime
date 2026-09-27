// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricochlime/game/components/snowball.dart';
import 'package:ricochlime/game/components/snowman.dart';
import 'package:ricochlime/game/level_manager.dart';
import 'package:ricochlime/game/models/level_config.dart';
import 'package:ricochlime/utils/stows.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    stows.coins.value = 0;
    stows.currentLevel.value = 1;
    stows.highestLevelUnlocked.value = 1;
    stows.selectedCharacter.value = 'default';
    stows.selectedSnowball.value = 'normal';
  });

  group('LevelManager & Level Progression', () {
    test('Level 1 initializes with correct snowman count and snowballs', () {
      final manager = LevelManager(initialLevel: 1);
      expect(manager.currentLevel, equals(1));
      expect(manager.availableSnowballs.value, equals(3));
      expect(manager.remainingSnowmen.value, equals(5));
      expect(manager.isLevelCompleted, isFalse);
    });

    test('Defeating snowmen awards coins and snowballs', () {
      final manager = LevelManager(initialLevel: 1);
      final initialCoins = stows.coins.value;

      final snowmanConfig = manager.currentLevelConfig.snowmen.first;
      manager.onSnowmanDestroyed(snowmanConfig);

      expect(manager.remainingSnowmen.value, equals(4));
      expect(manager.coinsEarnedThisLevel, equals(snowmanConfig.rewardCoins));
      expect(stows.coins.value, equals(initialCoins + snowmanConfig.rewardCoins));

      // Bonus snowballs are queued until turn resolution
      expect(manager.bonusSnowballsThisTurn, equals(snowmanConfig.rewardSnowballs));
      manager.resolveTurnResources();
      expect(
        manager.availableSnowballs.value,
        equals(3 + snowmanConfig.rewardSnowballs),
      );
    });

    test('Defeating all snowmen in Level 1 completes level and allows advancing to Level 2', () {
      final manager = LevelManager(initialLevel: 1);
      for (final snowman in manager.currentLevelConfig.snowmen) {
        manager.onSnowmanDestroyed(snowman);
      }

      expect(manager.remainingSnowmen.value, equals(0));
      expect(manager.isLevelCompleted, isTrue);

      // Advance to Level 2
      manager.nextLevel();
      expect(manager.currentLevel, equals(2));
      expect(stows.currentLevel.value, equals(2));
      expect(stows.highestLevelUnlocked.value, greaterThanOrEqualTo(2));
      expect(manager.remainingSnowmen.value, equals(7));
      expect(manager.isLevelCompleted, isFalse);
    });

    test('Zero snowballs does NOT mark game over or complete', () {
      final manager = LevelManager(initialLevel: 1);
      manager.availableSnowballs.value = 0;
      expect(manager.isLevelCompleted, isFalse);
      expect(manager.remainingSnowmen.value, equals(5));
    });

    test('Danger line condition configuration', () {
      // Level 1 has no downward movement
      final level1 = LevelConfig.fromNumber(1);
      expect(level1.hasDownwardMovement, isFalse);

      // Level 5 enables downward movement
      final level5 = LevelConfig.fromNumber(5);
      expect(level5.hasDownwardMovement, isTrue);
      expect(level5.dangerLineY, greaterThan(100.0));
    });

    test('Levels 1 to 10 have valid progressive configurations', () {
      for (var l = 1; l <= 10; l++) {
        final config = LevelConfig.fromNumber(l);
        expect(config.levelNumber, equals(l));
        expect(config.totalSnowmen, greaterThanOrEqualTo(5));
        expect(config.startingSnowballs, greaterThanOrEqualTo(3));
        expect(config.snowmen.isNotEmpty, isTrue);
      }
    });
  });

  group('Snowman Entity Behavior', () {
    test('Snowman takes damage and updates health', () {
      final snowman = Snowman(
        id: 'test_s1',
        initialPosition: Vector2(50, 50),
        maxHp: 3,
        rewardCoins: 10,
        rewardSnowballs: 1,
      );

      expect(snowman.currentHp, equals(3));
      expect(snowman.isDead, isFalse);

      snowman.takeDamage(1);
      expect(snowman.currentHp, equals(2));
      expect(snowman.state, equals(SnowmanState.hit));

      snowman.takeDamage(2);
      expect(snowman.currentHp, equals(0));
      expect(snowman.isDead, isTrue);
    });
  });

  group('Snowball Projectile Properties', () {
    test('Normal snowball speed, radius, and anti-stuck horizontal ratio', () {
      expect(Snowball.radius, greaterThan(1.0));
      expect(Snowball.speed, greaterThan(Snowball.radius));

      final horizontalVelocity = Vector2(100, 1);
      expect(Snowball.isVelocityHorizontal(horizontalVelocity), isTrue);

      final angledVelocity = Vector2(50, -50);
      expect(Snowball.isVelocityHorizontal(angledVelocity), isFalse);
    });
  });

  group('Persistence and Economy', () {
    test('Coin addition and persistence', () {
      stows.addCoins(250);
      expect(stows.coins.value, equals(250));
      stows.addCoins(100);
      expect(stows.coins.value, equals(350));
    });

    test('Selected character and snowball persistence', () {
      stows.selectedCharacter.value = 'reindeer';
      expect(stows.selectedCharacter.value, equals('reindeer'));

      stows.selectedSnowball.value = 'ice_crystal';
      expect(stows.selectedSnowball.value, equals('ice_crystal'));
    });
  });
}
