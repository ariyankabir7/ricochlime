// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

/// Animation states of the winter boy player (rear-view gameplay camera).
enum PlayerAnimState { idle, aiming, throwing, celebration }

/// The player component positioned at the bottom of the arena during gameplay.
/// Always shows the rear-facing view (camera behind player). Face is never visible during gameplay.
class Player extends PositionComponent {
  Player({Vector2? initialPosition, this.characterSkin = 'default'})
    : super(
        size: Vector2(staticWidth, staticHeight),
        anchor: Anchor.bottomCenter,
        priority: 20,
      ) {
    if (initialPosition != null) {
      position = initialPosition;
    }
  }

  // 280x310 source frame aspect ratio
  static const double staticWidth = 20.0;
  static const double staticHeight = 22.14;

  String characterSkin;
  PlayerAnimState animState = PlayerAnimState.idle;

  Vector2? aimDirection;
  double _throwTimer = 0.0;

  SpriteAnimationTicker? _idleTicker;
  SpriteAnimationTicker? _aimingTicker;
  SpriteAnimationTicker? _throwingTicker;
  SpriteAnimationTicker? _celebrationTicker;

  static final Paint _pixelPaint = Paint()
    ..filterQuality = FilterQuality.none
    ..isAntiAlias = false;

  double get bottomY => position.y;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Idle animation (4 frames)
    final idleSprites = await Future.wait([
      for (var i = 0; i < 4; i++) Sprite.load('player/idle_$i.png'),
    ]);
    final idleAnimation = SpriteAnimation.spriteList(
      idleSprites,
      stepTime: 0.22,
      loop: true,
    );
    _idleTicker = idleAnimation.createTicker();

    // 2. Aiming animation (4 frames)
    final aimingSprites = await Future.wait([
      for (var i = 0; i < 4; i++) Sprite.load('player/aiming_$i.png'),
    ]);
    final aimingAnimation = SpriteAnimation.spriteList(
      aimingSprites,
      stepTime: 0.16,
      loop: true,
    );
    _aimingTicker = aimingAnimation.createTicker();

    // 3. Throwing animation (4 frames)
    final throwingSprites = await Future.wait([
      for (var i = 0; i < 4; i++) Sprite.load('player/throwing_$i.png'),
    ]);
    final throwingAnimation = SpriteAnimation.spriteList(
      throwingSprites,
      stepTime: 0.09,
      loop: false,
    );
    _throwingTicker = throwingAnimation.createTicker();

    // 4. Celebration animation (4 frames)
    final celebrationSprites = await Future.wait([
      for (var i = 0; i < 4; i++) Sprite.load('player/celebration_$i.png'),
    ]);
    final celebrationAnimation = SpriteAnimation.spriteList(
      celebrationSprites,
      stepTime: 0.18,
      loop: true,
    );
    _celebrationTicker = celebrationAnimation.createTicker();
  }

  void playThrow() {
    animState = PlayerAnimState.throwing;
    _throwTimer = 0.45;
    _throwingTicker?.reset();
  }

  void playAiming(Vector2? direction) {
    aimDirection = direction;
    if (animState != PlayerAnimState.celebration &&
        animState != PlayerAnimState.throwing) {
      animState = direction != null
          ? PlayerAnimState.aiming
          : PlayerAnimState.idle;
    }
  }

  void playCelebration() {
    animState = PlayerAnimState.celebration;
    _celebrationTicker?.reset();
  }

  void resetIdle() {
    animState = PlayerAnimState.idle;
    aimDirection = null;
    _throwTimer = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_throwTimer > 0) {
      _throwTimer -= dt;
      if (_throwTimer <= 0 && animState == PlayerAnimState.throwing) {
        animState = PlayerAnimState.idle;
      }
    }

    switch (animState) {
      case PlayerAnimState.idle:
        _idleTicker?.update(dt);
      case PlayerAnimState.aiming:
        _aimingTicker?.update(dt);
      case PlayerAnimState.throwing:
        _throwingTicker?.update(dt);
      case PlayerAnimState.celebration:
        _celebrationTicker?.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final currentTicker = switch (animState) {
      PlayerAnimState.idle => _idleTicker,
      PlayerAnimState.aiming => _aimingTicker,
      PlayerAnimState.throwing => _throwingTicker,
      PlayerAnimState.celebration => _celebrationTicker,
    };

    if (currentTicker != null) {
      currentTicker.getSprite().render(
        canvas,
        position: Vector2.zero(),
        size: size,
        overridePaint: _pixelPaint,
      );
    } else {
      // Safe fallback if sprites are still loading or in headless tests
      _renderFallbackBoy(canvas);
    }
  }

  void _renderFallbackBoy(Canvas canvas) {
    final coatPaint = Paint()..color = const Color(0xFFC62828);
    final hatPaint = Paint()..color = const Color(0xFFC62828);
    final trimPaint = Paint()..color = Colors.white;
    final scarfPaint = Paint()..color = const Color(0xFF1976D2);
    final pantsPaint = Paint()..color = const Color(0xFF1A237E);

    // Rear coat & pants
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.2, size.y * 0.4, size.x * 0.6, size.y * 0.4),
        const Radius.circular(3),
      ),
      coatPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.25, size.y * 0.8, size.x * 0.5, size.y * 0.2),
        const Radius.circular(2),
      ),
      pantsPaint,
    );
    // Rear hat (no face visible!)
    canvas.drawArc(
      Rect.fromLTWH(size.x * 0.25, size.y * 0.05, size.x * 0.5, size.y * 0.35),
      3.14159,
      3.14159,
      true,
      hatPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.22, size.y * 0.25, size.x * 0.56, size.y * 0.08),
        const Radius.circular(2),
      ),
      trimPaint,
    );
    // Scarf at neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.22, size.y * 0.35, size.x * 0.56, size.y * 0.1),
        const Radius.circular(2),
      ),
      scarfPaint,
    );
  }
}
