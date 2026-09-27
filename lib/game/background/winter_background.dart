// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ricochlime/game/snowball_smash_game.dart';
import 'package:ricochlime/utils/constants/snowball_palette.dart';

class _Snowflake {
  _Snowflake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.swaySpeed,
    required this.swayOffset,
    required this.opacity,
  });

  double x;
  double y;
  double radius;
  double speed;
  double swaySpeed;
  double swayOffset;
  double opacity;
}

/// The rich winter environment background with icy borders, pine trees, and falling snow particles.
class WinterBackground extends PositionComponent
    with HasGameReference<SnowballSmashGame> {
  WinterBackground() : super(priority: -10) {
    // Generate gentle background snowflakes
    final random = Random(42);
    for (var i = 0; i < 35; i++) {
      _snowflakes.add(
        _Snowflake(
          x: random.nextDouble() * SnowballSmashGame.arenaWidth,
          y: random.nextDouble() * SnowballSmashGame.arenaHeight,
          radius: 0.6 + random.nextDouble() * 1.4,
          speed: 10.0 + random.nextDouble() * 18.0,
          swaySpeed: 1.0 + random.nextDouble() * 2.0,
          swayOffset: random.nextDouble() * pi * 2,
          opacity: 0.35 + random.nextDouble() * 0.5,
        ),
      );
    }
  }

  final List<_Snowflake> _snowflakes = [];
  double _time = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    final width = SnowballSmashGame.arenaWidth;
    final height = SnowballSmashGame.arenaHeight;

    for (final flake in _snowflakes) {
      flake.y += flake.speed * dt;
      flake.x += sin(_time * flake.swaySpeed + flake.swayOffset) * 0.4;

      if (flake.y > height) {
        flake.y = -5.0;
        flake.x = Random().nextDouble() * width;
      }
      if (flake.x > width) flake.x = 0;
      if (flake.x < 0) flake.x = width;
    }
  }

  @override
  void render(Canvas canvas) {
    final width = SnowballSmashGame.arenaWidth;
    final height = SnowballSmashGame.arenaHeight;

    // 1. Snowy ground background gradient
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFCBE5F7), // Icy light blue at top
          Color(0xFFE2F0FB), // Soft snowy white
          Color(0xFFD4E9F8), // Crisp snow at bottom
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), groundPaint);

    // Subtle snowy ground drifts/shading
    final driftPaint = Paint()..color = const Color(0x2289BBE0);
    canvas.drawCircle(
      Offset(width * 0.3, height * 0.4),
      width * 0.35,
      driftPaint,
    );
    canvas.drawCircle(
      Offset(width * 0.7, height * 0.65),
      width * 0.4,
      driftPaint,
    );

    // 2. Danger line indicator (if downward movement enabled)
    if (game.levelManager.currentLevelConfig.hasDownwardMovement) {
      final dangerY = game.levelManager.currentLevelConfig.dangerLineY;
      final linePaint = Paint()
        ..color = SnowballPalette.dangerLine.withValues(alpha: 0.6)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // Dashed danger line
      for (double x = 8; x < width - 8; x += 6) {
        canvas.drawLine(
          Offset(x, dangerY),
          Offset(x + 3.5, dangerY),
          linePaint,
        );
      }

      // Small danger skull or exclamation markers on sides
      canvas.drawCircle(
        Offset(10, dangerY),
        1.8,
        Paint()..color = SnowballPalette.dangerLine.withValues(alpha: 0.8),
      );
      canvas.drawCircle(
        Offset(width - 10, dangerY),
        1.8,
        Paint()..color = SnowballPalette.dangerLine.withValues(alpha: 0.8),
      );
    }

    // 3. Side snow banks & pine trees (matching UI.png!)
    _drawBordersAndTrees(canvas, width, height);

    // 4. Falling snow particles
    for (final flake in _snowflakes) {
      final flakePaint = Paint()
        ..color = Colors.white.withValues(alpha: flake.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(flake.x, flake.y), flake.radius, flakePaint);
    }
  }

  void _drawBordersAndTrees(Canvas canvas, double width, double height) {
    // Left snow bank
    final snowBankPaint = Paint()..color = const Color(0xFFEAF5FD);
    final bankShadowPaint = Paint()..color = const Color(0xFFB1D8F2);

    // Left border
    final leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(7.0, 0)
      ..quadraticBezierTo(9.0, height * 0.25, 6.0, height * 0.5)
      ..quadraticBezierTo(10.0, height * 0.75, 7.0, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(leftPath, bankShadowPaint);
    canvas.drawPath(leftPath.shift(const Offset(-1.5, 0)), snowBankPaint);

    // Right border
    final rightPath = Path()
      ..moveTo(width, 0)
      ..lineTo(width - 7.0, 0)
      ..quadraticBezierTo(width - 9.0, height * 0.25, width - 6.0, height * 0.5)
      ..quadraticBezierTo(width - 10.0, height * 0.75, width - 7.0, height)
      ..lineTo(width, height)
      ..close();
    canvas.drawPath(rightPath, bankShadowPaint);
    canvas.drawPath(rightPath.shift(const Offset(1.5, 0)), snowBankPaint);

    // Top icy arch / cave border
    final topArchPath = Path()
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, 10)
      ..quadraticBezierTo(width * 0.75, 14, width * 0.5, 11)
      ..quadraticBezierTo(width * 0.25, 14, 0, 10)
      ..close();
    canvas.drawPath(topArchPath, const Color(0xFF90C5E8).toPaint());
    canvas.drawPath(topArchPath.shift(const Offset(0, -1.5)), snowBankPaint);

    // Draw cute snow-capped pine trees along the side borders
    _drawPineTree(canvas, 4.0, 30.0, scale: 0.9);
    _drawPineTree(canvas, 3.5, 75.0, scale: 1.1);
    _drawPineTree(canvas, 4.0, 125.0, scale: 1.0);
    _drawPineTree(canvas, 3.0, 175.0, scale: 1.15);

    _drawPineTree(canvas, width - 4.0, 35.0, scale: 1.0);
    _drawPineTree(canvas, width - 3.5, 80.0, scale: 0.95);
    _drawPineTree(canvas, width - 4.0, 130.0, scale: 1.1);
    _drawPineTree(canvas, width - 3.0, 180.0, scale: 1.2);

    // Wooden fence posts at bottom sides (matching UI.png!)
    _drawWoodenFence(canvas, 4.0, height - 32.0);
    _drawWoodenFence(canvas, width - 10.0, height - 32.0);
  }

  void _drawPineTree(Canvas canvas, double x, double y, {double scale = 1.0}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);

    final pinePaint = Paint()..color = SnowballPalette.pineDeep;
    final snowCapPaint = Paint()..color = Colors.white;

    // 3 tiered pine layers
    // Bottom tier
    final p1 = Path()
      ..moveTo(0, -14)
      ..lineTo(-7, 0)
      ..lineTo(7, 0)
      ..close();
    canvas.drawPath(p1, pinePaint);
    // Snow on bottom tier
    final s1 = Path()
      ..moveTo(0, -14)
      ..lineTo(-3, -7)
      ..lineTo(3, -7)
      ..close();
    canvas.drawPath(s1, snowCapPaint);

    // Middle tier
    final p2 = Path()
      ..moveTo(0, -20)
      ..lineTo(-5.5, -9)
      ..lineTo(5.5, -9)
      ..close();
    canvas.drawPath(p2, pinePaint);

    // Top tier
    final p3 = Path()
      ..moveTo(0, -25)
      ..lineTo(-4, -16)
      ..lineTo(4, -16)
      ..close();
    canvas.drawPath(p3, pinePaint);
    // Snow peak
    final s3 = Path()
      ..moveTo(0, -25)
      ..lineTo(-2, -21)
      ..lineTo(2, -21)
      ..close();
    canvas.drawPath(s3, snowCapPaint);

    canvas.restore();
  }

  void _drawWoodenFence(Canvas canvas, double x, double y) {
    final woodPaint = Paint()..color = const Color(0xFF795548);
    final woodHighlight = Paint()..color = const Color(0xFFA1887F);
    final snowPaint = Paint()..color = Colors.white;

    // Post 1
    canvas.drawRect(Rect.fromLTWH(x, y, 2.5, 12), woodPaint);
    canvas.drawCircle(Offset(x + 1.25, y), 1.5, snowPaint);

    // Post 2
    canvas.drawRect(Rect.fromLTWH(x + 4.5, y + 2, 2.5, 10), woodPaint);
    canvas.drawCircle(Offset(x + 5.75, y + 2), 1.5, snowPaint);

    // Cross beam
    canvas.drawRect(Rect.fromLTWH(x - 1, y + 4, 9, 2), woodHighlight);
  }
}

extension on Color {
  Paint toPaint() => Paint()..color = this;
}
