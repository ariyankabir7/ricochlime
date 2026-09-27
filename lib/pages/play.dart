// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ricochlime/game/game_state.dart';
import 'package:ricochlime/game/snowball_smash_game.dart';
import 'package:ricochlime/pages/settings.dart';
import 'package:ricochlime/utils/constants/snowball_palette.dart';
import 'package:ricochlime/widgets/snow_coin_badge.dart';
import 'package:ricochlime/widgets/snow_game_over_dialog.dart';
import 'package:ricochlime/widgets/snow_level_complete_dialog.dart';
import 'package:ricochlime/widgets/snow_pause_dialog.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with WidgetsBindingObserver {
  late final SnowballSmashGame _game;

  @override
  void initState() {
    super.initState();
    _game = SnowballSmashGame.instance;
    _game
      ..onLevelComplete = _showLevelCompleteDialog
      ..onGameOver = _showGameOverDialog
      ..audio.playBgm();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _game
      ..onLevelComplete = null
      ..onGameOver = null
      ..audio.pauseBgm();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _game.audio.playBgm();
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _game.audio.pauseBgm();
    }
  }

  bool _isDialogShowing = false;

  void _showLevelCompleteDialog() {
    if (!mounted || _isDialogShowing) return;
    _isDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SnowLevelCompleteDialog(
        level: _game.levelManager.currentLevel,
        coinsEarned: _game.levelManager.coinsEarnedThisLevel,
        snowballsEarned: _game.levelManager.snowballsEarnedThisLevel,
        onNextLevel: () {
          Navigator.of(context).pop();
          _isDialogShowing = false;
          _game.advanceToNextLevel();
        },
        onHome: () {
          Navigator.of(context).pop();
          _isDialogShowing = false;
          Navigator.of(this.context).pop();
        },
      ),
    );
  }

  void _showGameOverDialog() {
    if (!mounted || _isDialogShowing) return;
    _isDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SnowGameOverDialog(
        onContinue: () {
          Navigator.of(context).pop();
          _isDialogShowing = false;
          _game.loadLevel(_game.levelManager.currentLevel);
        },
        onRestart: () {
          Navigator.of(context).pop();
          _isDialogShowing = false;
          _game.restartCurrentLevel();
        },
        onHome: () {
          Navigator.of(context).pop();
          _isDialogShowing = false;
          Navigator.of(this.context).pop();
        },
      ),
    );
  }

  void _showPauseDialog() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    final prevState = _game.state.value;
    _game.state.value = SnowballGameState.paused;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SnowPauseDialog(
        onResume: () {
          Navigator.of(context).pop();
          _isDialogShowing = false;
          _game.state.value = prevState;
        },
        onRestart: () {
          Navigator.of(context).pop();
          _isDialogShowing = false;
          _game.restartCurrentLevel();
        },
        onSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
        onHome: () {
          Navigator.of(context).pop();
          _isDialogShowing = false;
          Navigator.of(this.context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: SnowballPalette.snowGround,
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Core Flame Game
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: SnowballSmashGame.arenaWidth,
                    height: SnowballSmashGame.arenaHeight,
                    child: GameWidget(game: _game),
                  ),
                ),
              ),

              // 2. Top HUD Bar (Pause, Level Badge, Coins)
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pause button
                    GestureDetector(
                      onTap: _showPauseDialog,
                      child: Image.asset(
                        'assets/images/ui/btn_pause.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    // Level Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF42A5F5), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Level ${_game.levelManager.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Coins Badge
                    const SnowCoinBadge(),
                  ],
                ),
              ),

              // 3. Snowball Counter Pill (below Pause button on top left)
              Positioned(
                top: 54,
                left: 12,
                child: ListenableBuilder(
                  listenable: _game.levelManager.availableSnowballs,
                  builder: (context, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF64B5F6), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/ui/snowball_sphere.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'x ${_game.levelManager.availableSnowballs.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
