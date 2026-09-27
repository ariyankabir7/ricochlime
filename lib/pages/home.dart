// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ricochlime/pages/play.dart';
import 'package:ricochlime/pages/settings.dart';
import 'package:ricochlime/pages/shop.dart';
import 'package:ricochlime/utils/stows.dart';
import 'package:ricochlime/widgets/character_avatar.dart';
import 'package:ricochlime/widgets/snow_coin_badge.dart';
import 'package:ricochlime/widgets/snowball_logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Santa is first/default; removed 'default' character
  final List<Map<String, String>> _characters = const [
    {'id': 'santa', 'name': 'Santa'},
    {'id': 'reindeer', 'name': 'Reindeer'},
    {'id': 'blue_winter', 'name': 'Blue Winter'},
    {'id': 'green_hood', 'name': 'Green Hood'},
    {'id': 'penguin', 'name': 'Penguin'},
  ];

  int _characterIndex = 0;

  // Play button animation
  late final AnimationController _playButtonController;
  late final Animation<double> _playButtonScale;

  @override
  void initState() {
    super.initState();

    // Set santa as default if 'default' skin is stored
    final currentSkin = stows.selectedCharacter.value;
    if (currentSkin == 'default') {
      stows.selectedCharacter.value = 'santa';
    }
    final updatedSkin = stows.selectedCharacter.value;
    final index = _characters.indexWhere((c) => c['id'] == updatedSkin);
    if (index >= 0) {
      _characterIndex = index;
    }

    _playButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _playButtonScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _playButtonController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    super.dispose();
  }

  void _prevCharacter() {
    setState(() {
      _characterIndex = (_characterIndex - 1 + _characters.length) % _characters.length;
      stows.selectedCharacter.value = _characters[_characterIndex]['id']!;
    });
  }

  void _nextCharacter() {
    setState(() {
      _characterIndex = (_characterIndex + 1) % _characters.length;
      stows.selectedCharacter.value = _characters[_characterIndex]['id']!;
    });
  }

  Future<void> _onPlayTap() async {
    await _playButtonController.forward();
    await _playButtonController.reverse();
    if (!mounted) return;
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PlayPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSkin = _characters[_characterIndex]['id']!;
    final currentSkinName = _characters[_characterIndex]['name']!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF81D4FA), // Icy winter sky
                Color(0xFFE1F5FE), // Soft snowy haze
                Color(0xFFB3E5FC), // Snow base
              ],
            ),
          ),
          child: SafeArea(
            bottom: false, // We handle bottom padding manually for nav bar
            child: Column(
              children: [
                // 1. Top Bar: Coins + Settings Cog
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SnowCoinBadge(
                        showPlus: true,
                        onPlusPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ShopPage()),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsPage()),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Color(0x44000000), blurRadius: 4, offset: Offset(0, 3)),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/ui/btn_settings.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Logo
                const SnowballLogo(fontSize: 32),

                const Spacer(),

                // 3. Character Showcase with < and > arrows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildArrowButton(onTap: _prevCharacter, isLeft: true),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        CharacterAvatar(skin: currentSkin, size: 110),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentSkinName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    _buildArrowButton(onTap: _nextCharacter, isLeft: false),
                  ],
                ),

                const Spacer(),

                // 4. Level Card & 3D Play Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF64B5F6), width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x55000000), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Level banner
                        ListenableBuilder(
                          listenable: stows.currentLevel,
                          builder: (context, _) {
                            final level = stows.currentLevel.value;
                            return Column(
                              children: [
                                Text(
                                  'LEVEL $level',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 140,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D47A1),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: ((level % 5) / 5).clamp(0.2, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF00E676), Color(0xFF00C853)],
                                            ),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.card_giftcard_rounded,
                                      color: Color(0xFFFFD54F),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // 3D Gamified Play Button (SVG/Canvas-based, no image)
                        ScaleTransition(
                          scale: _playButtonScale,
                          child: GestureDetector(
                            onTap: _onPlayTap,
                            onTapDown: (_) => _playButtonController.forward(),
                            onTapCancel: () => _playButtonController.reverse(),
                            child: const _GamePlayButton(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // 5. Bottom Navigation Bar with edge-to-edge safe padding
                Container(
                  padding: EdgeInsets.fromLTRB(0, 12, 0, 12 + bottomPadding),
                  decoration: const BoxDecoration(
                    color: Color(0xEE0D47A1),
                    border: Border(
                      top: BorderSide(color: Color(0xFF42A5F5), width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomNavButton(
                        icon: Icons.storefront_rounded,
                        label: 'Store',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ShopPage(initialTab: 0)),
                          );
                        },
                      ),
                      _buildBottomNavButton(
                        icon: Icons.checkroom_rounded,
                        label: 'Characters',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ShopPage(initialTab: 0)),
                          );
                        },
                      ),
                      _buildBottomNavButton(
                        icon: Icons.emoji_events_rounded,
                        label: 'Levels',
                        onTap: () {
                          _showLevelSelectModal(context);
                        },
                      ),
                      _buildBottomNavButton(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton({required VoidCallback onTap, required bool isLeft}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF64B5F6), width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x44000000), blurRadius: 4, offset: Offset(0, 3)),
          ],
        ),
        child: Icon(
          isLeft ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBottomNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF90CAF9), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelSelectModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1565C0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SELECT LEVEL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(10, (index) {
                  final level = index + 1;
                  final unlocked = level <= stows.highestLevelUnlocked.value;
                  return GestureDetector(
                    onTap: unlocked
                        ? () {
                            stows.currentLevel.value = level;
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PlayPage()),
                            );
                          }
                        : null,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: unlocked
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFCA28), Color(0xFFFF8F00)],
                              )
                            : null,
                        color: unlocked ? null : const Color(0xFF37474F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: unlocked ? Colors.white : const Color(0xFF546E7A),
                          width: 2,
                        ),
                        boxShadow: unlocked
                            ? [const BoxShadow(color: Color(0x44000000), blurRadius: 4, offset: Offset(0, 2))]
                            : null,
                      ),
                      child: Center(
                        child: unlocked
                            ? Text(
                                '$level',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : const Icon(Icons.lock, color: Colors.white54, size: 20),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A pure Dart/Canvas 3D-looking gamified play button.
class _GamePlayButton extends StatelessWidget {
  const _GamePlayButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: CustomPaint(
        painter: _PlayButtonPainter(),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
              SizedBox(width: 6),
              Text(
                'PLAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(color: Color(0x88000000), offset: Offset(1, 2), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(28),
    );

    // Bottom "shadow" layer (3D depth effect)
    final bottomRR = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 5, size.width, size.height),
      const Radius.circular(28),
    );
    canvas.drawRRect(
      bottomRR,
      Paint()..color = const Color(0xFFB45309), // dark amber shadow
    );

    // Main gradient fill
    final mainPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFCA28), // bright gold
          Color(0xFFFFA000), // deep amber
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(rr, mainPaint);

    // Top highlight gloss
    final glossRR = RRect.fromRectAndRadius(
      Rect.fromLTWH(6, 3, size.width - 12, size.height * 0.4),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      glossRR,
      Paint()..color = const Color(0x55FFFFFF),
    );

    // Outer border
    canvas.drawRRect(
      rr,
      Paint()
        ..color = const Color(0xFFFFE082)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
