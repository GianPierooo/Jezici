import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_sheen.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/checkpoint_models.dart';
import '../../data/models/level_exam_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/skill_names.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../practice/practice_player_screen.dart';
import 'certificate_screen.dart';
import 'level_exam_intro_screen.dart';

/// Resultado del EXAMEN de nivel (Examen.dc FRAME A): header de celebración
/// (gradiente + confeti + guacamayo + badge "EXAMEN SUPERADO"), card "Las 4
/// habilidades en el nivel" (barras vs línea de META punteada + chip "N/4 ✓" —
/// la regla real de certificación), card "Puntaje global" (anillo + fortaleza/
/// pulir + grid) y rama reprobado con diagnóstico per-skill + "Reforzar X".
/// Todo con datos REALES del servidor; el percentil del mockup no existe → se
/// omite (honesto). NO cambia scoring/gating/certificación.
class LevelExamResultScreen extends ConsumerStatefulWidget {
  const LevelExamResultScreen({super.key, required this.result});
  final LevelExamResult result;

  @override
  ConsumerState<LevelExamResultScreen> createState() => _LevelExamResultScreenState();
}

class _LevelExamResultScreenState extends ConsumerState<LevelExamResultScreen> {
  ConfettiController? _confetti;
  bool _startingPractice = false;

  static const _order = ['reading', 'listening', 'writing', 'speaking'];

  @override
  void initState() {
    super.initState();
    if (widget.result.passed) {
      _confetti = ConfettiController(duration: const Duration(seconds: 3))..play();
      FeedbackFx.celebrate();
    } else {
      FeedbackFx.wrong();
    }
  }

  @override
  void dispose() {
    _confetti?.dispose();
    super.dispose();
  }

  void _share() {
    final l10n = AppLocalizations.of(context);
    final r = widget.result;
    final c = r.certificate;
    Clipboard.setData(ClipboardData(
        text: c != null
            ? 'Jezici · ${r.level}\nFolio: ${c.folio}\nVerificación: ${c.verificationCode}'
            : 'Jezici · ${r.level} · ${r.scorePct}%'));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating, content: Text(l10n.examShareCopied)));
  }

  /// Refuerza la habilidad floja: práctica por skill si es calificable
  /// (reading/writing en Fase 1), si no la práctica de debilidades general.
  Future<void> _reinforce(String skill) async {
    if (_startingPractice) return;
    setState(() => _startingPractice = true);
    final l10n = AppLocalizations.of(context);
    final gradable = skill == 'reading' || skill == 'writing';
    try {
      final session = await ref
          .read(progressRepositoryProvider)
          .startPractice(gradable ? 'skill' : 'weakness', skill: gradable ? skill : null);
      if (!mounted) return;
      if (session.items.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.practiceNothingToReview)));
        return;
      }
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PracticePlayerScreen(
            mode: gradable ? 'skill' : 'weakness',
            title: skillName(l10n, skill),
            items: session.items),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.practiceStartError)));
      }
    } finally {
      if (mounted) setState(() => _startingPractice = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = widget.result;
    final pass = r.passed;
    final bySkill = {for (final s in r.perSkill) s.skill: s};
    final skills = [
      for (final k in _order)
        bySkill[k] ?? SkillScore(skill: k, total: 0, correct: 0, graded: 0, accuracy: null),
    ];
    final okCount =
        skills.where((s) => s.isGraded && s.accuracyPct >= r.thresholdPct).length;
    // Peor habilidad calificada (diagnóstico del reprobado / "pulir").
    final gradedSkills = skills.where((s) => s.isGraded).toList()
      ..sort((a, b) => a.accuracyPct.compareTo(b.accuracyPct));
    final worst = gradedSkills.isEmpty ? null : gradedSkills.first;
    final best = gradedSkills.isEmpty ? null : gradedSkills.last;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _CelebrationHeader(pass: pass, level: r.level, confetti: _confetti),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, 24 + MediaQuery.paddingOf(context).bottom),
              child: ResponsiveCenter(
                maxWidth: 560,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Veredicto + verificación.
                    Text.rich(
                      TextSpan(
                        text: pass ? '${l10n.examPassedVerdict} ' : '${l10n.examFailedVerdict} ',
                        style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            color: AppColors.text),
                        children: [
                          TextSpan(
                              text: l10n.examLevelWord(r.level),
                              style: TextStyle(
                                  color: pass ? AppColors.primary : AppColors.coral)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (pass) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
                          const SizedBox(width: 6),
                          Text(l10n.examVerifiedBy,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3CA86A))),
                        ],
                      ),
                    ],
                    const SizedBox(height: 15),

                    // ── Las 4 habilidades vs META (la regla de certificación) ──
                    _SkillsVsGoalCard(
                      level: r.level,
                      thresholdPct: r.thresholdPct,
                      skills: skills,
                      okCount: okCount,
                      pass: pass,
                    ),
                    const SizedBox(height: 15),

                    // ── Puntaje global ──
                    _GlobalScoreCard(
                      scorePct: r.scorePct,
                      pass: pass,
                      best: best,
                      worst: worst,
                      skills: gradedSkills,
                    ),
                    const SizedBox(height: 15),

                    if (pass) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _GoldButton(
                              label: l10n.examSeeCertificate,
                              onTap: () {
                                if (r.certificate != null) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              CertificateScreen(cert: r.certificate!)));
                                } else {
                                  Navigator.of(context).popUntil((x) => x.isFirst);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 11),
                          _ShareButton(onTap: _share),
                        ],
                      ),
                      if (r.xpEarned > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                              color: AppColors.navActiveBg,
                              borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            const Icon(Icons.bolt_rounded, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(l10n.examRewards(r.xpEarned, r.goldEarned),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary)),
                            ),
                          ]),
                        ),
                      ],
                    ] else ...[
                      // ── Reprobado: diagnóstico per-skill + reforzar ──
                      if (worst != null)
                        _FailDiagnosis(
                          level: r.level,
                          worst: worst,
                          thresholdPct: r.thresholdPct,
                          busy: _startingPractice,
                          onReinforce: () => _reinforce(worst.skill),
                        ),
                      const SizedBox(height: 14),
                      // Botón 3D de la casa (labio + hundido).
                      PrimaryButton(
                        label: l10n.examRetry,
                        expand: true,
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LevelExamIntroScreen())),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(context).popUntil((x) => x.isFirst),
                          child: Text(l10n.checkpointBackToMap,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textMuted)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header de celebración (Examen.dc) ─────────────────────────────────────────
class _CelebrationHeader extends StatelessWidget {
  const _CelebrationHeader({required this.pass, required this.level, required this.confetti});
  final bool pass;
  final String level;
  final ConfettiController? confetti;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPad = MediaQuery.paddingOf(context).top;
    return Container(
      height: 210 + topPad,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pass
              ? const [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)]
              : const [Color(0xFF8C84B8), Color(0xFF6E6796)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (pass)
            Align(
              alignment: const Alignment(0, -0.2),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.gold.withValues(alpha: 0.4),
                    AppColors.gold.withValues(alpha: 0),
                  ]),
                ),
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
                colors: const [
                  AppColors.gold,
                  AppColors.coral,
                  AppColors.success,
                  Colors.white
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: topPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ParrotMascot(
                    size: 72, mood: pass ? MascotMood.celebrate : MascotMood.encourage),
                const SizedBox(height: 10),
                // Badge dorado "EXAMEN SUPERADO" con sheen (solo al aprobar).
                JzSheen(
                  borderRadius: BorderRadius.circular(10),
                  period: const Duration(milliseconds: 2600),
                  intensity: pass ? 0.5 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: pass
                          ? AppColors.gold.withValues(alpha: 0.95)
                          : Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      pass ? l10n.examPassedBadge : l10n.examFailedBadge,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: pass ? const Color(0xFF5B3A00) : Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card: las 4 habilidades vs META ──────────────────────────────────────────
class _SkillsVsGoalCard extends StatelessWidget {
  const _SkillsVsGoalCard({
    required this.level,
    required this.thresholdPct,
    required this.skills,
    required this.okCount,
    required this.pass,
  });
  final String level;
  final int thresholdPct;
  final List<SkillScore> skills;
  final int okCount;
  final bool pass;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gradedCount = skills.where((s) => s.isGraded).length;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 6), blurRadius: 0),
          BoxShadow(color: Color(0x143C3778), offset: Offset(0, 14), blurRadius: 26),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.examSkillsAtLevel(level),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: okCount >= gradedCount && pass
                      ? const Color(0xFFE5F8EE)
                      : const Color(0xFFFFEFEF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text('$okCount / $gradedCount ${pass ? '✓' : ''}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: okCount >= gradedCount && pass
                            ? const Color(0xFF1B8E4E)
                            : AppColors.coral)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(pass ? l10n.examSkillsWhyCertified : l10n.examSkillsGoalHint(thresholdPct),
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF9A9FB8))),
          const SizedBox(height: 16),
          // Barras con línea de META punteada al umbral real.
          LayoutBuilder(builder: (context, cons) {
            const labelW = 74.0;
            const trailW = 46.0;
            final barW = cons.maxWidth - labelW - trailW - 20;
            final goalX = labelW + 10 + barW * (thresholdPct / 100);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    for (final s in skills) _bar(context, s),
                  ],
                ),
                // Línea META punteada.
                Positioned(
                  left: goalX,
                  top: -4,
                  bottom: 4,
                  child: CustomPaint(
                    size: const Size(2, double.infinity),
                    painter: _DashedLinePainter(),
                  ),
                ),
                Positioned(
                  left: goalX - 24,
                  top: -16,
                  child: Text(l10n.examGoalTag(level),
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary)),
                ),
              ],
            );
          }),
          // Escala.
          Padding(
            padding: const EdgeInsets.only(left: 84, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0%',
                    style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFC2C6D6))),
                Text('$thresholdPct%',
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const Text('100%',
                    style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFC2C6D6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, SkillScore s) {
    final l10n = AppLocalizations.of(context);
    final graded = s.isGraded;
    final pct = s.accuracyPct;
    final ok = graded && pct >= thresholdPct;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(skillName(l10n, s.skill),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.text)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: graded ? (pct / 100).clamp(0.0, 1.0) : 0,
                minHeight: 14,
                backgroundColor: const Color(0xFFF0F1F8),
                valueColor: AlwaysStoppedAnimation(
                    ok ? AppColors.success : (graded ? AppColors.coral : const Color(0xFFF0F1F8))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: graded
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('$pct',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: ok ? AppColors.success : AppColors.coral)),
                      if (ok)
                        const Icon(Icons.check_rounded, size: 13, color: AppColors.success),
                    ],
                  )
                : Text(l10n.checkpointSkillSoon,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.75)
      ..strokeWidth = 2;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 5), paint);
      y += 10;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => false;
}

// ── Card: puntaje global ─────────────────────────────────────────────────────
class _GlobalScoreCard extends StatelessWidget {
  const _GlobalScoreCard({
    required this.scorePct,
    required this.pass,
    required this.best,
    required this.worst,
    required this.skills,
  });
  final int scorePct;
  final bool pass;
  final SkillScore? best;
  final SkillScore? worst;
  final List<SkillScore> skills;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 6), blurRadius: 0),
          BoxShadow(color: Color(0x143C3778), offset: Offset(0, 14), blurRadius: 26),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Anillo N/100 (dato real del examen).
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 74,
                      height: 74,
                      child: CircularProgressIndicator(
                        value: (scorePct / 100).clamp(0.0, 1.0),
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFFF0F1F8),
                        valueColor: AlwaysStoppedAnimation(
                            pass ? AppColors.primary : AppColors.coral),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$scorePct',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                color: AppColors.text)),
                        const Text('/100',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF9A9FB8))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.examGlobalScore,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        if (best != null)
                          _chip('↑ ${l10n.examStrength}: ${skillName(l10n, best!.skill)}',
                              const Color(0xFFE5F8EE), const Color(0xFF1B8E4E)),
                        if (worst != null && worst!.skill != best?.skill)
                          _chip('↗ ${l10n.examPolish}: ${skillName(l10n, worst!.skill)}',
                              const Color(0xFFFFF4D6), const Color(0xFFC98A12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (skills.length >= 2) ...[
            Container(
                height: 1.5, color: const Color(0xFFF0F1F8), margin: const EdgeInsets.symmetric(vertical: 14)),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 11,
              crossAxisSpacing: 11,
              childAspectRatio: 5.2,
              children: [
                for (final s in skills)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(skillName(l10n, s.skill),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text)),
                          ),
                          Text('${s.accuracyPct}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: (s.accuracyPct / 100).clamp(0.0, 1.0),
                          minHeight: 7,
                          backgroundColor: const Color(0xFFF0F1F8),
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: fg)),
      );
}

// ── Reprobado: diagnóstico per-skill + reforzar ──────────────────────────────
class _FailDiagnosis extends StatelessWidget {
  const _FailDiagnosis({
    required this.level,
    required this.worst,
    required this.thresholdPct,
    required this.busy,
    required this.onReinforce,
  });
  final String level;
  final SkillScore worst;
  final int thresholdPct;
  final bool busy;
  final VoidCallback onReinforce;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = skillName(l10n, worst.skill);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DAE6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 66,
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7A809B))),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (worst.accuracyPct / 100).clamp(0.0, 1.0),
                    minHeight: 11,
                    backgroundColor: const Color(0xFFEFF0F6),
                    valueColor: const AlwaysStoppedAnimation(AppColors.coral),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${worst.accuracyPct}%',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.hearts)),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: '${l10n.examNotYetCertified(level)}: ',
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text),
              children: [
                TextSpan(
                    text: l10n.examRaiseSkill(name),
                    style: const TextStyle(color: AppColors.hearts)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: busy ? null : onReinforce,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: Color(0xFFDCD8FB), width: 1.5),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: busy
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2))
                  : Text('${l10n.examReinforceSkill(name)} →',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Labio 3D en un DecoratedBox EXTERNO (para que el sheen, que clippa, no lo
      // recorte); el sheen barre solo la superficie dorada del CTA.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(color: Color(0xFFD69400), offset: Offset(0, 6), blurRadius: 0),
          ],
        ),
        child: JzSheen(
          borderRadius: BorderRadius.circular(17),
          period: const Duration(milliseconds: 2800),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [Color(0xFFFFDD7A), AppColors.gold]),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.text, size: 19),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.navActiveBg,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(color: Color(0xFFDCD8FB), offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: const Icon(Icons.share_rounded, color: AppColors.primary, size: 22),
      ),
    );
  }
}
