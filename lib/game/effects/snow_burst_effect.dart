// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class _Particle {
  _Particle({
    required this.pos,
    required this.velocity,
    required this.radius,
    required this.color,
  });
  Vector2 pos;
  Vector2 velocity;
  double radius;
  Color color;
}

/// A short radial burst of snow particles upon snowball impact.
class SnowBurstEffect extends PositionComponent {
  SnowBurstEffect({
    required Vector2 position,
    int count = 7,
    this.duration = 0.35,
  }) : super(position: position, anchor: Anchor.center, priority: 50) {
    final random = Random();
    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 15.0 + random.nextDouble() * 30.0;
      _particles.add(
        _Particle(
          pos: Vector2.zero(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          radius: 1.0 + random.nextDouble() * 1.5,
          color: random.nextBool() ? Colors.white : const Color(0xFFD6EDFC),
        ),
      );
    }
  }

  final double duration;
  double _elapsed = 0.0;
  final List<_Particle> _particles = [];

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    for (final p in _particles) {
      p.pos += p.velocity * dt;
      p.velocity *= 0.92; // Friction
    }
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1.0 - (_elapsed / duration)).clamp(0.0, 1.0);
    for (final p in _particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.pos.x, p.pos.y), p.radius * alpha, paint);
    }
  }
}
