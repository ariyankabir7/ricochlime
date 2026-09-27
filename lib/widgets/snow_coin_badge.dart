// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flutter/material.dart';
import 'package:ricochlime/utils/stows.dart';

/// Styled coin badge with yellow coin icon and count.
class SnowCoinBadge extends StatelessWidget {
  const SnowCoinBadge({
    super.key,
    this.showPlus = false,
    this.onPlusPressed,
  });

  final bool showPlus;
  final VoidCallback? onPlusPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stows.coins,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.85),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coin icon
              Image.asset(
                'assets/images/ui/coin.png',
                width: 22,
                height: 22,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 6),
              // Balance text
              Text(
                '${stows.coins.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              if (showPlus) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onPlusPressed,
                  child: Image.asset(
                    'assets/images/ui/icon_plus.png',
                    width: 18,
                    height: 18,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
