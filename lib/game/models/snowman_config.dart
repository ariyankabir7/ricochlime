import 'package:flame/extensions.dart';

enum SnowmanType {
  red,
  blue,
  green,
  basic,
  scarf,
  topHat,
  cool,
  boss;

  String get colorKey => switch (this) {
    SnowmanType.red || SnowmanType.basic || SnowmanType.boss => 'red',
    SnowmanType.blue || SnowmanType.scarf || SnowmanType.cool => 'blue',
    SnowmanType.green || SnowmanType.topHat => 'green',
  };
}

/// Configuration for a snowman's spawn and rewards.
class SnowmanSpawnConfig {
  const SnowmanSpawnConfig({
    required this.id,
    required this.type,
    required this.position,
    required this.maxHp,
    this.rewardCoins = 10,
    this.rewardSnowballs = 1,
  });

  factory SnowmanSpawnConfig.fromJson(Map<String, dynamic> json) {
    return SnowmanSpawnConfig(
      id: json['id'] as String? ?? 'snowman_${json['px']}_${json['py']}',
      type: SnowmanType.values.byName(
        json['type'] as String? ?? SnowmanType.basic.name,
      ),
      position: Vector2(
        (json['px'] as num).toDouble(),
        (json['py'] as num).toDouble(),
      ),
      maxHp: json['maxHp'] as int? ?? 1,
      rewardCoins: json['rewardCoins'] as int? ?? 10,
      rewardSnowballs: json['rewardSnowballs'] as int? ?? 1,
    );
  }

  final String id;
  final SnowmanType type;
  final Vector2 position;
  final int maxHp;
  final int rewardCoins;
  final int rewardSnowballs;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'px': position.x,
    'py': position.y,
    'maxHp': maxHp,
    'rewardCoins': rewardCoins,
    'rewardSnowballs': rewardSnowballs,
  };
}
