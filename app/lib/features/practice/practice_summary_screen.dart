import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/practice_models.dart';

/// Resumen de una sesión de práctica (datos del servidor).
class PracticeSummaryScreen extends StatelessWidget {
  const PracticeSummaryScreen({super.key, required this.summary});
  final PracticeSummary summary;

  @override
  Widget build(BuildContext context) {
    final r = summary;
    final perfect = r.graded > 0 && r.correct == r.graded;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              Text(perfect ? '🌟' : '🦜', style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              Text(
                r.graded == 0
                    ? '¡Práctica hecha!'
                    : (perfect ? '¡Sesión impecable!' : '¡Buen repaso!'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text),
              ),
              const SizedBox(height: 4),
              Text(
                r.graded == 0
                    ? 'Practicaste sin penalización.'
                    : 'Acertaste ${r.correct} de ${r.graded}.',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  _Tile(icon: Icons.bolt_rounded, value: '+${r.xpEarned}', label: 'XP', color: AppColors.primary),
                  const SizedBox(width: 12),
                  _Tile(
                      icon: Icons.check_circle_outline_rounded,
                      value: r.graded == 0 ? '—' : '${r.accuracyPct}%',
                      label: 'PRECISIÓN',
                      color: AppColors.success),
                  const SizedBox(width: 12),
                  _Tile(icon: Icons.monetization_on_rounded, value: '+${r.goldEarned}', label: 'ORO', color: AppColors.goldDark),
                ],
              ),
              if (r.streakAdvanced) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFF3E6), Color(0xFFFFEDDC)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.streak, size: 24),
                    const SizedBox(width: 10),
                    Text('🔥 ${r.streak} días — ¡la práctica también suma!',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, color: Color(0xFFE8650A), fontSize: 14)),
                  ]),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('LISTO',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.3, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}
