// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flutter/material.dart';

/// Styled 3D winter logo for "SNOWBALL SMASH".
class SnowballLogo extends StatelessWidget {
  const SnowballLogo({super.key, this.fontSize = 28, this.width = 240});

  final double fontSize;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/snowball_smash_logo.png',
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SNOWBALL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: const Color(0xFFE1F5FE),
                shadows: const [
                  Shadow(color: Color(0xFF0277BD), offset: Offset(2, 2)),
                  Shadow(color: Color(0xFF01579B), offset: Offset(3, 4), blurRadius: 2),
                ],
              ),
            ),
            Text(
              'SMASH',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize * 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                color: const Color(0xFFFFB300),
                shadows: const [
                  Shadow(color: Color(0xFFE65100), offset: Offset(2, 2)),
                  Shadow(color: Color(0xFFBF360C), offset: Offset(3, 4), blurRadius: 2),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
