import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../ui/primary_button.dart';
import 'lesson_result.dart';

/// Pantalla de fin: XP, precisión, bonus de combo, racha y celebración (confeti).
/// NO persiste nada en la BD (eso es el paso E); solo muestra el resumen local.
class LessonCompleteScreen extends StatefulWidget {
  const LessonCompleteScreen({super.key, required this.result});
  final LessonResult result;

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header de celebración.
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.06,
                    numberOfParticles: 14,
                    maxBlastForce: 22,
                    minBlastForce: 8,
                    gravity: 0.25,
                    colors: const [
                      AppColors.gold,
                      AppColors.coral,
                      AppColors.success,
                      Color(0xFF8C7DF2),
                      Colors.white,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🦜', style: TextStyle(fontSize: 90)),
                      const SizedBox(height: 6),
                      Text(
                        'LECCIÓN COMPLETADA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '¡Lo lograste! 🎉',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Recompensas.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      _RewardTile(
                        icon: Icons.bolt_rounded,
                        value: '+${r.xpEarned}',
                        label: 'XP GANADO',
                        bg: AppColors.navActiveBg,
                        fg: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _RewardTile(
                        icon: Icons.check_circle_outline_rounded,
                        value: r.graded == 0 ? '—' : '${r.accuracyPct}%',
                        label: 'PRECISIÓN',
                        bg: const Color(0xFFE7F9EF),
                        fg: AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      _RewardTile(
                        icon: Icons.monetization_on_rounded,
                        value: '+${r.gold}',
                        label: 'ORO',
                        bg: const Color(0xFFFFF4D6),
                        fg: AppColors.goldDark,
                      ),
                    ],
                  ),
                  if (r.comboBonusXp > 0) ...[
                    const SizedBox(height: 13),
                    _InfoRow(
                      leading: const Text('⚡', style: TextStyle(fontSize: 18)),
                      leadingBg: AppColors.coral,
                      title: 'Bonus de combo',
                      subtitle: '+${r.comboBonusXp} XP · x${r.maxCombo} seguidas',
                      subtitleColor: AppColors.coral,
                    ),
                  ],
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF3E6), Color(0xFFFFEDDC)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.streak, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🔥 ${r.streakDays} días de racha',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE8650A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.streak,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('+1 hoy',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  // Vista previa de habilidades (la subida real se guarda en el paso E).
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F9EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.insights_rounded,
                                  color: AppColors.success, size: 20),
                            ),
                            const SizedBox(width: 11),
                            const Expanded(
                              child: Text(
                                'Progreso de habilidades',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            const Icon(Icons.lock_clock_rounded,
                                color: AppColors.textMuted, size: 18),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tus 4 habilidades suben al guardar el progreso (paso E).',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'CONTINUAR',
                    expand: true,
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.bg,
    required this.fg,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: fg, size: 22),
            ),
            const SizedBox(height: 7),
            Text(value,
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: fg)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.leading,
    required this.leadingBg,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
  });
  final Widget leading;
  final Color leadingBg;
  final String title;
  final String subtitle;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: leadingBg, borderRadius: BorderRadius.circular(12)),
            child: leading,
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: subtitleColor)),
            ],
          ),
        ],
      ),
    );
  }
}
