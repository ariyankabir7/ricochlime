import 'package:ricochlime/game/models/snowman_config.dart';

/// Configuration for a wave of snowmen.
class WaveConfig {
  const WaveConfig({required this.snowmen, this.spawnDelaySeconds = 0.0});

  final List<SnowmanSpawnConfig> snowmen;
  final double spawnDelaySeconds;
}
