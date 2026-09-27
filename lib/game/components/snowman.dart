// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:ricochlime/game/components/health_bar.dart';
import 'package:ricochlime/game/components/snowball.dart';
import 'package:ricochlime/game/effects/floating_reward_effect.dart';
import 'package:ricochlime/game/effects/snow_burst_effect.dart';
import 'package:ricochlime/game/effects/snow_poof_effect.dart';
import 'package:ricochlime/game/models/snowman_config.dart';
import 'package:ricochlime/game/snowball_smash_game.dart';
import 'package:ricochlime/utils/constants/snowball_palette.dart';

/// Snowman lifecycle states.
enum SnowmanState { idle, hit, heavyDamage, dying, destroyed }

/// A snowman enemy component with Forge2D collision body, animated visuals, and HP tracking.
/// Supports configurable types: red, blue, green with full animation states:
/// IDLE, HIT, HEAVY DAMAGE, and DESTRUCTION.
class Snowman extends BodyComponent with ContactCallbacks {
  Snowman({
    required this.id,
    required this.initialPosition,
    required this.maxHp,
    int? currentHp,
    this.type = SnowmanType.basic,
    this.rewardCoins = 10,
    this.rewardSnowballs = 1,
  }) : _currentHp = currentHp ?? maxHp,
       super(renderBody: false, priority: 5) {
    _healthBar = HealthBar(
      maxHp: maxHp,
      hp: _currentHp,
      width: 14.0,
      height: 3.0,
    )..position = Vector2(0, -snowmanRadius - 6.0);
    add(_healthBar);
  }

  static const double snowmanRadius = 8.0;

  final String id;
  final Vector2 initialPosition;
  final SnowmanType type;
  final int maxHp;
  final int rewardCoins;
  final int rewardSnowballs;

  int _currentHp;
  int get currentHp => _currentHp;

  SnowmanState state = SnowmanState.idle;
  late final HealthBar _healthBar;

  bool get isDead =>
      _currentHp <= 0 ||
      state == SnowmanState.dying ||
      state == SnowmanState.destroyed;

  // Hit feedback animation
  double _hitFlashTimer = 0.0;
  double _bobbingTimer = 0.0;
  double _dyingTimer = 0.6;

  // Smooth downward movement
  Vector2? _moveStart;
  Vector2? _moveTarget;
  double _moveProgress = 1.0;
  double _moveDuration = 0.6;

  // Sprite animation tickers
  SpriteAnimationTicker? _idleTicker;
  SpriteAnimationTicker? _hitTicker;
  SpriteAnimationTicker? _heavyTicker;
  SpriteAnimationTicker? _destrTicker;

  static final Paint _pixelPaint = Paint()
    ..filterQuality = FilterQuality.none
    ..isAntiAlias = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final color = type.colorKey; // 'red', 'blue', or 'green'

    // 1. Idle animation (4 frames)
    final idleSprites = await Future.wait([
      for (var i = 0; i < 4; i++) Sprite.load('enemies/$color/idle_$i.png'),
    ]);
    final idleAnim = SpriteAnimation.spriteList(
      idleSprites,
      stepTime: 0.22,
      loop: true,
    );
    _idleTicker = idleAnim.createTicker();

    // 2. Hit animation (4 frames)
    final hitSprites = await Future.wait([
      for (var i = 0; i < 4; i++) Sprite.load('enemies/$color/hit_$i.png'),
    ]);
    final hitAnim = SpriteAnimation.spriteList(
      hitSprites,
      stepTime: 0.08,
      loop: false,
    );
    _hitTicker = hitAnim.createTicker();

    // 3. Heavy damage animation (4 frames)
    final heavySprites = await Future.wait([
      for (var i = 0; i < 4; i++) Sprite.load('enemies/$color/heavy_$i.png'),
    ]);
    final heavyAnim = SpriteAnimation.spriteList(
      heavySprites,
      stepTime: 0.18,
      loop: true,
    );
    _heavyTicker = heavyAnim.createTicker();

    // 4. Destruction animation (4 frames)
    final destrSprites = await Future.wait([
      for (var i = 0; i < 4; i++) Sprite.load('enemies/$color/destruction_$i.png'),
    ]);
    final destrAnim = SpriteAnimation.spriteList(
      destrSprites,
      stepTime: 0.14,
      loop: false,
    );
    _destrTicker = destrAnim.createTicker();
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = snowmanRadius;
    final fixtureDef = FixtureDef(
      shape,
      userData: this,
      restitution: 0.8,
      friction: 0.2,
    );

    final bodyDef = BodyDef(
      position: initialPosition.clone(),
      type: BodyType.static,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobbingTimer += dt * 2.5;

    // Handle dying state and destruction animation
    if (state == SnowmanState.dying) {
      if (_destrTicker != null) {
        _destrTicker!.update(dt);
        if (_destrTicker!.done()) {
          state = SnowmanState.destroyed;
          removeFromParent();
        }
      } else {
        _dyingTimer -= dt;
        if (_dyingTimer <= 0) {
          state = SnowmanState.destroyed;
          removeFromParent();
        }
      }
      return;
    }

    // Update hit flash / animation
    if (_hitFlashTimer > 0) {
      _hitFlashTimer -= dt;
      _hitTicker?.update(dt);
      if (_hitFlashTimer <= 0 && state == SnowmanState.hit) {
        state = (_currentHp <= maxHp ~/ 2)
            ? SnowmanState.heavyDamage
            : SnowmanState.idle;
      }
    } else if (state == SnowmanState.heavyDamage) {
      _heavyTicker?.update(dt);
    } else {
      _idleTicker?.update(dt);
    }

    // Update smooth downward movement
    if (_moveProgress < 1.0 && _moveStart != null && _moveTarget != null) {
      _moveProgress = (_moveProgress + dt / _moveDuration).clamp(0.0, 1.0);
      final currentPos = Vector2(
        _moveStart!.x,
        _moveStart!.y +
            (_moveTarget!.y - _moveStart!.y) *
                Curves.easeInOut.transform(_moveProgress),
      );
      body.setTransform(currentPos, 0);

      if (_moveProgress >= 1.0) {
        _moveStart = null;
        _moveTarget = null;
      }
    }
  }

  /// Triggers a downward translation for this snowman.
  void moveDown(
    double distance, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    if (isDead) return;
    _moveStart = body.position.clone();
    _moveTarget = body.position + Vector2(0, distance);
    _moveProgress = 0.0;
    _moveDuration = duration.inMilliseconds / 1000.0;
  }

  /// Applies damage to this snowman.
  void takeDamage(int damage) {
    if (isDead) return;

    _currentHp = max(0, _currentHp - damage);
    _healthBar.hp = _currentHp;

    if (_currentHp <= 0) {
      _die();
      return;
    }

    _hitFlashTimer = 0.25;
    state = SnowmanState.hit;
    _hitTicker?.reset();

    // Spawn impact particles
    if (parent != null) {
      final pos = isMounted ? body.position.clone() : initialPosition.clone();
      parent?.add(SnowBurstEffect(position: pos));
    }

    // Play hit sound
    if (isMounted && game is SnowballSmashGame) {
      (game as SnowballSmashGame).audio.playHit();
    }
  }

  void _die() {
    if (state == SnowmanState.dying || state == SnowmanState.destroyed) return;
    state = SnowmanState.dying;
    if (isMounted) {
      body.setActive(false);
    }
    _healthBar.removeFromParent();

    final deathPos = isMounted ? body.position.clone() : initialPosition.clone();

    // Spawn destruction poof
    if (parent != null) {
      parent?.add(
        SnowPoofEffect(
          position: deathPos,
          radius: snowmanRadius * 1.5,
        ),
      );

      // Spawn reward floating texts
      if (rewardSnowballs > 0) {
        parent?.add(
          FloatingRewardEffect(
            position: deathPos + Vector2(0, -8),
            text: '+$rewardSnowballs Snowball',
            color: const Color(0xFF64B5F6),
          ),
        );
      }
      if (rewardCoins > 0) {
        parent?.add(
          FloatingRewardEffect(
            position: deathPos + Vector2(0, -16),
            text: '+$rewardCoins Coins',
            color: const Color(0xFFFFD54F),
          ),
        );
      }
    }

    // Notify game
    if (isMounted && game is SnowballSmashGame) {
      final smashGame = game as SnowballSmashGame;
      smashGame.onSnowmanDestroyed(this);
      smashGame.triggerScreenShake(intensity: 2.0);
    }

    _destrTicker?.reset();
    _dyingTimer = 0.6;
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (isDead) return;

    if (other is Snowball) {
      takeDamage(other.damage);
    }
  }

  @override
  void render(Canvas canvas) {
    if (state == SnowmanState.destroyed) return;
    super.render(canvas);

    final isFlashing = _hitFlashTimer > 0;
    final scaleSquash = isFlashing ? 0.92 : 1.0;
    final bobY = (state == SnowmanState.dying)
        ? 0.0
        : sin(_bobbingTimer + id.hashCode % 10) * 0.35;

    canvas.save();
    canvas.translate(0, bobY);
    canvas.scale(scaleSquash, 2.0 - scaleSquash);

    final currentTicker = switch (state) {
      SnowmanState.dying => _destrTicker ?? _idleTicker,
      SnowmanState.hit => _hitTicker ?? _idleTicker,
      SnowmanState.heavyDamage => _heavyTicker ?? _idleTicker,
      SnowmanState.idle => _idleTicker,
      SnowmanState.destroyed => null,
    };

    if (currentTicker != null) {
      const drawSize = snowmanRadius * 2.8;
      currentTicker.getSprite().render(
        canvas,
        position: Vector2(-drawSize / 2, -drawSize / 2 - 1.0),
        size: Vector2(drawSize, drawSize),
        overridePaint: _pixelPaint,
      );
    } else {
      _renderFallbackSnowman(canvas, isFlashing);
    }

    canvas.restore();
  }

  void _renderFallbackSnowman(Canvas canvas, bool isFlashing) {
    const bottomRadius = snowmanRadius;
    const topRadius = snowmanRadius * 0.72;
    const topCenterY = -bottomRadius * 0.75;

    final snowPaint = Paint()
      ..color = isFlashing ? Colors.white : SnowballPalette.snowmanWhite
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = isFlashing ? Colors.white : SnowballPalette.snowmanOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Body
    canvas.drawCircle(Offset.zero, bottomRadius, snowPaint);
    canvas.drawCircle(Offset.zero, bottomRadius, outlinePaint);
    // Head
    canvas.drawCircle(Offset(0, topCenterY), topRadius, snowPaint);
    canvas.drawCircle(Offset(0, topCenterY), topRadius, outlinePaint);
  }
}
