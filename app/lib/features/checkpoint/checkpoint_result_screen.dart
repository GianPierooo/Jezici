import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/checkpoint_models.dart';
import '../../data/models/lesson_model.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/skill_names.dart';
import '../../ui/primary_button.dart';
import '../../ui/progress_bar.dart';
import '../learn/widgets/parrot_mascot.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.result.passed) {
      _confetti = ConfettiController(duration: const Duration(seconds: 2))..play();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              // + inset inferior para que el botón al final del scroll despeje la barra
              // de navegación de Android (sweep del mismo patrón de corte).
              padding: EdgeInsets.fromLTRB(20, 18, 20, 24 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desglose por las 4 habilidades.
                  Text(l10n.checkpointSkillsBreakdown,
                      style: const TextStyle(
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
                      label: l10n.checkpointContinueJourney,
                      expand: true,
                      onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    ),
                  ] else ...[
                    _Reinforce(
                        weaknesses: r.weaknesses,
                        perSkill: r.perSkill,
                        scorePct: r.scorePct,
                        thresholdPct: r.thresholdPct),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: l10n.checkpointRetry,
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
                        child: Text(l10n.checkpointBackToMap,
                            style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
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
          // Halo dorado detrás del guacamayo (jzGlow del mockup, estático-suave).
          if (passed)
            Align(
              alignment: const Alignment(0, -0.55),
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.gold.withValues(alpha: 0.35),
                    AppColors.gold.withValues(alpha: 0),
                  ]),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ParrotMascot(
                    size: 72,
                    mood: passed ? MascotMood.celebrate : MascotMood.encourage),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: passed ? AppColors.success : Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    passed ? l10n.checkpointPassedLabel : l10n.checkpointFailedLabel,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  passed ? l10n.checkpointPassedMsg : l10n.checkpointFailedMsg,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  passed ? l10n.checkpointPassedScore(scorePct) : l10n.checkpointFailedScore(scorePct),
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
    final l10n = AppLocalizations.of(context);
    final label = skillName(l10n, skill);
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
            graded ? '$pct%' : l10n.checkpointSkillSoon,
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
    final l10n = AppLocalizations.of(context);
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
              nextUnlocked ? l10n.checkpointRegionUnlockedLabel : l10n.checkpointCompleteLabel,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white),
            ),
          ),
          // Mini-mapa del desbloqueo (Checkpoint.dc): portal superado (✓) →
          // camino punteado → siguiente región con glow. El "momento wow".
          if (nextUnlocked) ...[
            SizedBox(
              height: 112,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _UnlockMapPainter()),
                  ),
                  // Portal superado (izquierda).
                  Positioned(
                    left: 4,
                    top: 28,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 50,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 48,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFF8474F0), AppColors.primary]),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14), bottom: Radius.circular(10)),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: AppColors.primaryDark,
                                        offset: Offset(0, 4),
                                        blurRadius: 0)
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  width: 20,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Color(0xFFFFE9A8), AppColors.gold]),
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10), bottom: Radius.circular(4)),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -4,
                                left: 15,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(l10n.checkpointMapDone,
                            style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                  // Siguiente región con glow (derecha).
                  Positioned(
                    right: 2,
                    top: 8,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    AppColors.success.withValues(alpha: 0.4),
                                    AppColors.success.withValues(alpha: 0),
                                  ]),
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFF3FD97E), AppColors.success]),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.successDark,
                                        offset: Offset(0, 4),
                                        blurRadius: 0)
                                  ],
                                ),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(l10n.checkpointMapNext,
                            style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B8E4E))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nextUnlocked
                      ? l10n.checkpointRegionUnlockedMsg(unitTitle)
                      : l10n.checkpointCompleteSoonMsg(unitTitle),
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

/// Fondo del mini-mapa: colina + costa insinuada + camino punteado que pasa de
/// violeta (recorrido) a verde (por recorrer) — Checkpoint.dc.
class _UnlockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Colina.
    final hill = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.27, h * 0.56, w * 0.54, h * 0.74)
      ..quadraticBezierTo(w * 0.78, h * 0.88, w, h * 0.52)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFFD9F0E2));
    // Costa insinuada (derecha).
    final coast = Path()
      ..moveTo(w * 0.74, h * 0.56)
      ..quadraticBezierTo(w * 0.87, h * 0.5, w, h * 0.56)
      ..lineTo(w, h)
      ..lineTo(w * 0.74, h)
      ..close();
    canvas.drawPath(coast, Paint()..color = const Color(0xFFBFE7F0).withValues(alpha: 0.7));
    // Camino punteado: tramo recorrido (violeta) y tramo nuevo (verde).
    void dots(Path p, Color color) {
      final paint = Paint()..color = color;
      for (final m in p.computeMetrics()) {
        var d = 0.0;
        while (d < m.length) {
          final t = m.getTangentForOffset(d);
          if (t != null) canvas.drawCircle(t.position, 2.4, paint);
          d += 12;
        }
      }
    }

    dots(
      Path()
        ..moveTo(w * 0.17, h * 0.62)
        ..quadraticBezierTo(w * 0.3, h * 0.54, w * 0.45, h * 0.64),
      const Color(0xFFC7BEF0),
    );
    dots(
      Path()
        ..moveTo(w * 0.55, h * 0.58)
        ..quadraticBezierTo(w * 0.72, h * 0.48, w * 0.86, h * 0.34),
      const Color(0xFF9FD9C2),
    );
  }

  @override
  bool shouldRepaint(covariant _UnlockMapPainter old) => false;
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
  const _Reinforce({
    required this.weaknesses,
    required this.perSkill,
    required this.scorePct,
    required this.thresholdPct,
  });
  final List<String> weaknesses;
  final List<SkillScore> perSkill;
  final int scorePct;
  final int thresholdPct;

  static const _skillIcons = {
    'reading': Icons.menu_book_rounded,
    'listening': Icons.headphones_rounded,
    'writing': Icons.edit_rounded,
    'speaking': Icons.mic_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missing = (thresholdPct - scorePct).clamp(0, 100);
    // Fallos REALES por habilidad (total - correct de los ítems calificados).
    // (El servidor no expone fallos por TEMA → degradación honesta al dato real.)
    final fails = [
      for (final s in perSkill)
        if (s.isGraded && (s.graded - s.correct) > 0) (s.skill, s.graded - s.correct),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
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
          // Anillo de score (Checkpoint.dc): "64%" + te faltaron N puntos.
          Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        value: (scorePct / 100).clamp(0.0, 1.0),
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFFF0F1F8),
                        valueColor: const AlwaysStoppedAnimation(AppColors.coral),
                      ),
                    ),
                    Text('$scorePct%',
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.hearts)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.checkpointMissingPoints(missing, thresholdPct),
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(l10n.checkpointReinforceTitle,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: AppColors.textMuted)),
          const SizedBox(height: 8),
          if (fails.isEmpty && weaknesses.isEmpty)
            Text(l10n.checkpointReinforceEmpty,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textMuted))
          else if (fails.isNotEmpty)
            // Filas con CONTEO DE FALLOS reales (formato del mockup).
            Column(
              children: [
                for (final (skill, n) in fails)
                  Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEF0F7), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFEFEF),
                              borderRadius: BorderRadius.circular(7)),
                          child: Icon(_skillIcons[skill] ?? Icons.star_rounded,
                              size: 13, color: AppColors.coral),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(skillName(l10n, skill),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.text)),
                        ),
                        Text(l10n.checkpointFailCount(n),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.hearts)),
                      ],
                    ),
                  ),
              ],
            )
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
                      skillName(l10n, w),
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
