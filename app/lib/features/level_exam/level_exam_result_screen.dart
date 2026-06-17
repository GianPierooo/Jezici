import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/checkpoint_models.dart';
import '../../data/models/level_exam_models.dart';
import 'certificate_screen.dart';

/// Resultados del examen de nivel: veredicto + desglose por habilidad. Si aprobó,
/// lleva al certificado.
class LevelExamResultScreen extends StatelessWidget {
  const LevelExamResultScreen({super.key, required this.result});
  final LevelExamResult result;

  static const _labels = {
    'reading': 'Reading', 'listening': 'Listening', 'writing': 'Writing', 'speaking': 'Speaking'
  };

  @override
  Widget build(BuildContext context) {
    final r = result;
    final pass = r.passed;
    final accent = pass ? AppColors.success : AppColors.coral;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Text(pass ? '🎓' : '💪', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 6),
            Text(pass ? '¡Aprobaste el examen A1!' : 'Aún no, ¡casi!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 4),
            Text('Puntaje ${r.scorePct}% · necesitas ${r.thresholdPct}%',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: accent)),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Por habilidad',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                        const SizedBox(height: 12),
                        for (final s in r.perSkill) _SkillRow(score: s),
                      ],
                    ),
                  ),
                  if (pass && r.xpEarned > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('+${r.xpEarned} XP · +${r.goldEarned} oro por certificar',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (pass && r.certificate != null) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => CertificateScreen(cert: r.certificate!)));
                    } else {
                      Navigator.of(context).popUntil((x) => x.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pass ? AppColors.gold : AppColors.primary,
                    foregroundColor: pass ? AppColors.text : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(pass ? 'VER MI CERTIFICADO 🎓' : 'VOLVER',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.score});
  final SkillScore score;
  @override
  Widget build(BuildContext context) {
    final label = LevelExamResultScreen._labels[score.skill] ?? score.skill;
    final graded = score.isGraded;
    final pct = score.accuracyPct;
    final color = !graded
        ? AppColors.textMuted
        : (pct >= 80 ? AppColors.success : (pct >= 50 ? AppColors.goldDark : AppColors.coral));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
              Text(graded ? '$pct%' : 'participación',
                  style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: graded ? pct / 100 : 0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2DEF8),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
