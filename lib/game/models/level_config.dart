// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame/extensions.dart';
import 'package:ricochlime/game/models/ice_block_config.dart';
import 'package:ricochlime/game/models/snowman_config.dart';

/// Configuration for a complete level.
class LevelConfig {
  LevelConfig({
    required this.levelNumber,
    this.startingSnowballs = 1,
    required this.snowmen,
    this.reinforcements = const [],
    this.obstacles = const [],
    this.hasDownwardMovement = false,
    this.downwardMoveDistance = 12.6,
    this.dangerLineY = 180.0,
    this.rewardCoinsOnComplete = 50,
  });

  /// Factory constructor to get or procedurally generate a level.
  factory LevelConfig.fromNumber(int levelNumber) {
    if (levelNumber <= 0) return defaultLevels.first;
    if (levelNumber <= defaultLevels.length) {
      return defaultLevels[levelNumber - 1];
    }
    // Procedural generation beyond level 10
    final baseCount = 8 + (levelNumber - 10);
    final reinfCount = 6 + (levelNumber - 10);
    return LevelConfig(
      levelNumber: levelNumber,
      startingSnowballs: 2,
      hasDownwardMovement: true,
      downwardMoveDistance: 12.6,
      rewardCoinsOnComplete: 100 + levelNumber * 10,
      snowmen: [
        for (var i = 0; i < baseCount; i++)
          SnowmanSpawnConfig(
            id: 'gen_${levelNumber}_$i',
            type: SnowmanType.values[i % SnowmanType.values.length],
            position: Vector2(20 + (i % 4) * 26.0, 25 + (i ~/ 4) * 22.0),
            maxHp: (i >= baseCount - 2) ? 2 : (6 + levelNumber + (i % 3) * 2),
            rewardCoins: 15,
            rewardSnowballs: 1,
          ),
      ],
      reinforcements: [
        for (var i = 0; i < reinfCount; i++)
          SnowmanSpawnConfig(
            id: 'gen_reinf_${levelNumber}_$i',
            type: SnowmanType.values[(i + 1) % SnowmanType.values.length],
            position: Vector2(20 + (i % 4) * 26.0, 25),
            maxHp: 6 + levelNumber,
            rewardCoins: 15,
            rewardSnowballs: 1,
          ),
      ],
    );
  }

  final int levelNumber;
  final int startingSnowballs;
  final List<SnowmanSpawnConfig> snowmen;
  final List<SnowmanSpawnConfig> reinforcements;
  final List<IceBlockConfig> obstacles;
  final bool hasDownwardMovement;
  final double downwardMoveDistance;
  final double dangerLineY;
  final int rewardCoinsOnComplete;

  /// Total number of snowmen in this level.
  int get totalSnowmen => snowmen.length + reinforcements.length;

  /// Predefined configurations for Levels 1 to 10.
  static List<LevelConfig> get defaultLevels => [
    // Level 1: 5 basic snowmen, Low HP, Simple formation, 1 starting snowball
    LevelConfig(
      levelNumber: 1,
      startingSnowballs: 1,
      hasDownwardMovement: false,
      rewardCoinsOnComplete: 30,
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l1_1',
          type: SnowmanType.basic,
          position: Vector2(32, 40),
          maxHp: 2,
          rewardCoins: 5,
          rewardSnowballs: 1,
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
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l1_4',
          type: SnowmanType.basic,
          position: Vector2(48, 65),
          maxHp: 2,
          rewardCoins: 5,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l1_5',
          type: SnowmanType.basic,
          position: Vector2(80, 65),
          maxHp: 2,
          rewardCoins: 5,
          rewardSnowballs: 1,
        ),
      ],
    ),

    // Level 2: 7 snowmen, Slightly higher HP, 1 starting snowball
    LevelConfig(
      levelNumber: 2,
      startingSnowballs: 1,
      hasDownwardMovement: false,
      rewardCoinsOnComplete: 40,
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l2_1',
          type: SnowmanType.basic,
          position: Vector2(24, 35),
          maxHp: 3,
          rewardCoins: 5,
          rewardSnowballs: 1,
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
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l2_4',
          type: SnowmanType.basic,
          position: Vector2(104, 35),
          maxHp: 3,
          rewardCoins: 5,
          rewardSnowballs: 1,
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
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l2_7',
          type: SnowmanType.basic,
          position: Vector2(92, 75),
          maxHp: 3,
          rewardCoins: 5,
          rewardSnowballs: 1,
        ),
      ],
    ),

    // Level 3: 8 snowmen with obstacles (Matching UI.png!)
    LevelConfig(
      levelNumber: 3,
      startingSnowballs: 1,
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
          rewardSnowballs: 1,
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
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l3_4',
          type: SnowmanType.basic,
          position: Vector2(25, 65),
          maxHp: 3,
          rewardCoins: 5,
          rewardSnowballs: 1,
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
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l3_7',
          type: SnowmanType.scarf,
          position: Vector2(92, 95),
          maxHp: 3,
          rewardCoins: 5,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l3_8',
          type: SnowmanType.basic,
          position: Vector2(36, 95),
          maxHp: 3,
          rewardCoins: 5,
          rewardSnowballs: 1,
        ),
      ],
    ),

    // Level 4: 10 snowmen, Mixed HP, 1 starting snowball
    LevelConfig(
      levelNumber: 4,
      startingSnowballs: 1,
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
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l4_2',
          type: SnowmanType.scarf,
          position: Vector2(50, 30),
          maxHp: 6,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l4_3',
          type: SnowmanType.topHat,
          position: Vector2(78, 30),
          maxHp: 7,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l4_4',
          type: SnowmanType.basic,
          position: Vector2(106, 32),
          maxHp: 4,
          rewardCoins: 8,
          rewardSnowballs: 1,
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
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l4_8',
          type: SnowmanType.basic,
          position: Vector2(104, 88),
          maxHp: 5,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l4_9',
          type: SnowmanType.scarf,
          position: Vector2(46, 102),
          maxHp: 6,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l4_10',
          type: SnowmanType.scarf,
          position: Vector2(82, 102),
          maxHp: 6,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
      ],
    ),

    // Level 5: 14 snowmen total (8 initial + 6 reinforcements), Downward movement enabled!
    LevelConfig(
      levelNumber: 5,
      startingSnowballs: 2,
      hasDownwardMovement: true,
      downwardMoveDistance: 11.0,
      rewardCoinsOnComplete: 75,
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l5_1',
          type: SnowmanType.basic,
          position: Vector2(24, 30),
          maxHp: 4,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_2',
          type: SnowmanType.topHat,
          position: Vector2(50, 26),
          maxHp: 6,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_3',
          type: SnowmanType.topHat,
          position: Vector2(78, 26),
          maxHp: 6,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_4',
          type: SnowmanType.basic,
          position: Vector2(104, 30),
          maxHp: 4,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_5',
          type: SnowmanType.scarf,
          position: Vector2(36, 52),
          maxHp: 2,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_6',
          type: SnowmanType.cool,
          position: Vector2(64, 48),
          maxHp: 8,
          rewardCoins: 20,
          rewardSnowballs: 2,
        ),
        SnowmanSpawnConfig(
          id: 'l5_7',
          type: SnowmanType.scarf,
          position: Vector2(92, 52),
          maxHp: 5,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_8',
          type: SnowmanType.basic,
          position: Vector2(64, 72),
          maxHp: 2,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
      ],
      reinforcements: [
        SnowmanSpawnConfig(
          id: 'l5_r1',
          type: SnowmanType.scarf,
          position: Vector2(30, 26),
          maxHp: 5,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_r2',
          type: SnowmanType.topHat,
          position: Vector2(64, 25),
          maxHp: 7,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_r3',
          type: SnowmanType.basic,
          position: Vector2(98, 26),
          maxHp: 5,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_r4',
          type: SnowmanType.cool,
          position: Vector2(45, 26),
          maxHp: 6,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_r5',
          type: SnowmanType.scarf,
          position: Vector2(83, 26),
          maxHp: 6,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l5_r6',
          type: SnowmanType.basic,
          position: Vector2(64, 25),
          maxHp: 5,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
      ],
    ),

    // Level 6: 14 snowmen total (8 initial + 6 reinforcements), Downward movement enabled
    LevelConfig(
      levelNumber: 6,
      startingSnowballs: 2,
      hasDownwardMovement: true,
      downwardMoveDistance: 11.8,
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
            position: Vector2(24 + i * 26.0, 26),
            maxHp: 5 + i,
            rewardCoins: 10,
            rewardSnowballs: 1,
          ),
        for (var i = 0; i < 4; i++)
          SnowmanSpawnConfig(
            id: 'l6_r2_$i',
            type: SnowmanType.scarf,
            position: Vector2(24 + i * 26.0, 50),
            maxHp: (i == 0 || i == 3) ? 2 : (6 + (i % 2) * 2),
            rewardCoins: 12,
            rewardSnowballs: 1,
          ),
      ],
      reinforcements: [
        for (var i = 0; i < 6; i++)
          SnowmanSpawnConfig(
            id: 'l6_reinf_$i',
            type: i.isEven ? SnowmanType.cool : SnowmanType.topHat,
            position: Vector2(20 + (i % 4) * 28.0, 26),
            maxHp: 6 + (i % 3) * 2,
            rewardCoins: 14,
            rewardSnowballs: 1,
          ),
      ],
    ),

    // Level 7: 14 snowmen total (8 initial + 6 reinforcements), V-shape fortress with Boss!
    LevelConfig(
      levelNumber: 7,
      startingSnowballs: 2,
      hasDownwardMovement: true,
      downwardMoveDistance: 11.8,
      rewardCoinsOnComplete: 110,
      snowmen: [
        SnowmanSpawnConfig(
          id: 'l7_center',
          type: SnowmanType.boss,
          position: Vector2(64, 25),
          maxHp: 16,
          rewardCoins: 30,
          rewardSnowballs: 2,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v1',
          type: SnowmanType.topHat,
          position: Vector2(46, 38),
          maxHp: 8,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v2',
          type: SnowmanType.topHat,
          position: Vector2(82, 38),
          maxHp: 8,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v3',
          type: SnowmanType.scarf,
          position: Vector2(30, 52),
          maxHp: 7,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v4',
          type: SnowmanType.scarf,
          position: Vector2(98, 52),
          maxHp: 7,
          rewardCoins: 12,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v5',
          type: SnowmanType.basic,
          position: Vector2(18, 66),
          maxHp: 2,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_v6',
          type: SnowmanType.basic,
          position: Vector2(110, 66),
          maxHp: 2,
          rewardCoins: 10,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l7_b4',
          type: SnowmanType.cool,
          position: Vector2(64, 52),
          maxHp: 8,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
      ],
      reinforcements: [
        for (var i = 0; i < 6; i++)
          SnowmanSpawnConfig(
            id: 'l7_reinf_$i',
            type: i.isEven ? SnowmanType.topHat : SnowmanType.scarf,
            position: Vector2(22 + (i % 4) * 26.0, 26),
            maxHp: 7 + (i % 2) * 2,
            rewardCoins: 15,
            rewardSnowballs: 1,
          ),
      ],
    ),

    // Level 8: 15 snowmen total (9 initial + 6 reinforcements), Staggered barricade
    LevelConfig(
      levelNumber: 8,
      startingSnowballs: 2,
      hasDownwardMovement: true,
      downwardMoveDistance: 11.8,
      rewardCoinsOnComplete: 130,
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
            position: Vector2(20 + i * 22.0, 26),
            maxHp: 7 + i,
            rewardCoins: 12,
            rewardSnowballs: 1,
          ),
        for (var i = 0; i < 4; i++)
          SnowmanSpawnConfig(
            id: 'l8_mid_$i',
            type: SnowmanType.cool,
            position: Vector2(31 + i * 22.0, 44),
            maxHp: (i == 0 || i == 3) ? 2 : (8 + (i % 2) * 2),
            rewardCoins: 15,
            rewardSnowballs: 1,
          ),
      ],
      reinforcements: [
        for (var i = 0; i < 6; i++)
          SnowmanSpawnConfig(
            id: 'l8_reinf_$i',
            type: SnowmanType.values[i % 3],
            position: Vector2(22 + (i % 4) * 26.0, 26),
            maxHp: 8 + i % 2,
            rewardCoins: 15,
            rewardSnowballs: 1,
          ),
      ],
    ),

    // Level 9: 16 snowmen total (10 initial + 6 reinforcements), Heavy formation
    LevelConfig(
      levelNumber: 9,
      startingSnowballs: 2,
      hasDownwardMovement: true,
      downwardMoveDistance: 12.6,
      rewardCoinsOnComplete: 160,
      snowmen: [
        for (var r = 0; r < 2; r++)
          for (var c = 0; c < 5; c++)
            SnowmanSpawnConfig(
              id: 'l9_${r}_$c',
              type: r == 0 ? SnowmanType.topHat : SnowmanType.cool,
              position: Vector2(20 + c * 22.0, 26 + r * 22.0),
              maxHp: (r == 1 && (c == 0 || c == 4))
                  ? 2
                  : (8 + r * 2 + (c % 2) * 2),
              rewardCoins: 14 + r * 2,
              rewardSnowballs: 1,
            ),
      ],
      reinforcements: [
        for (var i = 0; i < 6; i++)
          SnowmanSpawnConfig(
            id: 'l9_reinf_$i',
            type: i.isEven ? SnowmanType.topHat : SnowmanType.scarf,
            position: Vector2(22 + (i % 4) * 26.0, 26),
            maxHp: 9 + i % 2,
            rewardCoins: 16,
            rewardSnowballs: 1,
          ),
      ],
    ),

    // Level 10: 18 snowmen total (10 initial + 8 reinforcements), Grand Castle Boss!
    LevelConfig(
      levelNumber: 10,
      startingSnowballs: 2,
      hasDownwardMovement: true,
      downwardMoveDistance: 12.6,
      rewardCoinsOnComplete: 220,
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
          maxHp: 24,
          rewardCoins: 50,
          rewardSnowballs: 3,
        ),
        // Royal Guard
        SnowmanSpawnConfig(
          id: 'l10_g1',
          type: SnowmanType.topHat,
          position: Vector2(38, 28),
          maxHp: 12,
          rewardCoins: 20,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l10_g2',
          type: SnowmanType.topHat,
          position: Vector2(90, 28),
          maxHp: 12,
          rewardCoins: 20,
          rewardSnowballs: 1,
        ),
        // Flankers
        SnowmanSpawnConfig(
          id: 'l10_f1',
          type: SnowmanType.cool,
          position: Vector2(18, 35),
          maxHp: 10,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        SnowmanSpawnConfig(
          id: 'l10_f2',
          type: SnowmanType.cool,
          position: Vector2(110, 35),
          maxHp: 10,
          rewardCoins: 15,
          rewardSnowballs: 1,
        ),
        // Second line
        for (var i = 0; i < 5; i++)
          SnowmanSpawnConfig(
            id: 'l10_m_$i',
            type: SnowmanType.scarf,
            position: Vector2(20 + i * 22.0, 52),
            maxHp: (i == 0 || i == 4) ? 2 : (9 + i % 3),
            rewardCoins: 15,
            rewardSnowballs: 1,
          ),
      ],
      reinforcements: [
        for (var i = 0; i < 8; i++)
          SnowmanSpawnConfig(
            id: 'l10_reinf_$i',
            type: i == 0
                ? SnowmanType.boss
                : (i.isEven ? SnowmanType.topHat : SnowmanType.cool),
            position: Vector2(18 + (i % 4) * 28.0, 26),
            maxHp: 10 + (i % 3) * 2,
            rewardCoins: 18,
            rewardSnowballs: 1,
          ),
      ],
    ),
  ];
}
