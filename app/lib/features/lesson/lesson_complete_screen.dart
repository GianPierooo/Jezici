import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/skills.dart';
import '../../core/feedback/feedback_fx.dart';
import '../../core/theme/app_colors.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../../data/models/progress_models.dart';
import '../../data/models/tip_models.dart';
import '../../data/providers.dart';
import '../notifications/coach_styles.dart';
import '../../ui/daily_goal_bar.dart';
import '../../ui/primary_button.dart';

/// Pantalla de fin: muestra el resumen DEVUELTO POR EL SERVIDOR (complete_lesson).
/// XP, precisión, oro, bonus de combo, racha y las habilidades que subieron, +
/// una tarjeta de TIP (capa "enseña") personalizada a la skill más débil.
class LessonCompleteScreen extends ConsumerStatefulWidget {
  const LessonCompleteScreen({super.key, required this.summary, required this.lessonId});
  final LessonSummary summary;
  final String lessonId;

  @override
  ConsumerState<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends ConsumerState<LessonCompleteScreen> {
  late final ConfettiController _confetti;
  TipModel? _tip;

  static const _skillLabels = kSkillEs;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
    FeedbackFx.lessonComplete(golden: widget.summary.status == 'golden');
    _loadTip();
  }

  Future<void> _loadTip() async {
    try {
      final t = await ref.read(progressRepositoryProvider).getLessonTip(widget.lessonId);
      if (mounted) setState(() => _tip = t);
    } catch (_) {}
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.summary;
    final golden = r.status == 'golden';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
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
                      const ParrotMascot(size: 80, mood: MascotMood.celebrate),
                      const SizedBox(height: 6),
                      Text(
                        golden ? 'LECCIÓN PERFECTA' : 'LECCIÓN COMPLETADA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        golden ? '¡Impecable! 🌟' : '¡Lo lograste! 🎉',
                        style: const TextStyle(
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      _RewardTile(
                        icon: Icons.bolt_rounded,
                        target: r.xpEarned.toDouble(),
                        prefix: '+',
                        label: 'XP GANADO',
                        bg: AppColors.navActiveBg,
                        fg: AppColors.primary,
                        delayMs: 120,
                      ),
                      const SizedBox(width: 12),
                      _RewardTile(
                        icon: Icons.check_circle_outline_rounded,
                        target: r.graded == 0 ? null : r.accuracyPct.toDouble(),
                        suffix: '%',
                        placeholder: '—',
                        label: 'PRECISIÓN',
                        bg: const Color(0xFFE7F9EF),
                        fg: AppColors.success,
                        delayMs: 240,
                      ),
                      const SizedBox(width: 12),
                      _RewardTile(
                        icon: Icons.monetization_on_rounded,
                        target: r.goldEarned.toDouble(),
                        prefix: '+',
                        label: 'ORO',
                        bg: const Color(0xFFFFF4D6),
                        fg: AppColors.goldDark,
                        delayMs: 360,
                      ),
                    ],
                  ),
                  if (r.comboBonus > 0) ...[
                    const SizedBox(height: 13),
                    _InfoRow(
                      leading: const Text('⚡', style: TextStyle(fontSize: 18)),
                      leadingBg: AppColors.coral,
                      title: 'Bonus de combo',
                      subtitle: '+${r.comboBonus} XP · x${r.maxCombo} seguidas',
                      subtitleColor: AppColors.coral,
                    ),
                  ],
                  // Hito de racha alcanzado (7/30/100/365) → celebración extra.
                  if (r.milestone > 0) ...[
                    const SizedBox(height: 13),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold, Color(0xFFFFB02E)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '¡Hito de ${r.milestone} días! Recompensa de oro desbloqueada',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔥 ${r.streak} ${r.streak == 1 ? 'día' : 'días'} de racha',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE8650A),
                                ),
                              ),
                              Text(
                                r.streakAdvanced
                                    ? '¡+1 hoy! Cumpliste tu meta diaria'
                                    : (r.goalMet
                                        ? 'Meta diaria cumplida'
                                        : 'Sigue para cumplir tu meta de hoy'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: r.streakAdvanced || r.goalMet
                                      ? AppColors.successDark
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (r.streakAdvanced)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('+1',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                          ),
                      ],
                    ),
                  ),
                  // Meta de hoy.
                  if (r.dailyGoalXp > 0) ...[
                    const SizedBox(height: 13),
                    DailyGoalBar(
                        earned: r.dailyXpEarned, goal: r.dailyGoalXp, compact: true),
                  ],
                  if (r.skillsUp.isNotEmpty) ...[
                    const SizedBox(height: 13),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'Habilidades que subieron',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final s in r.skillsUp)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7F9EF),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Text(
                                    '${_skillLabels[s] ?? s} ▲',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.successDark,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Tarjeta de TIP (capa "enseña"): personalizada a la skill débil,
                  // en la voz del coach (Matix) del usuario.
                  if (_tip != null) ...[
                    const SizedBox(height: 13),
                    _TipCard(
                      tip: _tip!,
                      coachKey: ref.watch(settingsProvider).value?.coachStyle ??
                          CoachStyle.all.first.key,
                    ),
                  ],
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

/// Tarjeta de TIP en la voz del coach (Matix). Personalizada si el tip cubre la
/// skill más débil del usuario.
class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.coachKey});
  final TipModel tip;
  final String coachKey;

  IconData get _icon => switch (tip.type) {
        'pronunciacion' => Icons.record_voice_over_rounded,
        'nota_cultural' => Icons.public_rounded,
        'error_comun' => Icons.report_problem_rounded,
        'mnemotecnia' => Icons.lightbulb_rounded,
        _ => Icons.school_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final coach = CoachStyle.of(coachKey);
    final personalized = tip.weakSkill != null && tip.skill == tip.weakSkill;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F1FF), Color(0xFFEDE9FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9D2FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(coach.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Matix te enseña · ${tip.typeLabel}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ),
              Icon(_icon, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Text(tip.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 5),
          Text(tip.body,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.4)),
          if (tip.example != null && tip.example!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text(tip.example!,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.35)),
            ),
          ],
          if (personalized) ...[
            const SizedBox(height: 9),
            Text('Te lo doy porque tu ${kSkillEs[tip.skill] ?? tip.skill} necesita un empujón. 🦜',
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.coral)),
          ],
        ],
      ),
    );
  }
}

/// Tile de recompensa con ENTRADA con rebote + CONTADOR animado (cuenta hasta el
/// valor). El "jugo" de la pantalla de fin (Sistema_Diseno §6 · dinamismo).
class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    this.target,
    this.prefix = '',
    this.suffix = '',
    this.placeholder,
    this.delayMs = 0,
  });
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final double? target; // null → muestra placeholder, sin contador
  final String prefix;
  final String suffix;
  final String? placeholder;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _Reveal(
        delayMs: delayMs,
        scaleFrom: 0.7,
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
              target == null
                  ? Text(placeholder ?? '—',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: fg))
                  : TweenAnimationBuilder<double>(
                      // El contador arranca tras la entrada del tile.
                      duration: Duration(milliseconds: 900 + delayMs),
                      curve: Interval(delayMs / (900 + delayMs), 1, curve: Curves.easeOutCubic),
                      tween: Tween(begin: 0, end: target),
                      builder: (_, v, _) => Text('$prefix${v.round()}$suffix',
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: fg)),
                    ),
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
      ),
    );
  }
}

/// Entrada con fade + slide-up + rebote, escalonada por [delayMs]. SIN timers
/// (un único TweenAnimationBuilder con curva `Interval` → determinista en tests).
/// Respeta reduce-motion (aparece directo).
class _Reveal extends StatelessWidget {
  const _Reveal({required this.child, this.delayMs = 0, this.scaleFrom = 1.0});
  final Widget child;
  final int delayMs;
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) return child;
    final total = delayMs + 420;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1, curve: Curves.easeOutBack),
      tween: Tween(begin: 0, end: 1),
      builder: (_, t, child) {
        final o = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: Transform.scale(scale: scaleFrom + (1 - scaleFrom) * t, child: child),
          ),
        );
      },
      child: child,
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
