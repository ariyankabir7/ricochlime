// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ricochlime/i18n/strings.g.dart';
import 'package:ricochlime/utils/stows.dart';
import 'package:ricochlime/utils/version.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SETTINGS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(color: Color(0x55000000), offset: Offset(0, 2), blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Scrollable settings list
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
                  children: [
                    _SettingsSectionHeader(t.settingsPage.gameplay),

                    // Background music volume
                    _SettingsSliderTile(
                      icon: Icons.music_note_rounded,
                      title: t.settingsPage.bgmVolume,
                      listenable: stows.bgmVolume,
                      onChanged: (v) => stows.bgmVolume.value = v,
                    ),

                    const SizedBox(height: 8),

                    // Sound effects volume
                    _SettingsSliderTile(
                      icon: Icons.volume_up_rounded,
                      title: t.settingsPage.sfxVolume,
                      listenable: stows.sfxVolume,
                      onChanged: (v) => stows.sfxVolume.value = v,
                    ),

                    const SizedBox(height: 8),

                    // Aim guide reflection toggle
                    ValueListenableBuilder(
                      valueListenable: stows.showReflectionInAimGuide,
                      builder: (context, value, _) => _SettingsToggleTile(
                        icon: Icons.track_changes_rounded,
                        title: t.settingsPage.showReflectionInAimGuide,
                        value: value,
                        onChanged: (v) => stows.showReflectionInAimGuide.value = v,
                      ),
                    ),

                    _SettingsSectionHeader(t.settingsPage.appInfo),

                    // App info
                    _SettingsTapTile(
                      icon: Icons.info_outline_rounded,
                      title: t.settingsPage.appInfo,
                      onTap: () {
                        final screenWidth = MediaQuery.sizeOf(context).width;
                        final iconSize = min<double>(64, screenWidth * 0.15);
                        showAboutDialog(
                          context: context,
                          applicationName: t.appName,
                          applicationVersion: 'v$buildName ($buildNumber)',
                          applicationIcon: Image.asset(
                            'assets/icon/icon.png',
                            width: iconSize,
                            height: iconSize,
                          ),
                          applicationLegalese: t.settingsPage.licenseNotice(
                            buildYear: buildYear,
                          ),
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
    );
  }
}


/// Section header with a divider line.
class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF90CAF9),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0x5590CAF9),
            ),
          ),
        ],
      ),
    );
  }
}

/// A settings card with a slider.
class _SettingsSliderTile extends StatelessWidget {
  const _SettingsSliderTile({
    required this.icon,
    required this.title,
    required this.listenable,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final ValueNotifier<double> listenable;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x3364B5F6), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                ListenableBuilder(
                  listenable: listenable,
                  builder: (context, _) => SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF29B6F6),
                      inactiveTrackColor: const Color(0xFF0D47A1),
                      thumbColor: Colors.white,
                      overlayColor: const Color(0x2229B6F6),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: listenable.value,
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A settings card with a toggle switch.
class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x3364B5F6), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF29B6F6),
              activeTrackColor: const Color(0xFF0D47A1),
              inactiveThumbColor: Colors.white60,
              inactiveTrackColor: const Color(0xFF0D47A1),
            ),
          ],
        ),
      ),
    );
  }
}

/// A settings card that responds to a tap.
class _SettingsTapTile extends StatelessWidget {
  const _SettingsTapTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x3364B5F6), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
