// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ricochlime/game/components/snowball.dart';
import 'package:ricochlime/game/components/walls.dart';
import 'package:ricochlime/game/snowball_smash_game.dart';
import 'package:ricochlime/utils/stows.dart';

/// Predicts and draws the trajectory of snowballs when the player aims.
class AimGuide extends PositionComponent with HasGameReference<SnowballSmashGame> {
  AimGuide()
    : super(
        anchor: Anchor.center,
        priority: 15,
      );

  AimDetails? aimDetails;
  Vector2? lastMousePosition;
  int lastNumDotsBeforeReflection = 0;

  static const double _dotInterval = 8.0;
  static const int _maxDots = 24;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = game.player.position + Vector2(0, -game.player.size.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = game.player.position + Vector2(0, -game.player.size.y);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final details = aimDetails;
    if (details == null || details.unitDir.isZero() || details.unitDir.y >= 0) {
      return;
    }

    const gameInset = Snowball.radius + wallInset;
    final gameRect = Rect.fromLTRB(
      gameInset,
      gameInset,
      SnowballSmashGame.arenaWidth - gameInset,
      SnowballSmashGame.arenaHeight - gameInset,
    );

    final reflectionPoint = details.reflectionPoint(position, gameRect);
    final reflectionDist = reflectionPoint.length;
    final numDotsTotal = (details.aimLength * _maxDots).ceil();

    final int numDotsBeforeReflection;
    final numDotsBeforeReflectionUnrounded = min(
      numDotsTotal,
      reflectionDist / _dotInterval,
    );

    if ((numDotsBeforeReflectionUnrounded - lastNumDotsBeforeReflection).abs() < 0.5) {
      numDotsBeforeReflection = lastNumDotsBeforeReflection;
    } else {
      numDotsBeforeReflection = numDotsBeforeReflectionUnrounded.floor();
      lastNumDotsBeforeReflection = numDotsBeforeReflection;
    }

    final numDotsAfterReflection = min(
      numDotsTotal - numDotsBeforeReflection,
      stows.showReflectionInAimGuide.value ? numDotsTotal : 0,
    );

    final adjustedDotInterval = numDotsBeforeReflection >= numDotsTotal
        ? _dotInterval
        : (numDotsBeforeReflection > 0 ? reflectionDist / numDotsBeforeReflection : _dotInterval);
    final dotDelta = details.unitDir * adjustedDotInterval;

    // Draw primary trajectory
    for (var dot = 1; dot <= numDotsBeforeReflection; dot++) {
      final dotPosition = dotDelta * dot.toDouble();
      final dotRatio = dot / _maxDots;
      final dotRadius = Snowball.radius * (1.0 - dotRatio * 0.35);
      final alpha = (1.0 - dotRatio * 0.25).clamp(0.4, 1.0);

      Snowball.drawSnowball(
        canvas,
        Offset(dotPosition.x, dotPosition.y),
        radius: dotRadius,
        opacity: alpha,
      );
    }

    // Draw reflection trajectory
    if (numDotsAfterReflection > 0) {
      dotDelta.x *= -1; // Reflect horizontally
      for (var dot = 1; dot <= numDotsAfterReflection; dot++) {
        final dotPosition = reflectionPoint + dotDelta * dot.toDouble();
        final dotRatio = (numDotsBeforeReflection + dot) / _maxDots;
        final dotRadius = Snowball.radius * (1.0 - dotRatio * 0.35);
        final alpha = (0.75 - dotRatio * 0.3).clamp(0.2, 0.75);

        Snowball.drawSnowball(
          canvas,
          Offset(dotPosition.x, dotPosition.y),
          radius: dotRadius,
          opacity: alpha,
        );
      }
    }
  }

  /// Updates trajectory from touch/mouse drag position.
  void aim(Vector2 inputPosition) {
    // Invert so dragging downwards aims upwards (slingshot feel), or direct drag upwards
    var displacement = position - inputPosition;
    final distance = displacement.length;

    // If dragging directly above the player, direct aim towards finger
    if (inputPosition.y < position.y) {
      displacement = inputPosition - position;
    }

    // Enforce aiming UPWARDS into arena only (never backwards)
    if (displacement.y >= -2.0) {
      displacement.y = -2.0;
    }

    final clampedDistance = displacement.length;
    if (clampedDistance < 1.0) return;

    // Limit extreme horizontal angles
    final relX = (displacement.x / clampedDistance).abs();
    const maxRelX = 0.95;
    if (relX > maxRelX) {
      final minRelY = sqrt(1.0 - maxRelX * maxRelX);
      displacement
        ..x = clampedDistance * maxRelX * displacement.x.sign
        ..y = -clampedDistance * minRelY;
    }

    final aimLength = min(1.0, distance / (_dotInterval * _maxDots) * 3.5);
    final unit = displacement.normalized();

    aimDetails = AimDetails(
      unitDir: unit,
      aimLength: max(0.25, aimLength),
      mouseBelowPlayer: inputPosition.y >= position.y,
    );
  }

  /// Finalizes the aim, resetting preview and returning aim direction.
  Vector2? finishAim() {
    final dir = aimDetails?.unitDir;
    aimDetails = null;
    if (dir == null || dir.isZero() || dir.y >= 0) {
      return null;
    }
    return dir;
  }
}

/// Detailed calculation parameters for the aim trajectory.
class AimDetails {
  AimDetails({
    required this.unitDir,
    required this.aimLength,
    required this.mouseBelowPlayer,
  });

  final Vector2 unitDir;
  double aimLength;
  bool mouseBelowPlayer;

  Vector2 reflectionPoint(Vector2 playerPos, Rect gameRect) {
    if (unitDir.x == 0) return Vector2(0, gameRect.top - playerPos.y);

    final y = unitDir.y / unitDir.x.abs() * (gameRect.width / 2);
    final x = unitDir.x > 0 ? gameRect.right : gameRect.left;
    return Vector2(x - playerPos.x, y);
  }
}
