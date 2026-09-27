// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:ricochlime/game/snowball_smash_game.dart';

/// Supported snowball types for extensibility.
enum SnowballType { normal, iceCrystal, fireball, giftBox }

/// A physical snowball projectile simulated with Forge2D.
class Snowball extends BodyComponent with ContactCallbacks {
  Snowball({
    required this.initialPosition,
    required this.direction,
    this.type = SnowballType.normal,
    this.damage = 1,
  }) : assert(direction.y < 0, 'Snowball must be shot upwards'),
       super(renderBody: false);

  /// Radius of the snowball in world units.
  static const double radius = 2.4;

  /// Initial speed of the projectile.
  static const double speed = radius * 90;

  final Vector2 initialPosition;
  final Vector2 direction;
  final SnowballType type;
  final int damage;

  double lifetime = 0.0;
  static const double maxLifetime = 45.0;

  /// Trail positions for snow particle effect.
  final List<Vector2> _trail = [];
  double _timeSinceLastTrail = 0.0;

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      userData: this,
      restitution: 1.0,
      friction: 0.0,
      filter: Filter()
        ..categoryBits = 1 << 2
        ..maskBits = 0xFFFF & ~(1 << 2), // Don't collide with other snowballs
    );

    final velocity = direction * speed;
    final bodyDef = BodyDef(
      position: initialPosition.clone(),
      linearVelocity: velocity,
      angularVelocity: 4 * pi,
      type: BodyType.dynamic,
      bullet: true,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifetime += dt;

    if (lifetime > maxLifetime) {
      removeFromParent();
      return;
    }

    // Check bottom boundary exit
    if (game is SnowballSmashGame) {
      final smashGame = game as SnowballSmashGame;
      if (body.position.y > smashGame.bottomBoundaryY) {
        removeFromParent();
        return;
      }
    } else if (body.position.y > 220) {
      removeFromParent();
      return;
    }

    // Record trail
    _timeSinceLastTrail += dt;
    if (_timeSinceLastTrail >= 0.02) {
      _timeSinceLastTrail = 0.0;
      _trail.add(body.position.clone());
      if (_trail.length > 6) {
        _trail.removeAt(0);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw trail
    for (var i = 0; i < _trail.length; i++) {
      final trailPos = _trail[i] - body.position;
      final alpha = ((i + 1) / _trail.length) * 0.45;
      final trailRadius = radius * (0.3 + 0.5 * (i / _trail.length));
      final trailPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(trailPos.x, trailPos.y),
        trailRadius,
        trailPaint,
      );
    }

    // Render the snowball according to type
    drawSnowball(canvas, Offset.zero, radius: radius, type: type);
  }

  /// Static helper to draw a snowball at any offset.
  static void drawSnowball(
    Canvas canvas,
    Offset offset, {
    double radius = radius,
    SnowballType type = SnowballType.normal,
    double opacity = 1.0,
  }) {
    switch (type) {
      case SnowballType.normal:
        // Soft drop shadow
        canvas.drawCircle(
          offset + const Offset(0.3, 0.4),
          radius,
          Paint()
            ..color = const Color(0x33000000).withValues(alpha: 0.2 * opacity),
        );
        // Base sphere (cool white)
        canvas.drawCircle(
          offset,
          radius,
          Paint()..color = const Color(0xFFE6F3FB).withValues(alpha: opacity),
        );
        // Inner highlight
        canvas.drawCircle(
          offset - const Offset(0.5, 0.5),
          radius * 0.6,
          Paint()..color = Colors.white.withValues(alpha: opacity),
        );
        // Subtle icy rim
        canvas.drawCircle(
          offset,
          radius,
          Paint()
            ..color = const Color(0xFFB0D5EF).withValues(alpha: 0.6 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );

      case SnowballType.iceCrystal:
        // Ice crystal shape
        final path = Path()
          ..moveTo(offset.dx, offset.dy - radius * 1.1)
          ..lineTo(offset.dx + radius * 0.9, offset.dy)
          ..lineTo(offset.dx, offset.dy + radius * 1.1)
          ..lineTo(offset.dx - radius * 0.9, offset.dy)
          ..close();
        canvas.drawPath(
          path,
          Paint()..color = const Color(0xFF4DD0E1).withValues(alpha: opacity),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.8 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );

      case SnowballType.fireball:
        canvas.drawCircle(
          offset,
          radius * 1.1,
          Paint()
            ..color = const Color(0xFFFF5722).withValues(alpha: 0.8 * opacity),
        );
        canvas.drawCircle(
          offset,
          radius * 0.7,
          Paint()..color = const Color(0xFFFFEB3B).withValues(alpha: opacity),
        );

      case SnowballType.giftBox:
        final rect = Rect.fromCenter(
          center: offset,
          width: radius * 1.8,
          height: radius * 1.8,
        );
        canvas.drawRect(
          rect,
          Paint()..color = const Color(0xFFE53935).withValues(alpha: opacity),
        );
        // Ribbon
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + rect.width * 0.4,
            rect.top,
            rect.width * 0.2,
            rect.height,
          ),
          Paint()..color = const Color(0xFFFFD54F).withValues(alpha: opacity),
        );
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left,
            rect.top + rect.height * 0.4,
            rect.width,
            rect.height * 0.2,
          ),
          Paint()..color = const Color(0xFFFFD54F).withValues(alpha: opacity),
        );
    }
  }

  // Anti-stuck bounce logic
  int horizontalCollisions = 0;
  static const maxHorizontalCollisions = 40;
  static const horizontalVelocityRatio = 0.0524077792830412;

  static bool isVelocityHorizontal(Vector2 velocity) {
    if (velocity.x == 0) return false;
    final ratio = velocity.y / velocity.x;
    return ratio.abs() < horizontalVelocityRatio;
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    if (!body.isActive) return;

    if (isVelocityHorizontal(body.linearVelocity)) {
      horizontalCollisions++;
    } else {
      horizontalCollisions = 0;
    }

    if (horizontalCollisions >= maxHorizontalCollisions) {
      body.linearVelocity.y += speed * horizontalVelocityRatio;
    }
  }
}
