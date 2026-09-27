import 'package:flame_forge2d/flame_forge2d.dart';

const double wallInset = 2.0;

/// Creates boundary walls for the arena.
List<ArenaWall> createArenaBoundaries(
  double width,
  double height, {
  bool includeTop = true,
  bool includeBottom = false,
  bool includeLeft = true,
  bool includeRight = true,
}) {
  final topLeft = Vector2(wallInset, wallInset);
  final bottomRight = Vector2(width - wallInset, height - wallInset);
  final topRight = Vector2(bottomRight.x, topLeft.y);
  final bottomLeft = Vector2(topLeft.x, bottomRight.y);

  return [
    if (includeTop) ArenaWall(topLeft, topRight),
    if (includeRight) ArenaWall(topRight, bottomRight),
    if (includeBottom) ArenaWall(bottomRight, bottomLeft),
    if (includeLeft) ArenaWall(bottomLeft, topLeft),
  ];
}

/// A static wall collider.
class ArenaWall extends BodyComponent {
  ArenaWall(this.start, this.end) {
    renderBody = false;
  }

  final Vector2 start;
  final Vector2 end;

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape, restitution: 1.0, friction: 0.0);
    final bodyDef = BodyDef(userData: this, position: Vector2.zero());

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
