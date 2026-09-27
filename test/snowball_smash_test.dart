// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricochlime/game/components/snowball.dart';
import 'package:ricochlime/game/components/snowman.dart';
import 'package:ricochlime/game/level_manager.dart';
import 'package:ricochlime/game/models/level_config.dart';
import 'package:ricochlime/utils/stows.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DummyContact implements Contact {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
      expect(manager.availableSnowballs.value, equals(1));
      expect(manager.remainingSnowmen.value, equals(5));
      expect(manager.isLevelCompleted, isFalse);
    });

    test('Defeating snowmen awards coins and maximum 1 snowball per throw', () {
      final manager = LevelManager(initialLevel: 1);
      final initialCoins = stows.coins.value;

      final snowmanConfig1 = manager.currentLevelConfig.snowmen[0];
      final snowmanConfig2 = manager.currentLevelConfig.snowmen[1];

      // First snowman destroyed awards 1 bonus snowball
      final earned1 = manager.onSnowmanDestroyed(snowmanConfig1);
      expect(earned1, isTrue);
      expect(manager.remainingSnowmen.value, equals(4));
      expect(manager.coinsEarnedThisLevel, equals(snowmanConfig1.rewardCoins));
      expect(stows.coins.value, equals(initialCoins + snowmanConfig1.rewardCoins));

      // Destroying a second snowman in the same throw awards coins but NO additional snowball (capped at 1 per throw)
      final earned2 = manager.onSnowmanDestroyed(snowmanConfig2);
      expect(earned2, isFalse);
      expect(manager.bonusSnowballsThisTurn, equals(1));

      // At turn resolution, exactly 1 snowball is added
      manager.resolveTurnResources();
      expect(manager.availableSnowballs.value, equals(2));
      expect(manager.bonusSnowballsThisTurn, equals(0));
      expect(manager.snowballEarnedThisTurn, isFalse);
    });

    test('Throw with 0 snowmen destroyed awards 0 bonus snowballs', () {
      final manager = LevelManager(initialLevel: 1);
      manager.resolveTurnResources();
      expect(manager.availableSnowballs.value, equals(1));
      expect(manager.snowballsEarnedThisLevel, equals(0));
    });

    test('currentLevelNotifier updates dynamically when loading and advancing levels', () {
      final manager = LevelManager(initialLevel: 1);
      expect(manager.currentLevelNotifier.value, equals(1));

      manager.loadLevel(3);
      expect(manager.currentLevelNotifier.value, equals(3));

      manager.nextLevel();
      expect(manager.currentLevelNotifier.value, equals(4));
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

    test('Danger line condition and reinforcement configuration', () {
      // Level 1 has no downward movement or reinforcements
      final level1 = LevelConfig.fromNumber(1);
      expect(level1.hasDownwardMovement, isFalse);
      expect(level1.reinforcements.isEmpty, isTrue);

      // Level 5 enables downward movement and reinforcements
      final level5 = LevelConfig.fromNumber(5);
      expect(level5.hasDownwardMovement, isTrue);
      expect(level5.reinforcements.isNotEmpty, isTrue);
      expect(level5.dangerLineY, greaterThan(100.0));
      expect(level5.totalSnowmen, equals(level5.snowmen.length + level5.reinforcements.length));
    });

    test('Levels 1 to 10 have valid progressive configurations', () {
      for (var l = 1; l <= 10; l++) {
        final config = LevelConfig.fromNumber(l);
        expect(config.levelNumber, equals(l));
        expect(config.totalSnowmen, greaterThanOrEqualTo(5));
        expect(config.startingSnowballs, equals(l < 5 ? 1 : 2));
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

    test('Snowman safely queues contact damage and applies in update', () {
      final snowman = Snowman(
        id: 'test_contact',
        initialPosition: Vector2(50, 50),
        maxHp: 2,
      );

      final snowball = Snowball(
        initialPosition: Vector2(50, 60),
        direction: Vector2(0, -1),
        damage: 1,
      );

      // Simulate contact without throwing or modifying body during locked physics
      snowman.beginContact(snowball, _DummyContact());
      expect(snowman.currentHp, equals(2), reason: 'Damage should be deferred to update loop');

      // Update frame processes queued damage
      snowman.update(0.016);
      expect(snowman.currentHp, equals(1));

      // Another hit that is fatal
      snowman.beginContact(snowball, _DummyContact());
      snowman.update(0.016);
      expect(snowman.currentHp, equals(0));
      expect(snowman.isDead, isTrue);
      expect(snowman.state, equals(SnowmanState.dying));
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
