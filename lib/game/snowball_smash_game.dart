// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:forge2d/src/settings.dart' as physics_settings;
import 'package:logging/logging.dart';
import 'package:ricochlime/flame/ticker.dart';
import 'package:ricochlime/game/background/winter_background.dart';
import 'package:ricochlime/game/components/aim_guide.dart';
import 'package:ricochlime/game/components/ice_block.dart';
import 'package:ricochlime/game/components/player.dart';
import 'package:ricochlime/game/components/snowball.dart';
import 'package:ricochlime/game/components/snowman.dart';
import 'package:ricochlime/game/components/walls.dart';
import 'package:ricochlime/game/effects/snow_poof_effect.dart';
import 'package:ricochlime/game/game_state.dart';
import 'package:ricochlime/game/level_manager.dart';
import 'package:ricochlime/game/models/snowman_config.dart';
import 'package:ricochlime/utils/audio/snowball_audio.dart';
import 'package:ricochlime/utils/constants/snowball_palette.dart';
import 'package:ricochlime/utils/stows.dart';

/// The core Snowball Smash Flame game.
class SnowballSmashGame extends Forge2DGame
    with PanDetector, TapCallbacks, MouseMovementDetector, SingleGameInstance {
  SnowballSmashGame._() : super(gravity: Vector2(0, 16.0), zoom: 1.0) {
    physics_settings.maxTranslation = Snowball.speed;
  }

  static final instance = SnowballSmashGame._();
  static final log = Logger('SnowballSmashGame');

  static const double arenaWidth = 128.0;
  static double arenaHeight = 213.33;

  double get bottomBoundaryY => arenaHeight + 8.0;

  List<ArenaWall> _walls = [];
  double _lastWallHeight = 0.0;

  /// Routes all game components to [world] so they are rendered through
  /// the CameraComponent and scaled to fill the entire screen edge-to-edge.
  @override
  FutureOr<void> add(Component component) {
    if (component is CameraComponent || component is Forge2DWorld) {
      return super.add(component);
    }
    return world.add(component);
  }

  @override
  Future<void> addAll(Iterable<Component> components) {
    return world.addAll(components);
  }

  @override
  void remove(Component component) {
    world.remove(component);
  }

  @override
  void removeWhere(bool Function(Component) test) {
    world.children.where(test).toList().forEach((c) => c.removeFromParent());
    super.removeWhere(test);
  }

  void _setupBoundaries() {
    if ((_lastWallHeight - arenaHeight).abs() < 0.1 && _walls.isNotEmpty) {
      return;
    }
    _lastWallHeight = arenaHeight;
    for (final wall in _walls) {
      wall.removeFromParent();
    }
    _walls = createArenaBoundaries(
      arenaWidth,
      arenaHeight,
      includeBottom: false,
    );
    _walls.forEach(world.add);
  }

  /// Adapts arenaHeight and viewfinder zoom so the game world fills the entire
  /// screen edge-to-edge with no letterboxing or gaps.
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x <= 0 || size.y <= 0) return;

    final zoom = size.x / arenaWidth;
    arenaHeight = size.y / zoom;

    camera.viewfinder.zoom = zoom;
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    if (isLoaded) {
      _setupBoundaries();
      player.position = Vector2(arenaWidth * 0.5, arenaHeight - 16.0);
    }
  }

  final ValueNotifier<SnowballGameState> state = ValueNotifier(
    SnowballGameState.idle,
  );
  final LevelManager levelManager = LevelManager();
  final SnowballAudio audio = SnowballAudio();
  final Ticker ticker = Ticker();
  final ValueNotifier<double> timeDilation = ValueNotifier(1.0);

  late final Player player;
  late final AimGuide aimGuide;
  late final WinterBackground background;

  bool get isAimAllowed => state.value.isAimAllowed;
  bool _turnCancelled = false;
  List<SnowmanSpawnConfig> _pendingReinforcements = [];

  // Screen shake variables
  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;
  final Random _random = Random();

  // Callbacks for UI overlays
  VoidCallback? onLevelComplete;
  VoidCallback? onGameOver;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    if (size.x > 0 && size.y > 0) {
      final zoom = size.x / arenaWidth;
      arenaHeight = size.y / zoom;
      camera.viewfinder.zoom = zoom;
    }

    // 1. Background
    background = WinterBackground();
    world.add(background);

    // 2. Arena boundaries (walls on top, left, right; open bottom)
    _setupBoundaries();

    // 3. Player at bottom center
    player = Player(
      initialPosition: Vector2(arenaWidth * 0.5, arenaHeight - 16.0),
    );
    world.add(player);

    // 4. Aim guide
    aimGuide = AimGuide();
    world.add(aimGuide);

    // 5. Pre-warm the Forge2D physics world
    _warmUpPhysics();

    // 6. Initialize current level from storage
    await stows.currentLevel.waitUntilRead();
    final savedLevel = stows.currentLevel.value;
    loadLevel(savedLevel);
  }

  /// Creates a temporary static body to pre-warm Forge2D's broad-phase.
  void _warmUpPhysics() {
    try {
      final shape = CircleShape()..radius = 1.0;
      final fixtureDef = FixtureDef(shape);
      final bodyDef = BodyDef(
        position: Vector2(arenaWidth / 2, arenaHeight / 2),
        type: BodyType.static,
      );
      final warmBody = world.createBody(bodyDef)..createFixture(fixtureDef);
      world.destroyBody(warmBody);
    } catch (_) {
      // Silently ignore — warm-up is best-effort.
    }
  }

  /// Loads and spawns the specified level.
  void loadLevel(int levelNumber) {
    _turnCancelled = true;
    _clearLevelEntities();

    levelManager.loadLevel(levelNumber);
    final config = levelManager.currentLevelConfig;
    _pendingReinforcements = List.from(config.reinforcements);

    // Spawn obstacles (ice blocks)
    for (final obs in config.obstacles) {
      world.add(IceBlock(initialPosition: obs.position, blockSize: obs.size));
    }

    // Spawn snowmen
    for (final spawn in config.snowmen) {
      world.add(
        Snowman(
          id: spawn.id,
          initialPosition: spawn.position,
          maxHp: spawn.maxHp,
          type: spawn.type,
          rewardCoins: spawn.rewardCoins,
          rewardSnowballs: spawn.rewardSnowballs,
        ),
      );
    }

    player.resetIdle();
    timeDilation.value = 1.0;
    _turnCancelled = false;
    state.value = SnowballGameState.idle;
  }

  void _clearLevelEntities() {
    world.children.whereType<Snowman>().toList().forEach(
      (s) => s.removeFromParent(),
    );
    world.children.whereType<IceBlock>().toList().forEach(
      (i) => i.removeFromParent(),
    );
    world.children.whereType<Snowball>().toList().forEach(
      (b) => b.removeFromParent(),
    );
  }

  /// Dismisses active gameplay, clears entities, and resets state to idle.
  /// Used when leaving the play screen so the next entry starts a completely fresh level.
  void dismissGame() {
    _turnCancelled = true;
    _clearLevelEntities();
    _pendingReinforcements.clear();
    aimGuide.finishAim();
    aimGuide.lastMousePosition = null;
    player.resetIdle();
    timeDilation.value = 1.0;
    state.value = SnowballGameState.idle;
  }

  void restartCurrentLevel() {
    loadLevel(levelManager.currentLevel);
  }

  void advanceToNextLevel() {
    levelManager.nextLevel();
    loadLevel(levelManager.currentLevel);
  }

  /// Called by Snowman when it is destroyed.
  /// Returns true if a bonus snowball was awarded on this throw.
  bool onSnowmanDestroyed(Snowman snowman) {
    final spawnConfig = SnowmanSpawnConfig(
      id: snowman.id,
      type: snowman.type,
      position: snowman.initialPosition,
      maxHp: snowman.maxHp,
      rewardCoins: snowman.rewardCoins,
      rewardSnowballs: snowman.rewardSnowballs,
    );
    final earnedSnowball = levelManager.onSnowmanDestroyed(spawnConfig);
    audio.playPoof();
    return earnedSnowball;
  }

  /// Triggers a screen shake effect.
  void triggerScreenShake({double intensity = 2.0}) {
    _shakeIntensity = intensity;
    _shakeTimer = 0.16;
  }

  @override
  void update(double dt) {
    // Skip frames that are too large (first frame, background wake, etc.)
    // to prevent physics from taking too long and causing ANR.
    if (dt > 0.1) return;
    dt = dt * timeDilation.value;

    ticker.tick(dt);
    super.update(dt);

    // Screen shake update
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      if (_shakeTimer <= 0) {
        camera.viewfinder.position = Vector2.zero();
      } else {
        final offsetX = (_random.nextDouble() * 2 - 1) * _shakeIntensity;
        final offsetY = (_random.nextDouble() * 2 - 1) * _shakeIntensity;
        camera.viewfinder.position = Vector2(offsetX, offsetY);
      }
    }
  }

  @override
  Color backgroundColor() => SnowballPalette.snowGround;

  // --- Input Handlers ---

  /// Converts a screen-pixel position (from widget events) into world coordinates,
  /// accounting for the camera zoom and centering applied in [onGameResize].
  Vector2 _toWorld(Vector2 screenPos) {
    return camera.globalToLocal(screenPos);
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (!isAimAllowed) return;
    state.value = SnowballGameState.aiming;
    aimGuide.aim(_toWorld(info.eventPosition.widget));
    player.playAiming(aimGuide.aimDetails?.unitDir);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    aimGuide.lastMousePosition = _toWorld(info.eventPosition.widget);
    if (!isAimAllowed) return;
    if (state.value != SnowballGameState.aiming) {
      state.value = SnowballGameState.aiming;
    }
    aimGuide.aim(_toWorld(info.eventPosition.widget));
    player.playAiming(aimGuide.aimDetails?.unitDir);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    aimGuide.lastMousePosition = null;
    if (state.value == SnowballGameState.aiming ||
        (isAimAllowed && aimGuide.aimDetails != null)) {
      _executeTurn();
    } else {
      aimGuide.finishAim();
      player.resetIdle();
      if (isAimAllowed) {
        state.value = SnowballGameState.idle;
      }
    }
  }

  @override
  void onPanCancel() {
    aimGuide.lastMousePosition = null;
    aimGuide.finishAim();
    player.resetIdle();
    if (isAimAllowed) {
      state.value = SnowballGameState.idle;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Tap to speed up while shooting
    if (state.value == SnowballGameState.shooting) {
      timeDilation.value = min(3.0, timeDilation.value + 0.5);
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final worldPos = _toWorld(info.eventPosition.widget);
      aimGuide.lastMousePosition = worldPos;
      if (isAimAllowed) {
        aimGuide.aim(worldPos);
        player.playAiming(aimGuide.aimDetails?.unitDir);
      }
    }
  }

  /// Launches the snowballs and executes the turn sequence.
  Future<void> _executeTurn() async {
    final aimDir = aimGuide.finishAim();
    if (aimDir == null) {
      player.resetIdle();
      if (isAimAllowed) {
        state.value = SnowballGameState.idle;
      }
      return;
    }

    final snowballCount = levelManager.availableSnowballs.value;
    if (snowballCount <= 0) {
      player.resetIdle();
      if (isAimAllowed) {
        state.value = SnowballGameState.idle;
      }
      return;
    }

    state.value = SnowballGameState.shooting;
    player.playThrow();
    audio.playThrow();
    levelManager.snowballEarnedThisTurn = false;
    levelManager.bonusSnowballsThisTurn = 0;

    if (_turnCancelled) return;

    final snowballs = <Snowball>[];
    final selectedType = _getSelectedSnowballType();

    try {
      // 1. Launch snowballs sequentially
      for (var i = 0; i < snowballCount; i++) {
        if (_turnCancelled) return;

        final snowball = Snowball(
          initialPosition: player.position + Vector2(0, -player.size.y),
          direction: aimDir,
          type: selectedType,
        );
        snowballs.add(snowball);
        add(snowball);

        await ticker.delayed(const Duration(milliseconds: 65));
        if (_turnCancelled) return;
      }

      // 2. Wait until all active snowballs have left or reached max lifetime
      var elapsed = 0.0;
      const timeoutSecs = 35.0;
      await for (final tick in ticker.onTick) {
        if (_turnCancelled) return;
        elapsed += tick;

        if (snowballs.every((s) => s.parent == null)) break;
        if (elapsed >= timeoutSecs) {
          // Force remove stuck snowballs
          for (final s in snowballs) {
            if (s.parent != null) s.removeFromParent();
          }
          break;
        }
      }

      if (_turnCancelled) return;

      // 3. Resolve turn
      state.value = SnowballGameState.resolvingTurn;
      timeDilation.value = 1.0;
      levelManager.resolveTurnResources();

      // Check level completion
      if (levelManager.isLevelCompleted) {
        _handleLevelComplete();
        return;
      }

      // 4. Downward movement & reinforcements (for level 5+)
      final config = levelManager.currentLevelConfig;
      if (config.hasDownwardMovement) {
        state.value = SnowballGameState.movingSnowmen;
        final aliveSnowmen = world.children
            .whereType<Snowman>()
            .where((s) => !s.isDead)
            .toList();

        for (final s in aliveSnowmen) {
          s.moveDown(config.downwardMoveDistance);
        }

        await ticker.delayed(const Duration(milliseconds: 550));
        if (_turnCancelled) return;

        // Spawn reinforcement wave if available from top
        if (_pendingReinforcements.isNotEmpty) {
          final countToSpawn = min(3, _pendingReinforcements.length);
          final spawnBatch = _pendingReinforcements.take(countToSpawn).toList();
          _pendingReinforcements.removeRange(0, countToSpawn);

          for (final spawn in spawnBatch) {
            world.add(SnowPoofEffect(position: spawn.position, radius: 10.0));
            world.add(
              Snowman(
                id: spawn.id,
                initialPosition: spawn.position,
                maxHp: spawn.maxHp,
                type: spawn.type,
                rewardCoins: spawn.rewardCoins,
                rewardSnowballs: spawn.rewardSnowballs,
              ),
            );
          }
          audio.playPoof();
          await ticker.delayed(const Duration(milliseconds: 250));
          if (_turnCancelled) return;
        }

        // Check danger condition (Game Over only occurs if a snowman crosses danger line!)
        final allCurrentSnowmen = world.children
            .whereType<Snowman>()
            .where((s) => !s.isDead)
            .toList();
        final dangerReached = allCurrentSnowmen.any(
          (s) => s.body.position.y >= config.dangerLineY,
        );

        if (dangerReached) {
          _handleGameOver();
          return;
        }
      }

      // Check level completion once more in case deferred kills happened
      if (levelManager.isLevelCompleted) {
        _handleLevelComplete();
        return;
      }

      // Return to idle for the next turn
      player.resetIdle();
      state.value = SnowballGameState.idle;
    } finally {
      if (state.value != SnowballGameState.gameOver &&
          state.value != SnowballGameState.levelComplete) {
        state.value = SnowballGameState.idle;
      }
    }
  }

  SnowballType _getSelectedSnowballType() {
    switch (stows.selectedSnowball.value) {
      case 'ice_crystal':
        return SnowballType.iceCrystal;
      case 'fireball':
        return SnowballType.fireball;
      case 'gift_box':
        return SnowballType.giftBox;
      case 'normal':
      default:
        return SnowballType.normal;
    }
  }

  void _handleLevelComplete() {
    state.value = SnowballGameState.levelComplete;
    player.playCelebration();
    audio.playCelebration();
    onLevelComplete?.call();
  }

  void _handleGameOver() {
    state.value = SnowballGameState.gameOver;
    audio.playGameOver();
    onGameOver?.call();
  }
}
