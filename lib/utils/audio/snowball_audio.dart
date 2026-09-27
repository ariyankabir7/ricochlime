import 'package:ricochlime/utils/ricochlime_audio.dart';

/// Audio manager for Snowball Smash sounds and background music.
class SnowballAudio {
  SnowballAudio() : _baseAudio = RicochlimeAudio();

  final RicochlimeAudio _baseAudio;

  Future<void> init() => _baseAudio.init();

  void playBgm() => _baseAudio.playBgm();
  void pauseBgm() => _baseAudio.pauseBgm();

  void playThrow() {
    _baseAudio.playHitSfx();
  }

  void playHit() {
    _baseAudio.playHitSfx();
  }

  void playPoof() {
    _baseAudio.playHitSfx();
  }

  void playCoin() {
    _baseAudio.playHitSfx();
  }

  void playCelebration() {
    _baseAudio.playHitSfx();
  }

  void playGameOver() {
    _baseAudio.playHitSfx();
  }
}
