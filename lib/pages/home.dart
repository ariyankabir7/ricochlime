// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ricochlime/pages/play.dart';
import 'package:ricochlime/pages/settings.dart';
import 'package:ricochlime/pages/shop.dart';
import 'package:ricochlime/utils/constants/snowball_palette.dart';
import 'package:ricochlime/utils/stows.dart';
import 'package:ricochlime/widgets/character_avatar.dart';
import 'package:ricochlime/widgets/snow_coin_badge.dart';
import 'package:ricochlime/widgets/snowball_logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> _characters = const [
    {'id': 'default', 'name': 'Default'},
    {'id': 'blue_winter', 'name': 'Blue Winter'},
    {'id': 'green_hood', 'name': 'Green Hood'},
    {'id': 'reindeer', 'name': 'Reindeer'},
    {'id': 'santa', 'name': 'Santa'},
    {'id': 'penguin', 'name': 'Penguin'},
  ];

  int _characterIndex = 0;

  @override
  void initState() {
    super.initState();
    final currentSkin = stows.selectedCharacter.value;
    final index = _characters.indexWhere((c) => c['id'] == currentSkin);
    if (index >= 0) {
      _characterIndex = index;
    }
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

  @override
  Widget build(BuildContext context) {
    final currentSkin = _characters[_characterIndex]['id']!;
    final currentSkinName = _characters[_characterIndex]['name']!;

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
                        child: Image.asset(
                          'assets/images/ui/btn_settings.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                            ),
                            child: const Icon(Icons.settings, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Logo "SNOWBALL SMASH"
                const SnowballLogo(fontSize: 32),

                const Spacer(),

                // 3. Character Showcase with < and > arrows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left arrow
                    GestureDetector(
                      onTap: _prevCharacter,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF64B5F6), width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Character Preview
                    Column(
                      children: [
                        CharacterAvatar(skin: currentSkin, size: 110),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentSkinName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 20),

                    // Right arrow
                    GestureDetector(
                      onTap: _nextCharacter,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF64B5F6), width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // 4. Level Card & Big Yellow Play Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF64B5F6), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
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
                                  'Level $level',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Progress bar with gift box
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
                                            color: const Color(0xFF00E676),
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

                        const SizedBox(height: 14),

                        // Big Yellow Play Button
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PlayPage()),
                            );
                          },
                          child: Image.asset(
                            'assets/images/ui/btn_play_yellow.png',
                            height: 60,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (context, error, stackTrace) => SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const PlayPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SnowballPalette.playButtonYellow,
                                  foregroundColor: Colors.white,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(27),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, size: 36, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Play',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // 5. Bottom Navigation Bar: Store, Characters, Levels, Settings
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xDD1565C0),
                    border: Border(
                      top: BorderSide(color: Color(0xFF64B5F6), width: 1.5),
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
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF90CAF9), width: 1.5),
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
                        color: unlocked ? const Color(0xFFFFB300) : const Color(0xFF37474F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: unlocked ? Colors.white : const Color(0xFF546E7A),
                          width: 2,
                        ),
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
