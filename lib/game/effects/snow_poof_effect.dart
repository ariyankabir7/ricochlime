// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class _PoofBubble {
  _PoofBubble({
    required this.offset,
    required this.maxRadius,
    required this.delay,
  });
  Offset offset;
  double maxRadius;
  double delay;
}

/// A soft expanding and dissipating snow poof for snowman destruction.
class SnowPoofEffect extends PositionComponent {
  SnowPoofEffect({
    required Vector2 position,
    double radius = 12.0,
    this.duration = 0.55,
  }) : super(position: position, anchor: Anchor.center, priority: 60) {
    final random = Random();
    // Create multiple overlapping cloud bubbles
    _bubbles.add(
      _PoofBubble(offset: Offset.zero, maxRadius: radius, delay: 0.0),
    );
    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi + random.nextDouble() * 0.4;
      final dist = radius * (0.3 + random.nextDouble() * 0.4);
      _bubbles.add(
        _PoofBubble(
          offset: Offset(cos(angle) * dist, sin(angle) * dist),
          maxRadius: radius * (0.5 + random.nextDouble() * 0.4),
          delay: random.nextDouble() * 0.1,
        ),
      );
    }
  }

  final double duration;
  double _elapsed = 0.0;
  final List<_PoofBubble> _bubbles = [];

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final bubble in _bubbles) {
      if (_elapsed < bubble.delay) continue;
      final localElapsed = _elapsed - bubble.delay;
      final progress = (localElapsed / (duration - bubble.delay)).clamp(
        0.0,
        1.0,
      );
      final currentRadius =
          bubble.maxRadius * (0.4 + 0.6 * sin(progress * pi / 2));
      final alpha = (1.0 - progress).clamp(0.0, 1.0) * 0.85;

      // Outer cloud body
      canvas.drawCircle(
        bubble.offset,
        currentRadius,
        Paint()
          ..color = const Color(0xFFE8F4FC).withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
      // Soft highlight
      canvas.drawCircle(
        bubble.offset - const Offset(0.5, 0.5),
        currentRadius * 0.6,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.9)
          ..style = PaintingStyle.fill,
      );
    }
  }
}
