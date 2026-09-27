// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flutter/material.dart';

/// Renders the authentic pixel-art front-facing character sprites for menus and store.
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.skin,
    this.size = 100,
  });

  final String skin;
  final double size;

  static const _validSkins = {
    'default',
    'blue_winter',
    'green_hood',
    'reindeer',
    'santa',
    'penguin',
  };

  @override
  Widget build(BuildContext context) {
    final effectiveSkin = _validSkins.contains(skin) ? skin : 'default';

    return SizedBox(
      width: size,
      height: size * 1.25,
      child: Center(
        child: Image.asset(
          'assets/images/characters/$effectiveSkin.png',
          width: size,
          height: size * 1.25,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              color: Colors.white,
              size: 48,
            );
          },
        ),
      ),
    );
  }
}
