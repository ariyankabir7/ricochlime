// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ricochlime/utils/constants/snowball_palette.dart';

/// Renders a crisp HP bar with remaining numeric HP above the snowman.
class HealthBar extends PositionComponent {
  HealthBar({
    required this.maxHp,
    required this.hp,
    double width = 16.0,
    double height = 3.5,
  }) : super(
         size: Vector2(width, height),
         anchor: Anchor.center,
         priority: 10,
       );

  final int maxHp;
  int hp;

  static final _bgPaint = Paint()
    ..color = SnowballPalette.healthBarBg
    ..style = PaintingStyle.fill;

  static final _borderPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  static final _fillPaint = Paint()
    ..color = SnowballPalette.healthBarFill
    ..style = PaintingStyle.fill;

  static final _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  @override
  void render(Canvas canvas) {
    if (hp <= 0) return;

    // Draw numeric text above bar
    _textPainter.text = TextSpan(
      text: '$hp',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 5.5,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, blurRadius: 1, offset: Offset(0.5, 0.5)),
          Shadow(color: Colors.black, blurRadius: 1, offset: Offset(-0.5, -0.5)),
        ],
      ),
    );
    _textPainter.layout();
    _textPainter.paint(
      canvas,
      Offset((size.x - _textPainter.width) / 2, -_textPainter.height - 0.5),
    );

    // Draw background
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(rrect, _bgPaint);

    // Draw health fill
    final fillRatio = (hp / maxHp).clamp(0.0, 1.0);
    if (fillRatio > 0) {
      final fillRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0.4, 0.4, (size.x - 0.8) * fillRatio, size.y - 0.8),
        const Radius.circular(1.0),
      );
      canvas.drawRRect(fillRRect, _fillPaint);
    }

    // Draw border
    canvas.drawRRect(rrect, _borderPaint);
  }
}
