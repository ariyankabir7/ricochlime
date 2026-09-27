// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flutter/material.dart';
import 'package:ricochlime/utils/stows.dart';

/// Modal dialog shown upon game over (when snowman crosses danger line).
class SnowGameOverDialog extends StatelessWidget {
  const SnowGameOverDialog({
    super.key,
    required this.onRestart,
    required this.onContinue,
    required this.onHome,
  });

  final VoidCallback onRestart;
  final VoidCallback onContinue;
  final VoidCallback onHome;

  static const int continueCost = 50;

  @override
  Widget build(BuildContext context) {
    final canContinue = stows.coins.value >= continueCost;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFB71C1C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEF9A9A), width: 3),
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
              'assets/images/ui/panel_game_over.png',
              height: 58,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFFD54F),
                size: 48,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'GAME OVER',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A snowman crossed the danger line!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFCDD2),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            // Continue with coins button
            if (canContinue) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    stows.coins.value -= continueCost;
                    onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ui/coin.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.refresh, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continue ($continueCost Coins)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Restart button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onRestart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/ui/btn_retry.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.refresh, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'RESTART LEVEL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Back to Menu
            TextButton.icon(
              onPressed: onHome,
              icon: Image.asset(
                'assets/images/ui/btn_home.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.home, color: Color(0xFFFFCDD2), size: 18),
              ),
              label: const Text(
                'Back to Menu',
                style: TextStyle(
                  color: Color(0xFFFFCDD2),
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
