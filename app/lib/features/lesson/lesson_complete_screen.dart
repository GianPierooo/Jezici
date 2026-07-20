import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/plan/estimation.dart';
import '../../core/speech/speakable_text.dart';
import '../../core/ui/jz_transitions.dart';
import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../practice/srs_review_screen.dart';
import '../reference/reference_screen.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/progress_models.dart';
import '../../data/models/tip_models.dart';
import '../../data/models/unit_model.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/skill_names.dart';
import '../notifications/coach_styles.dart';
import '../notifications/matix_auto.dart';
import '../notifications/push_install_cards.dart' show InstallValueMomentCard;
import 'lesson_preview_screen.dart';
import '../../ui/daily_goal_bar.dart';
import '../../core/ui/jz_glow_pulse.dart';
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
  bool _startingReview = false;

  /// La SIGUIENTE lección del mapa (el servidor la devuelve en `next_lesson_id`).
  /// Se resuelve contra `mapUnitsProvider` (normalmente ya cacheado: se viene del
  /// mapa). `watch` y no `read`: si el mapa aún está cargando, el CTA se actualiza
  /// solo al llegar en vez de quedarse degradado para siempre. null si no hay
  /// siguiente (fin de unidad) o no se encuentra → el CTA cae a "volver al mapa".
  LessonModel? _nextLesson() {
    final id = widget.summary.nextLessonId;
    if (id == null || id.isEmpty) return null;
    for (final u in ref.watch(mapUnitsProvider).value ?? const <UnitModel>[]) {
      for (final l in u.lessons) {
        if (l.id == id) return l;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
    FeedbackFx.lessonComplete(golden: widget.summary.status == 'golden');
    // Refresca los niveles de skill: complete_lesson ya corrió en el servidor →
    // la tarjeta del fin muestra el CEFR/progreso POST-lección (dato fresco real).
    ref.invalidate(skillsProvider);
    // El SRS acaba de inscribir el vocabulario de esta lección (server-side).
    // Refrescamos su estado para saber si ofrecer "Repasar N" (E1): teje el
    // repaso en el loop de aprendizaje. Read-only (get_srs_status).
    ref.invalidate(srsStatusProvider);
    _loadTip();
    // T4 · Matix: si con esta lección quedó CUMPLIDA la meta diaria → goal_met
    // (positivo; el server capa 1/día y respeta estilo/idioma/quiet hours).
    ref.read(matixAutoProvider).afterLesson(
        goalXp: widget.summary.dailyGoalXp, earnedXp: widget.summary.dailyXpEarned);
  }

  Future<void> _loadTip() async {
    try {
      final t = await ref.read(progressRepositoryProvider).getLessonTip(widget.lessonId);
      if (mounted) setState(() => _tip = t);
    } catch (_) {}
  }

  /// E1 · Repasar AHORA lo que la lección acaba de enseñar (teje el repaso en el
  /// loop). Abre la MISMA sesión de repaso del SRS que Practicar (start_practice
  /// 'srs' → SrsReviewScreen). No toca economía/motor: solo navega a lo que ya
  /// existe. Vuelve al mapa primero (deja la pila limpia) y abre el repaso.
  Future<void> _startReview() async {
    if (_startingReview) return;
    setState(() => _startingReview = true);
    final nav = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final s = await ref.read(progressRepositoryProvider).startSrs();
      if (!mounted) return;
      nav.popUntil((route) => route.isFirst);
      if (s.cards.isNotEmpty) {
        nav.push(MaterialPageRoute(builder: (_) => SrsReviewScreen(session: s)));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _startingReview = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.practiceStartError)));
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                        golden ? l10n.lessonCompletePerfectTitle : l10n.lessonCompleteTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        golden ? l10n.lessonCompletePerfectMsg : l10n.lessonCompleteMsg,
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
              child: ResponsiveCenter(
                maxWidth: 480,
                child: Column(
                  children: [
                  Row(
                    children: [
                      _RewardTile(
                        icon: Icons.bolt_rounded,
                        target: r.xpEarned.toDouble(),
                        prefix: '+',
                        label: l10n.lessonCompleteXpLabel,
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
                        label: l10n.lessonCompleteAccuracyLabel,
                        bg: const Color(0xFFE7F9EF),
                        fg: AppColors.success,
                        delayMs: 240,
                      ),
                      const SizedBox(width: 12),
                      _RewardTile(
                        icon: Icons.monetization_on_rounded,
                        target: r.goldEarned.toDouble(),
                        prefix: '+',
                        label: l10n.lessonCompleteGoldLabel,
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
                      title: l10n.lessonCompleteComboBonusLabel,
                      subtitle: l10n.lessonCompleteComboDetail(r.comboBonus, r.maxCombo),
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
                              l10n.lessonCompleteMilestone(r.milestone),
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
                                l10n.lessonCompleteStreakDays(r.streak),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE8650A),
                                ),
                              ),
                              Text(
                                r.streakAdvanced
                                    ? l10n.lessonCompleteStreakAdvanced
                                    : (r.goalMet
                                        ? l10n.lessonCompleteGoalMet
                                        : l10n.lessonCompleteGoalPending),
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
                  // Congelador de racha: aviso cuando salvó la racha tras un hueco.
                  if (r.streakFreezeUsed > 0) ...[
                    const SizedBox(height: 9),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4FE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('🧊', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              r.streakFreezeUsed == 1
                                  ? l10n.lessonCompleteFreezeSingle
                                  : l10n.lessonCompleteFreezeMulti,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E6FA8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Meta de hoy.
                  if (r.dailyGoalXp > 0) ...[
                    const SizedBox(height: 13),
                    DailyGoalBar(
                        earned: r.dailyXpEarned, goal: r.dailyGoalXp, compact: true),
                  ],
                  if (r.skillsUp.isNotEmpty) ...[
                    const SizedBox(height: 13),
                    _SkillsUpCard(
                      skillsUp: r.skillsUp,
                      // Niveles reales (post-lección). Puede estar cargando → la
                      // card degrada a chips simples si aún no hay dato.
                      levels: {
                        for (final sl in (ref.watch(skillsProvider).value ?? const <SkillLevel>[]))
                          sl.skill: sl
                      },
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
                  // "QUÉ HACER AHORA" — siguiente paso GUIADO y jerarquizado
                  // (E1+E4). Antes el CTA solo empujaba a "siguiente lección" y
                  // el repaso quedaba invisible (nadie abría el SRS → 0 uso). Ahora:
                  //  • hay siguiente lección → PRIMARIO seguir aprendiendo, y si
                  //    además hay palabras pendientes en el SRS se ofrece "Repasar
                  //    N" como opción CLARA (teje el repaso en el loop);
                  //  • fin de unidad + repaso pendiente → el repaso pasa a PRIMARIO
                  //    (es el paso óptimo cuando no hay lección nueva);
                  //  • sin nada más → "Continuar" de siempre.
                  // Todo es NAVEGACIÓN a lo que ya existe: no toca motor/economía.
                  ...(() {
                    final next = _nextLesson();
                    // Vencidas + nuevas que el SRS serviría hoy (get_srs_status,
                    // refrescado en initState). Mientras carga → 0 (no ofrece de más).
                    final review = ref.watch(srsStatusProvider).maybeWhen(
                          data: (s) => s.sessionCount,
                          orElse: () => 0,
                        );
                    void backToMap() =>
                        Navigator.of(context).popUntil((route) => route.isFirst);
                    final reviewBtn = PrimaryButton(
                      label: l10n.lessonReviewCta(review),
                      icon: Icons.history_rounded,
                      color: AppColors.coral,
                      depthColor: AppColors.coralDark,
                      expand: true,
                      onPressed: _startingReview ? null : _startReview,
                    );
                    final backBtn = TextButton(
                      onPressed: backToMap,
                      child: Text(l10n.lessonBackToMap,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    );
                    final header = Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(l10n.lessonWhatNext,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: AppColors.textMuted)),
                    );
                    if (next != null) {
                      return [
                        if (review > 0) header,
                        JzGlowPulse(
                          color: AppColors.primary,
                          child: PrimaryButton(
                            label: l10n.lessonNextCta,
                            expand: true,
                            onPressed: () {
                              final nav = Navigator.of(context);
                              nav.popUntil((route) => route.isFirst);
                              nav.push(MaterialPageRoute(
                                builder: (_) => LessonPreviewScreen(lesson: next),
                              ));
                            },
                          ),
                        ),
                        if (review > 0) ...[const SizedBox(height: 10), reviewBtn],
                        const SizedBox(height: 8),
                        backBtn,
                      ];
                    }
                    if (review > 0) {
                      return [
                        header,
                        JzGlowPulse(color: AppColors.coral, child: reviewBtn),
                        const SizedBox(height: 8),
                        backBtn,
                      ];
                    }
                    return [
                      JzGlowPulse(
                        color: AppColors.primary,
                        child: PrimaryButton(
                          label: l10n.commonContinue,
                          expand: true,
                          onPressed: backToMap,
                        ),
                      ),
                    ];
                  })(),
                  // Momento de VALOR: ofrecer instalar la PWA tras completar la
                  // lección. Se auto-oculta si ya está instalada / sin camino /
                  // en cooldown tras un rechazo / ya ofrecida esta sesión.
                  const InstallValueMomentCard(),
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

/// Tarjeta de habilidades que subieron (Leccion.dc Frame B): por cada skill que
/// ganó puntos, fila con icono + nombre + badge "▲" + BARRA DE PROGRESO real
/// (avance dentro del nivel) + CHIP DE NIVEL CEFR real, y un PIE MOTIVACIONAL
/// ("Sigue así para alcanzar B1…") con el siguiente nivel real de la skill más
/// baja. Todo dato real de `user_skill_levels`; si aún no cargó, degrada a un
/// chip simple (no inventa progreso ni nivel).
class _SkillsUpCard extends StatelessWidget {
  const _SkillsUpCard({required this.skillsUp, required this.levels});
  final List<String> skillsUp;
  final Map<String, SkillLevel> levels;

  static IconData _iconFor(String skill) => switch (skill) {
        'listening' => Icons.headphones_rounded,
        'writing' => Icons.edit_rounded,
        'speaking' => Icons.mic_rounded,
        _ => Icons.menu_book_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Skill con dato real de nivel más BAJO → la que más se acerca al certificado
    // al mejorar; su siguiente CEFR alimenta el pie motivacional.
    SkillLevel? lowest;
    for (final s in skillsUp) {
      final sl = levels[s];
      if (sl == null) continue;
      if (lowest == null ||
          CefrTable.rank(sl.cefrLevel) < CefrTable.rank(lowest.cefrLevel) ||
          (CefrTable.rank(sl.cefrLevel) == CefrTable.rank(lowest.cefrLevel) &&
              sl.progressPoints < lowest.progressPoints)) {
        lowest = sl;
      }
    }
    return Container(
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F9EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights_rounded, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  l10n.lessonCompleteSkillsUp,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final s in skillsUp)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: levels[s] == null
                  ? _SkillChip(name: skillName(l10n, s))
                  : _SkillUpRow(name: skillName(l10n, s), level: levels[s]!),
            ),
          if (lowest != null)
            Text(
              l10n.lessonCompleteSkillNext(CefrTable.next(lowest.cefrLevel)),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

/// Fila rica de skill con barra de progreso real + chip CEFR (Leccion.dc).
class _SkillUpRow extends StatelessWidget {
  const _SkillUpRow({required this.name, required this.level});
  final String name;
  final SkillLevel level;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F9EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_SkillsUpCard._iconFor(level.skill), color: AppColors.success, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.lessonCompleteSkillAdvanced,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: level.levelProgress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF0F1F8),
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(level.cefrLevel,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ],
    );
  }
}

/// Chip simple (fallback cuando aún no cargó el nivel real de la skill).
class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F9EF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text('$name ▲',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.successDark)),
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
    final l10n = AppLocalizations.of(context);
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
                child: Text(l10n.tipCardHeader(tip.typeLabel),
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
              // Ejemplo en el idioma META: tócalo para oírlo (Web Speech).
              child: SpeakableText(tip.example!,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.35)),
            ),
          ],
          if (personalized) ...[
            const SizedBox(height: 9),
            Text(l10n.tipCardPersonalized(skillName(l10n, tip.skill)),
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.coral)),
          ],
          // E2 · entrada de primer nivel a la TEORÍA (Referencia): el usuario
          // acaba de leer un concepto → punto natural para explorar la guía
          // completa (que hoy vive enterrada en un tile de Practicar). ≤1 tap.
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.of(context).push(jzRoute(const ReferenceScreen())),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(l10n.tipCardSeeGuide,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),
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
