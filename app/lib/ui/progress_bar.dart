import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Barra de progreso redondeada (meta diaria / plan / avance de nivel).
class JzProgressBar extends StatelessWidget {
  const JzProgressBar({
    super.key,
    required this.value, // 0..1
    this.height = 12,
    this.color = AppColors.primary,
    this.trackColor = const Color(0xFFE2DEF8),
  });

  final double value;
  final double height;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: trackColor),
          FractionallySizedBox(
            widthFactor: clamped,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
