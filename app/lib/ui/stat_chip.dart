import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Indicador compacto de un stat (icono + número), para la top bar:
/// racha 🔥, oro 🪙, vidas ❤️.
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

/// Contador de oro (🪙).
class GoldCounter extends StatelessWidget {
  const GoldCounter({super.key, required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return StatChip(
      icon: Icons.monetization_on_rounded,
      value: '$amount',
      color: AppColors.goldDark,
    );
  }
}

/// Indicador de vidas (❤️).
class HeartsIndicator extends StatelessWidget {
  const HeartsIndicator({super.key, required this.hearts});
  final int hearts;

  @override
  Widget build(BuildContext context) {
    return StatChip(
      icon: Icons.favorite_rounded,
      value: '$hearts',
      color: AppColors.hearts,
    );
  }
}

/// Indicador de racha (🔥).
class StreakIndicator extends StatelessWidget {
  const StreakIndicator({super.key, required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return StatChip(
      icon: Icons.local_fire_department_rounded,
      value: '$days',
      color: AppColors.streak,
    );
  }
}
