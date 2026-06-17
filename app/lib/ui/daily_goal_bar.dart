import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'progress_bar.dart';

/// Barra "Meta de hoy: Y/X XP" (Estructura_App §8). El objetivo X sale de la
/// intensidad/ritmo elegido en el onboarding; al cumplirlo, se marca el día.
class DailyGoalBar extends StatelessWidget {
  const DailyGoalBar({
    super.key,
    required this.earned,
    required this.goal,
    this.compact = false,
  });

  final int earned;
  final int goal;
  final bool compact;

  bool get _met => goal > 0 && earned >= goal;
  double get _value => goal <= 0 ? 0 : (earned / goal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final color = _met ? AppColors.success : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 13 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_met ? Icons.check_circle_rounded : Icons.bolt_rounded,
                  color: color, size: 20),
              const SizedBox(width: 8),
              const Text('Meta de hoy',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
              const Spacer(),
              Text('$earned/$goal XP',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          const SizedBox(height: 9),
          JzProgressBar(value: _value, height: 10, color: color),
          if (_met) ...[
            const SizedBox(height: 8),
            const Text('¡Meta cumplida! Tu racha avanza hoy 🔥',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.successDark)),
          ] else ...[
            const SizedBox(height: 8),
            Text('Te faltan ${(goal - earned).clamp(0, goal)} XP para cumplir hoy',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}
