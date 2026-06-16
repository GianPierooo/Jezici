import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../ui/stat_chip.dart';

/// Top bar minimal de "Aprender" (Estructura_App §1, §3): idioma activo · racha ·
/// oro · vidas · mini anillo de meta diaria. Flotante y translúcida.
/// Valores placeholder en el paso C (los stats reales del usuario llegan en E).
class LearnTopBar extends StatelessWidget {
  const LearnTopBar({
    super.key,
    this.streak = 12,
    this.gold = 340,
    this.hearts = 5,
    this.dailyGoal = 0.66,
  });

  final int streak;
  final int gold;
  final int hearts;
  final double dailyGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28326E).withValues(alpha: 0.14),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Idioma activo (bandera).
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FB),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇬🇧', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: AppColors.navInactive),
              ],
            ),
          ),
          Row(
            children: [
              StreakIndicator(days: streak),
              const SizedBox(width: 13),
              GoldCounter(amount: gold),
              const SizedBox(width: 13),
              HeartsIndicator(hearts: hearts),
              const SizedBox(width: 13),
              _DailyGoalRing(value: dailyGoal),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyGoalRing extends StatelessWidget {
  const _DailyGoalRing({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: 4,
              backgroundColor: const Color(0xFFE2DEF8),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
        ],
      ),
    );
  }
}
