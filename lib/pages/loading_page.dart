// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:async';
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ricochlime/ads/iap.dart';
import 'package:ricochlime/flame/ricochlime_game.dart';
import 'package:ricochlime/i18n/strings.g.dart';
import 'package:ricochlime/pages/home.dart';
import 'package:ricochlime/utils/ricochlime_audio.dart';
import 'package:ricochlime/utils/stows.dart';
import 'package:ricochlime/widgets/character_avatar.dart';
import 'package:ricochlime/widgets/snowball_logo.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();

  /// A list of asynchronous tasks to be completed during the loading phase.
  static final tasks = _sequentialize([
    LocaleSettings.useDeviceLocale(),
    stows.highScore.waitUntilRead(),
    stows.currentLevel.waitUntilRead(),
    stows.stylizedPageTransitions.waitUntilRead(),
    GoogleFonts.pendingFonts([GoogleFonts.silkscreenTextTheme()]),
    RicochlimeGame.instance.preloadSprites.future,
    RicochlimeIAP.init(),
    RicochlimeAudio.load(),
  ]);

  static List<Task> _sequentialize(List<Future> futures) {
    final length = futures.length;
    final random = Random();
    final targetLoadingTime = defaultTargetPlatform == TargetPlatform.android
        ? const Duration(seconds: 1, milliseconds: 700)
        : const Duration(milliseconds: 700);
    return List.generate(length + 1, (index) {
      if (index == length) {
        return Task(Future.delayed(targetLoadingTime));
      }

      var cumulativeDuration =
          targetLoadingTime * ((index + 1) / (length + 2));
      cumulativeDuration *= random.nextDoubleBetween(0.75, 1.25);
      return Task(
        Future.wait([futures[index], Future.delayed(cumulativeDuration)]),
      );
    }, growable: false);
  }
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    for (final task in LoadingPage.tasks) {
      task.addListener(_checkOnTasks);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkOnTasks();
  }

  @override
  void dispose() {
    for (final task in LoadingPage.tasks) {
      task.removeListener(_checkOnTasks);
    }
    super.dispose();
  }

  int tasksCompleted = 0;
  int tasksTotal = 0;
  void _tallyTasks() {
    var tasksCompleted = 0;
    for (var i = 0; i < LoadingPage.tasks.length - 1; ++i) {
      if (LoadingPage.tasks[i].isComplete) {
        tasksCompleted += 1;
      }
    }
    this.tasksCompleted = tasksCompleted;
    tasksTotal = LoadingPage.tasks.length - 1;
  }

  void _checkOnTasks() {
    if (!mounted) return;

    _tallyTasks();

    if (tasksCompleted >= tasksTotal) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, _, _) => const HomePage(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
      return;
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = tasksTotal > 0
        ? (tasksCompleted / tasksTotal).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Deep winter night sky
              Color(0xFF1976D2), // Midnight blue
              Color(0xFF81D4FA), // Snowy ground horizon
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Title Logo
              const SnowballLogo(fontSize: 34),
              const SizedBox(height: 24),
              // Winter boy art preview
              const CharacterAvatar(skin: 'default', size: 120),
              const Spacer(),
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2463),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF42A5F5),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF29B6F6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Color(0xFF0D47A1),
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class Task extends ChangeNotifier {
  Task(Future future) {
    future.then(_markComplete);
  }

  bool _isComplete = false;
  bool get isComplete => _isComplete;

  void _markComplete(_) {
    _isComplete = true;
    notifyListeners();
  }
}
