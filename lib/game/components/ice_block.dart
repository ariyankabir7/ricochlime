// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:ricochlime/utils/constants/snowball_palette.dart';

/// A frozen ice block obstacle that reflects snowballs.
class IceBlock extends BodyComponent with ContactCallbacks {
  IceBlock({
    required this.initialPosition,
    this.blockSize = const Size(14, 14),
  }) : super(
         renderBody: false,
         priority: 4,
       );

  final Vector2 initialPosition;
  final Size blockSize;

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(
        blockSize.width / 2,
        blockSize.height / 2,
        Vector2.zero(),
        0,
      );

    final fixtureDef = FixtureDef(
      shape,
      userData: this,
      restitution: 1.0,
      friction: 0.0,
    );

    final bodyDef = BodyDef(
      position: initialPosition.clone(),
      type: BodyType.static,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final halfW = blockSize.width / 2;
    final halfH = blockSize.height / 2;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: blockSize.width,
      height: blockSize.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.5));

    // Outer shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0.5, 0.8)),
      Paint()..color = const Color(0x33004D40),
    );

    // Ice body gradient/fill
    canvas.drawRRect(
      rrect,
      Paint()..color = SnowballPalette.iceBlockMain,
    );

    // Inner bright ice face
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -halfW + 1.2,
        -halfH + 1.2,
        blockSize.width - 2.4,
        blockSize.height - 2.4,
      ),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(
      innerRRect,
      Paint()..color = SnowballPalette.iceBlockLight.withValues(alpha: 0.85),
    );

    // Frost shine/highlight lines
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-halfW + 2.5, -halfH + 2.5),
      Offset(-halfW + 6.0, -halfH + 2.5),
      shinePaint,
    );
    canvas.drawLine(
      Offset(-halfW + 2.5, -halfH + 2.5),
      Offset(-halfW + 2.5, -halfH + 6.0),
      shinePaint,
    );

    // Ice outline
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = SnowballPalette.iceBlockDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }
}
