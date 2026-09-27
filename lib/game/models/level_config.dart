// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame/extensions.dart';
import 'package:ricochlime/game/models/ice_block_config.dart';
import 'package:ricochlime/game/models/snowman_config.dart';

/// Configuration for a complete level.
class LevelConfig {
  LevelConfig({
    required this.levelNumber,
    required this.startingSnowballs,
    required this.snowmen,
    this.obstacles = const [],
    this.hasDownwardMovement = false,
    this.downwardMoveDistance = 14.0,
    this.dangerLineY = 160.0,
    this.rewardCoinsOnComplete = 50,
  });

  /// Factory constructor to get or procedurally generate a level.
  factory LevelConfig.fromNumber(int levelNumber) {
    if (levelNumber <= 0) return defaultLevels.first;
    if (levelNumber <= defaultLevels.length) {
      return defaultLevels[levelNumber - 1];
    }
    // Procedural generation beyond level 10
    final baseCount = 12 + (levelNumber - 10);
    return LevelConfig(
      levelNumber: levelNumber,
      startingSnowballs: 7 + (levelNumber ~/ 3),
      hasDownwardMovement: true,
      downwardMoveDistance: 14.0,
      rewardCoinsOnComplete: 100 + levelNumber * 10,
      snowmen: [
        for (var i = 0; i < baseCount; i++)
          SnowmanSpawnConfig(
            id: 'gen_${levelNumber}_$i',
            type: SnowmanType.values[i % SnowmanType.values.length],
            position: Vector2(20 + (i % 5) * 22.0, 25 + (i ~/ 5) * 20.0),
            maxHp: 8 + levelNumber + (i % 3) * 2,
            rewardCoins: 15,
            rewardSnowballs: i % 4 == 0 ? 1 : 0,
          ),
      ],
    );
  }

  final int levelNumber;
  final int startingSnowballs;
  final List<SnowmanSpawnConfig> snowmen;
  final List<IceBlockConfig> obstacles;
  final bool hasDownwardMovement;
  final double downwardMoveDistance;
  final double dangerLineY;
  final int rewardCoinsOnComplete;

  /// Total number of snowmen in this level.
  int get totalSnowmen => snowmen.length;

  /// Predefined configurations for Levels 1 to 10.
  static List<LevelConfig> get defaultLevels => [
    // Level 1: 5 basic snowmen, Low HP, Simple formation, 3 starting snowballs
    LevelConfig(
      levelNumber: 1,
      startingSnowballs: 3,
      hasDownwardMovement: false,
      rewardCoinsOnComplete: 30,
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l1_1',
          type: SnowmanType.basic,
          position: Vector2(32, 40),
          maxHp: 2,
          rewardCoins: 5,
        ),
        SnowmanSpawnConfig(
          id: 'l1_2',
          type: SnowmanType.scarf,
          position: Vector2(64, 30),
          maxHp: 3,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l1_3',
          type: SnowmanType.basic,
          position: Vector2(96, 40),
          maxHp: 2,
          rewardCoins: 5,
        ),
        SnowmanSpawnConfig(
          id: 'l1_4',
          type: SnowmanType.basic,
          position: Vector2(48, 65),
          maxHp: 2,
          rewardCoins: 5,
        ),
        SnowmanSpawnConfig(
          id: 'l1_5',
          type: SnowmanType.basic,
          position: Vector2(80, 65),
          maxHp: 2,
          rewardCoins: 5,
        ),
      ],
    ),

    // Level 2: 7 snowmen, Slightly higher HP, 4 starting snowballs
    LevelConfig(
      levelNumber: 2,
      startingSnowballs: 4,
      hasDownwardMovement: false,
      rewardCoinsOnComplete: 40,
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l2_1',
          type: SnowmanType.basic,
          position: Vector2(24, 35),
          maxHp: 3,
          rewardCoins: 5,
        ),
        SnowmanSpawnConfig(
          id: 'l2_2',
          type: SnowmanType.scarf,
          position: Vector2(50, 30),
          maxHp: 4,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l2_3',
          type: SnowmanType.basic,
          position: Vector2(78, 30),
          maxHp: 4,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l2_4',
          type: SnowmanType.basic,
          position: Vector2(104, 35),
          maxHp: 3,
          rewardCoins: 5,
        ),
        SnowmanSpawnConfig(
          id: 'l2_5',
          type: SnowmanType.topHat,
          position: Vector2(64, 55),
          maxHp: 5,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l2_6',
          type: SnowmanType.basic,
          position: Vector2(36, 75),
          maxHp: 3,
          rewardCoins: 5,
        ),
        SnowmanSpawnConfig(
          id: 'l2_7',
          type: SnowmanType.basic,
          position: Vector2(92, 75),
          maxHp: 3,
          rewardCoins: 5,
        ),
      ],
    ),

    // Level 3: 8 snowmen with obstacles (Matching UI.png!)
    LevelConfig(
      levelNumber: 3,
      startingSnowballs: 5,
      hasDownwardMovement: false,
      rewardCoinsOnComplete: 50,
      obstacles: [
        IceBlockConfig(position: Vector2(32, 110), size: Size(14, 14)),
        IceBlockConfig(position: Vector2(96, 110), size: Size(14, 14)),
      ],
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l3_1',
          type: SnowmanType.scarf,
          position: Vector2(30, 35),
          maxHp: 4,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l3_2',
          type: SnowmanType.topHat,
          position: Vector2(64, 32),
          maxHp: 8,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l3_3',
          type: SnowmanType.cool,
          position: Vector2(98, 35),
          maxHp: 6,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l3_4',
          type: SnowmanType.basic,
          position: Vector2(25, 65),
          maxHp: 3,
          rewardCoins: 5,
        ),
        SnowmanSpawnConfig(
          id: 'l3_5',
          type: SnowmanType.topHat,
          position: Vector2(64, 60),
          maxHp: 10,
          rewardCoins: 20,
          rewardSnowballs: 2,
        ),
        SnowmanSpawnConfig(
          id: 'l3_6',
          type: SnowmanType.scarf,
          position: Vector2(103, 65),
          maxHp: 5,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l3_7',
          type: SnowmanType.scarf,
          position: Vector2(92, 95),
          maxHp: 3,
          rewardCoins: 5,
        ),
        SnowmanSpawnConfig(
          id: 'l3_8',
          type: SnowmanType.basic,
          position: Vector2(36, 95),
          maxHp: 3,
          rewardCoins: 5,
        ),
      ],
    ),

    // Level 4: 10 snowmen, Mixed HP
    LevelConfig(
      levelNumber: 4,
      startingSnowballs: 5,
      hasDownwardMovement: false,
      rewardCoinsOnComplete: 60,
      obstacles: [
        IceBlockConfig(position: Vector2(64, 75), size: Size(14, 14)),
      ],
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l4_1',
          type: SnowmanType.basic,
          position: Vector2(22, 32),
          maxHp: 4,
          rewardCoins: 8,
        ),
        SnowmanSpawnConfig(
          id: 'l4_2',
          type: SnowmanType.scarf,
          position: Vector2(50, 30),
          maxHp: 6,
          rewardCoins: 12,
        ),
        SnowmanSpawnConfig(
          id: 'l4_3',
          type: SnowmanType.topHat,
          position: Vector2(78, 30),
          maxHp: 7,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l4_4',
          type: SnowmanType.basic,
          position: Vector2(106, 32),
          maxHp: 4,
          rewardCoins: 8,
        ),
        SnowmanSpawnConfig(
          id: 'l4_5',
          type: SnowmanType.cool,
          position: Vector2(36, 52),
          maxHp: 8,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l4_6',
          type: SnowmanType.cool,
          position: Vector2(92, 52),
          maxHp: 8,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l4_7',
          type: SnowmanType.basic,
          position: Vector2(24, 88),
          maxHp: 5,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l4_8',
          type: SnowmanType.basic,
          position: Vector2(104, 88),
          maxHp: 5,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l4_9',
          type: SnowmanType.scarf,
          position: Vector2(46, 102),
          maxHp: 6,
          rewardCoins: 12,
        ),
        SnowmanSpawnConfig(
          id: 'l4_10',
          type: SnowmanType.scarf,
          position: Vector2(82, 102),
          maxHp: 6,
          rewardCoins: 12,
        ),
      ],
    ),

    // Level 5: 10 snowmen, Downward movement enabled!
    LevelConfig(
      levelNumber: 5,
      startingSnowballs: 5,
      hasDownwardMovement: true,
      downwardMoveDistance: 12.0,
      rewardCoinsOnComplete: 75,
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l5_1',
          type: SnowmanType.basic,
          position: Vector2(20, 25),
          maxHp: 5,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l5_2',
          type: SnowmanType.topHat,
          position: Vector2(48, 22),
          maxHp: 9,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l5_3',
          type: SnowmanType.topHat,
          position: Vector2(80, 22),
          maxHp: 9,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l5_4',
          type: SnowmanType.basic,
          position: Vector2(108, 25),
          maxHp: 5,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l5_5',
          type: SnowmanType.scarf,
          position: Vector2(34, 45),
          maxHp: 7,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_6',
          type: SnowmanType.cool,
          position: Vector2(64, 42),
          maxHp: 12,
          rewardCoins: 20,
          rewardSnowballs: 2,
        ),
        SnowmanSpawnConfig(
          id: 'l5_7',
          type: SnowmanType.scarf,
          position: Vector2(94, 45),
          maxHp: 7,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_8',
          type: SnowmanType.basic,
          position: Vector2(30, 68),
          maxHp: 6,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l5_9',
          type: SnowmanType.topHat,
          position: Vector2(64, 65),
          maxHp: 8,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l5_10',
          type: SnowmanType.basic,
          position: Vector2(98, 68),
          maxHp: 6,
          rewardCoins: 10,
        ),
      ],
    ),

    // Level 6: 12 snowmen, Downward movement enabled
    LevelConfig(
      levelNumber: 6,
      startingSnowballs: 6,
      hasDownwardMovement: true,
      downwardMoveDistance: 13.0,
      rewardCoinsOnComplete: 90,
      obstacles: [
        IceBlockConfig(position: Vector2(40, 80), size: Size(12, 12)),
        IceBlockConfig(position: Vector2(88, 80), size: Size(12, 12)),
      ],
      snowmen: [
        for (var i = 0; i < 4; i++)
          SnowmanSpawnConfig(
            id: 'l6_r1_$i',
            type: i == 1 || i == 2 ? SnowmanType.topHat : SnowmanType.basic,
            position: Vector2(24 + i * 26.0, 24),
            maxHp: 6 + i,
            rewardCoins: 10,
            rewardSnowballs: i == 1 ? 1 : 0,
          ),
        for (var i = 0; i < 4; i++)
          SnowmanSpawnConfig(
            id: 'l6_r2_$i',
            type: SnowmanType.scarf,
            position: Vector2(24 + i * 26.0, 46),
            maxHp: 7 + (i % 2) * 3,
            rewardCoins: 12,
            rewardSnowballs: i == 2 ? 1 : 0,
          ),
        for (var i = 0; i < 4; i++)
          SnowmanSpawnConfig(
            id: 'l6_r3_$i',
            type: i == 1 || i == 2 ? SnowmanType.cool : SnowmanType.basic,
            position: Vector2(24 + i * 26.0, 68),
            maxHp: 5 + i * 2,
            rewardCoins: 10,
          ),
      ],
    ),

    // Level 7: 13 snowmen, V-shape fortress
    LevelConfig(
      levelNumber: 7,
      startingSnowballs: 6,
      hasDownwardMovement: true,
      downwardMoveDistance: 14.0,
      rewardCoinsOnComplete: 100,
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l7_center',
          type: SnowmanType.boss,
          position: Vector2(64, 25),
          maxHp: 15,
          rewardCoins: 30,
          rewardSnowballs: 2,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v1',
          type: SnowmanType.topHat,
          position: Vector2(46, 38),
          maxHp: 10,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v2',
          type: SnowmanType.topHat,
          position: Vector2(82, 38),
          maxHp: 10,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v3',
          type: SnowmanType.scarf,
          position: Vector2(30, 52),
          maxHp: 8,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v4',
          type: SnowmanType.scarf,
          position: Vector2(98, 52),
          maxHp: 8,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v5',
          type: SnowmanType.basic,
          position: Vector2(18, 66),
          maxHp: 6,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v6',
          type: SnowmanType.basic,
          position: Vector2(110, 66),
          maxHp: 6,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l7_m1',
          type: SnowmanType.cool,
          position: Vector2(46, 72),
          maxHp: 9,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l7_m2',
          type: SnowmanType.cool,
          position: Vector2(82, 72),
          maxHp: 9,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l7_b1',
          type: SnowmanType.basic,
          position: Vector2(32, 90),
          maxHp: 7,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l7_b2',
          type: SnowmanType.topHat,
          position: Vector2(64, 88),
          maxHp: 11,
          rewardCoins: 18,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_b3',
          type: SnowmanType.basic,
          position: Vector2(96, 90),
          maxHp: 7,
          rewardCoins: 10,
        ),
        SnowmanSpawnConfig(
          id: 'l7_b4',
          type: SnowmanType.scarf,
          position: Vector2(64, 50),
          maxHp: 8,
          rewardCoins: 12,
        ),
      ],
    ),

    // Level 8: 14 snowmen, Staggered barricade
    LevelConfig(
      levelNumber: 8,
      startingSnowballs: 7,
      hasDownwardMovement: true,
      downwardMoveDistance: 14.0,
      rewardCoinsOnComplete: 120,
      obstacles: [
        IceBlockConfig(position: Vector2(28, 60), size: Size(12, 12)),
        IceBlockConfig(position: Vector2(64, 60), size: Size(12, 12)),
        IceBlockConfig(position: Vector2(100, 60), size: Size(12, 12)),
      ],
      snowmen: [
        for (var i = 0; i < 5; i++)
          SnowmanSpawnConfig(
            id: 'l8_top_$i',
            type: i.isEven ? SnowmanType.scarf : SnowmanType.topHat,
            position: Vector2(20 + i * 22.0, 24),
            maxHp: 8 + i,
            rewardCoins: 12,
            rewardSnowballs: i == 2 ? 1 : 0,
          ),
        for (var i = 0; i < 4; i++)
          SnowmanSpawnConfig(
            id: 'l8_mid_$i',
            type: SnowmanType.cool,
            position: Vector2(31 + i * 22.0, 42),
            maxHp: 10 + (i % 2) * 2,
            rewardCoins: 15,
            rewardSnowballs: i == 1 ? 1 : 0,
          ),
        for (var i = 0; i < 5; i++)
          SnowmanSpawnConfig(
            id: 'l8_bot_$i',
            type: SnowmanType.basic,
            position: Vector2(20 + i * 22.0, 80),
            maxHp: 7 + (i % 3),
            rewardCoins: 10,
          ),
      ],
    ),

    // Level 9: 15 snowmen, Heavy formation
    LevelConfig(
      levelNumber: 9,
      startingSnowballs: 7,
      hasDownwardMovement: true,
      downwardMoveDistance: 15.0,
      rewardCoinsOnComplete: 150,
      snowmen: [
        for (var r = 0; r < 3; r++)
          for (var c = 0; c < 5; c++)
            SnowmanSpawnConfig(
              id: 'l9_${r}_$c',
              type: r == 0
                  ? SnowmanType.topHat
                  : r == 1
                  ? SnowmanType.cool
                  : SnowmanType.scarf,
              position: Vector2(20 + c * 22.0, 24 + r * 22.0),
              maxHp: 9 + r * 2 + (c % 2) * 2,
              rewardCoins: 14 + r * 2,
              rewardSnowballs:
                  (r == 1 && c == 2) || (r == 0 && c == 4) ? 1 : 0,
            ),
      ],
    ),

    // Level 10: 16 snowmen, Grand Snowman Castle with Boss!
    LevelConfig(
      levelNumber: 10,
      startingSnowballs: 8,
      hasDownwardMovement: true,
      downwardMoveDistance: 15.0,
      rewardCoinsOnComplete: 200,
      obstacles: [
        IceBlockConfig(position: Vector2(44, 90), size: Size(14, 14)),
        IceBlockConfig(position: Vector2(84, 90), size: Size(14, 14)),
      ],
      snowmen: [
        // Castle Boss
        SnowmanSpawnConfig(
          id: 'l10_boss',
          type: SnowmanType.boss,
          position: Vector2(64, 25),
          maxHp: 25,
          rewardCoins: 50,
          rewardSnowballs: 3,
        ),
        // Royal Guard
        SnowmanSpawnConfig(
          id: 'l10_g1',
          type: SnowmanType.topHat,
          position: Vector2(38, 28),
          maxHp: 14,
          rewardCoins: 20,
        ),
        SnowmanSpawnConfig(
          id: 'l10_g2',
          type: SnowmanType.topHat,
          position: Vector2(90, 28),
          maxHp: 14,
          rewardCoins: 20,
        ),
        // Flankers
        SnowmanSpawnConfig(
          id: 'l10_f1',
          type: SnowmanType.cool,
          position: Vector2(18, 35),
          maxHp: 12,
          rewardCoins: 15,
        ),
        SnowmanSpawnConfig(
          id: 'l10_f2',
          type: SnowmanType.cool,
          position: Vector2(110, 35),
          maxHp: 12,
          rewardCoins: 15,
        ),
        // Second line
        for (var i = 0; i < 5; i++)
          SnowmanSpawnConfig(
            id: 'l10_m_$i',
            type: SnowmanType.scarf,
            position: Vector2(20 + i * 22.0, 50),
            maxHp: 10 + i % 3,
            rewardCoins: 15,
            rewardSnowballs: i == 2 ? 1 : 0,
          ),
        // Front line
        for (var i = 0; i < 6; i++)
          SnowmanSpawnConfig(
            id: 'l10_front_$i',
            type: SnowmanType.basic,
            position: Vector2(16 + i * 19.2, 70),
            maxHp: 8 + (i % 2) * 2,
            rewardCoins: 12,
            rewardSnowballs: i == 4 ? 1 : 0,
          ),
      ],
    ),
  ];
}
