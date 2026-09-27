import 'package:flame/extensions.dart';

/// Configuration for an ice block obstacle in the arena.
class IceBlockConfig {
  const IceBlockConfig({
    required this.position,
    this.size = const Size(12, 12),
  });

  factory IceBlockConfig.fromJson(Map<String, dynamic> json) {
    return IceBlockConfig(
      position: Vector2(
        (json['px'] as num).toDouble(),
        (json['py'] as num).toDouble(),
      ),
      size: Size(
        (json['w'] as num?)?.toDouble() ?? 12,
        (json['h'] as num?)?.toDouble() ?? 12,
      ),
    );
  }

  final Vector2 position;
  final Size size;

  Map<String, dynamic> toJson() => {
    'px': position.x,
    'py': position.y,
    'w': size.width,
    'h': size.height,
  };
}
