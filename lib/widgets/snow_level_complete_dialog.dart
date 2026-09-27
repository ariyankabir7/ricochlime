// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flutter/material.dart';

/// Modal dialog shown upon completing a level.
class SnowLevelCompleteDialog extends StatelessWidget {
  const SnowLevelCompleteDialog({
    super.key,
    required this.level,
    required this.coinsEarned,
    required this.snowballsEarned,
    required this.onNextLevel,
    required this.onHome,
  });

  final int level;
  final int coinsEarned;
  final int snowballsEarned;
  final VoidCallback onNextLevel;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF90CAF9), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Banner
            Image.asset(
              'assets/images/ui/panel_level_complete.png',
              height: 58,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (context, error, stackTrace) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.star, color: Color(0xFFFFD54F), size: 36),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              'LEVEL $level COMPLETE!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(color: Color(0xFF0D47A1), offset: Offset(2, 2)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Reward Cards
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Coins
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/ui/coin.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFD54F),
                          ),
                          child: const Center(
                            child: Text(
                              '\$',
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+$coinsEarned',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Snowballs
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/ui/snowball_sphere.png',
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Icon(Icons.ac_unit, color: Color(0xFF29B6F6), size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+$snowballsEarned',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Next Level button
            GestureDetector(
              onTap: onNextLevel,
              child: Image.asset(
                'assets/images/ui/btn_next_level.png',
                height: 52,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onNextLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NEXT LEVEL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Home button
            TextButton.icon(
              onPressed: onHome,
              icon: Image.asset(
                'assets/images/ui/btn_home.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.home, color: Color(0xFFBBDEFB), size: 18),
              ),
              label: const Text(
                'Back to Menu',
                style: TextStyle(
                  color: Color(0xFFBBDEFB),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
