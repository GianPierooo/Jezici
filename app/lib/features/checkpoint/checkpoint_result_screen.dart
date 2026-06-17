import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/checkpoint_models.dart';
import '../../data/models/lesson_model.dart';
import '../../ui/primary_button.dart';
import '../../ui/progress_bar.dart';
import 'checkpoint_intro_screen.dart';

/// Resultado del checkpoint (mockup Frame B): veredicto, desglose por las 4
/// habilidades y la rama aprobado (celebración + desbloqueo) / no (refuerzo + reintento).
class CheckpointResultScreen extends StatefulWidget {
  const CheckpointResultScreen({
    super.key,
    required this.result,
    required this.lesson,
    required this.unitTitle,
  });

  final CheckpointResult result;
  final LessonModel lesson;
  final String unitTitle;

  @override
  State<CheckpointResultScreen> createState() => _CheckpointResultScreenState();
}

class _CheckpointResultScreenState extends State<CheckpointResultScreen> {
  ConfettiController? _confetti;

  static const _order = ['reading', 'listening', 'writing', 'speaking'];
  static const _labels = {
    'reading': 'Reading',
    'listening': 'Listening',
    'writing': 'Writing',
    'speaking': 'Speaking',
  };

  @override
  void initState() {
    super.initState();
    if (widget.result.passed) {
      _confetti = ConfettiController(duration: const Duration(seconds: 2))..play();
    }
  }

  @override
  void dispose() {
    _confetti?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final bySkill = {for (final s in r.perSkill) s.skill: s};
    final skills = [
      for (final k in _order)
        bySkill[k] ?? const SkillScore(skill: '', total: 0, correct: 0, graded: 0, accuracy: null),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(passed: r.passed, scorePct: r.scorePct, confetti: _confetti),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desglose por las 4 habilidades.
                  const Text('Desglose por habilidad',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < _order.length; i++) ...[
                          _SkillRow(skill: _order[i], score: skills[i]),
                          if (i < _order.length - 1) const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (r.passed) ...[
                    _RegionUnlock(nextUnlocked: r.nextUnlocked, unitTitle: widget.unitTitle),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Reward(
                            icon: Icons.bolt_rounded,
                            value: '+${r.xpEarned}',
                            label: 'XP',
                            bg: AppColors.navActiveBg,
                            fg: AppColors.primary),
                        const SizedBox(width: 12),
                        _Reward(
                            icon: Icons.monetization_on_rounded,
                            value: '+${r.goldEarned}',
                            label: 'ORO',
                            bg: const Color(0xFFFFF4D6),
                            fg: AppColors.goldDark),
                      ],
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'CONTINUAR EL VIAJE',
                      expand: true,
                      onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    ),
                  ] else ...[
                    _Reinforce(weaknesses: r.weaknesses, scorePct: r.scorePct, thresholdPct: r.thresholdPct),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'REINTENTAR',
                      expand: true,
                      color: AppColors.coral,
                      depthColor: AppColors.coralDark,
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => CheckpointIntroScreen(
                              lesson: widget.lesson, unitTitle: widget.unitTitle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        child: const Text('Volver al mapa',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.passed, required this.scorePct, required this.confetti});
  final bool passed;
  final int scorePct;
  final ConfettiController? confetti;

  @override
  Widget build(BuildContext context) {
    final colors = passed
        ? const [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)]
        : const [Color(0xFF8C84B8), Color(0xFF6E6796)];
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            ),
          ),
          if (confetti != null)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confetti!,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.06,
                numberOfParticles: 14,
                gravity: 0.25,
                colors: const [AppColors.gold, AppColors.coral, AppColors.success, Colors.white],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🦜', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: passed ? AppColors.success : Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    passed ? '✓ CHECKPOINT APROBADO' : 'CHECKPOINT NO APROBADO',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  passed ? '¡Unidad superada!' : 'Aún no superas el portal',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  passed ? '$scorePct% de aciertos' : '$scorePct% · necesitas 80%',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill, required this.score});
  final String skill;
  final SkillScore score;

  @override
  Widget build(BuildContext context) {
    final label = _CheckpointResultScreenState._labels[skill] ?? skill;
    final graded = score.isGraded;
    final pct = score.accuracyPct;
    final ok = pct >= 80;
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text)),
        ),
        Expanded(
          child: graded
              ? JzProgressBar(
                  value: pct / 100,
                  height: 9,
                  color: ok ? AppColors.success : AppColors.coral,
                )
              : Container(
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F8),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 56,
          child: Text(
            graded ? '$pct%' : 'pronto',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: graded ? (ok ? AppColors.successDark : AppColors.coral) : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _RegionUnlock extends StatelessWidget {
  const _RegionUnlock({required this.nextUnlocked, required this.unitTitle});
  final bool nextUnlocked;
  final String unitTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEAF4FF), Colors.white]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.success, borderRadius: BorderRadius.circular(9)),
            child: Text(
              nextUnlocked ? '✦ NUEVA REGIÓN DESBLOQUEADA' : '✓ UNIDAD COMPLETA',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nextUnlocked
                      ? '¡$unitTitle completa! Se desbloqueó la siguiente región.'
                      : '¡$unitTitle completa! La siguiente región llega pronto.',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward({
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: fg, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: fg)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Reinforce extends StatelessWidget {
  const _Reinforce({required this.weaknesses, required this.scorePct, required this.thresholdPct});
  final List<String> weaknesses;
  final int scorePct;
  final int thresholdPct;

  @override
  Widget build(BuildContext context) {
    final missing = (thresholdPct - scorePct).clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7DAE6), width: 1.5, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Te faltaron $missing puntos para el $thresholdPct%. ¡Casi!',
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 12),
          const Text('REFUERZA ESTAS HABILIDADES',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: AppColors.textMuted)),
          const SizedBox(height: 8),
          if (weaknesses.isEmpty)
            const Text('Repasa la unidad y reintenta.',
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final w in weaknesses)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEFEF),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      _CheckpointResultScreenState._labels[w] ?? w,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.coral),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
