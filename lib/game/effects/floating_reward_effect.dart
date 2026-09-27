// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Floating text effect that drifts upward and fades out.
class FloatingRewardEffect extends PositionComponent {
  FloatingRewardEffect({
    required Vector2 position,
    required this.text,
    this.color = const Color(0xFFFFD54F),
    this.duration = 1.0,
  }) : super(position: position, anchor: Anchor.center, priority: 100);

  final String text;
  final Color color;
  final double duration;

  double _elapsed = 0.0;
  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    // Drift upward
    position.y -= dt * 14.0;

    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (_elapsed / duration)).clamp(0.0, 1.0);
    _textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: 7.0,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: opacity),
            blurRadius: 2,
            offset: const Offset(0.5, 0.5),
          ),
        ],
      ),
    );
    _textPainter.layout();
    _textPainter.paint(
      canvas,
      Offset(-_textPainter.width / 2, -_textPainter.height / 2),
    );
  }
}
