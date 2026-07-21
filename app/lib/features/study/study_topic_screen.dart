import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/speech/speakable_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_glow_pulse.dart';
import '../../core/ui/jz_transitions.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/tip_models.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../lesson/exercises/audio_play_button.dart';
import '../lesson/lesson_preview_screen.dart';
import 'study_model.dart';
import 'study_quiz_screen.dart';
import 'study_theory_model.dart';

/// ESTUDIAR · tema → LA TEORÍA, con "Practícalo" que cierra el loop
/// estudiar → practicar.
///
/// Tres estados, en cascada honesta:
///  1. E-2 · SESIÓN DE ESTUDIO rica (teoría paso a paso + ejemplos con audio +
///     errores comunes + PRUEBA) si el tema ya la tiene.
///  2. E-1 · los conceptos (tips) curados, si aún no hay sesión rica.
///  3. "Teoría en camino" si el tema no tiene nada todavía.
///
/// HUECO E-3 (video de profesor, opcional por tema/idioma): marcado abajo. Hoy
/// NO existe ningún video, así que no se pinta nada — no se promete lo que no hay.
class StudyTopicScreen extends ConsumerWidget {
  const StudyTopicScreen({super.key, required this.unitId});
  final String unitId;

  StudyTopic? _find(List<StudyLevel> levels) {
    for (final l in levels) {
      for (final t in l.topics) {
        if (t.unit.id == unitId) return t;
      }
    }
    return null;
  }

  void _practice(BuildContext context, StudyTopic topic) {
    final id = topic.practiceLessonId;
    if (id == null) return;
    LessonModel? lesson;
    for (final l in topic.unit.lessons) {
      if (l.id == id) lesson = l;
    }
    if (lesson == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LessonPreviewScreen(lesson: lesson!)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final topic = _find(ref.watch(studyPlanProvider));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(topic?.unit.title ?? l10n.studyTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: topic == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  children: [
                    _TopicHeader(topic: topic),
                    const SizedBox(height: 14),

                    // ── HUECO E-3 (video del profesor) ──────────────────────
                    // Cuando exista video para este tema/idioma se renderiza
                    // aquí, ENCIMA de la teoría. Hoy no hay ninguno.

                    ...ref.watch(studyTheoryProvider(unitId)).maybeWhen(
                          data: (t) => t == null
                              ? _tipsFallback(l10n, topic)
                              : _richSession(context, l10n, t),
                          orElse: () => _tipsFallback(l10n, topic),
                        ),

                    const SizedBox(height: 12),
                    if (topic.practiceLessonId != null)
                      JzGlowPulse(
                        child: PrimaryButton(
                          label: l10n.studyPracticeCta,
                          icon: Icons.fitness_center_rounded,
                          expand: true,
                          onPressed: () => _practice(context, topic),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  /// E-1: los conceptos curados que ya existían; o el estado honesto si no hay.
  List<Widget> _tipsFallback(AppLocalizations l10n, StudyTopic topic) {
    if (!topic.hasTheory) return [const _NoTheoryYet()];
    return [
      _Header(l10n.studyConceptsHeader),
      for (final tip in topic.tips) ...[
        _ConceptCard(tip: tip),
        const SizedBox(height: 12),
      ],
    ];
  }

  /// E-2: la sesión de estudio completa.
  List<Widget> _richSession(BuildContext context, AppLocalizations l10n, StudyTheory t) {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3F1FF), Color(0xFFEDE9FF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD9D2FF), width: 1.5),
        ),
        child: Text(t.summary,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, height: 1.45, color: AppColors.text)),
      ),
      const SizedBox(height: 18),
      for (final s in t.sections) ...[
        _SectionCard(section: s),
        const SizedBox(height: 12),
      ],
      if (t.examples.isNotEmpty) ...[
        const SizedBox(height: 6),
        _Header(l10n.studyExamplesHeader),
        for (final e in t.examples) ...[
          _ExampleRow(example: e),
          const SizedBox(height: 10),
        ],
      ],
      if (t.pitfalls.isNotEmpty) ...[
        const SizedBox(height: 8),
        _Header(l10n.studyPitfallsHeader),
        for (final p in t.pitfalls) ...[
          _PitfallCard(pitfall: p),
          const SizedBox(height: 10),
        ],
      ],
      if (t.hasQuiz) ...[
        const SizedBox(height: 8),
        _QuizCta(
          count: t.quiz.length,
          onTap: () => Navigator.of(context)
              .push(jzRoute(StudyQuizScreen(unitId: unitId, title: t.title))),
        ),
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: AppColors.textMuted)),
      );
}

class _TopicHeader extends StatelessWidget {
  const _TopicHeader({required this.topic});
  final StudyTopic topic;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(10)),
        child: Text(topic.unit.cefrLevel,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(l10n.studyUnitProgress(topic.lessonsDone, topic.lessonsTotal),
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
      ),
    ]);
  }
}

/// Una sección de la teoría: título + explicación + viñetas escaneables.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final StudySection section;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.heading,
              style: const TextStyle(
                  fontSize: 16.5, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 7),
          Text(section.body,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.text)),
          if (section.bullets.isNotEmpty) const SizedBox(height: 10),
          for (final b in section.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 8),
                  child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                ),
                Expanded(
                  child: Text(b,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: AppColors.text)),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

/// Frase modelo: inglés + traducción + AUDIO pregenerado (TTS del curso).
class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.example});
  final StudyExample example;
  @override
  Widget build(BuildContext context) {
    final url = example.audioUrl;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(example.en,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 3),
              Text(example.es,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ],
          ),
        ),
        if (url != null && url.isNotEmpty) ...[
          const SizedBox(width: 8),
          AudioPlayButton(url: url, big: false, surface: 'study'),
        ],
      ]),
    );
  }
}

/// Error común: lo que suele fallar un hispanohablante, y la forma correcta.
class _PitfallCard extends StatelessWidget {
  const _PitfallCard({required this.pitfall});
  final StudyPitfall pitfall;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.report_problem_rounded, size: 16, color: Color(0xFFE8650A)),
            const SizedBox(width: 7),
            Expanded(
              child: Text(pitfall.title,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF8A4B00))),
            ),
          ]),
          const SizedBox(height: 6),
          Text(pitfall.body,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, height: 1.4, color: Color(0xFF6B4415))),
        ],
      ),
    );
  }
}

/// CTA a la prueba del tema.
class _QuizCta extends StatelessWidget {
  const _QuizCta({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A6BF0), AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Row(children: [
          const Icon(Icons.quiz_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.studyQuizTitle,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 2),
                Text(l10n.studyQuizSubtitle(count),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ]),
      ),
    );
  }
}

/// Un concepto (tip) curado — el contenido de E-1, que sigue sirviendo cuando
/// el tema aún no tiene sesión rica.
class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.tip});
  final TipModel tip;

  IconData get _icon => switch (tip.type) {
        'pronunciacion' => Icons.record_voice_over_rounded,
        'nota_cultural' => Icons.public_rounded,
        'error_comun' => Icons.report_problem_rounded,
        'mnemotecnia' => Icons.lightbulb_rounded,
        _ => Icons.school_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(_icon, size: 17, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(tip.typeLabel,
                  style: const TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
            if (tip.seen)
              const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
          ]),
          const SizedBox(height: 9),
          Text(tip.title,
              style: const TextStyle(
                  fontSize: 16.5, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 6),
          Text(tip.body,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, height: 1.45, color: AppColors.text)),
          if ((tip.example ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FB), borderRadius: BorderRadius.circular(12)),
              child: SpeakableText(
                tip.example!,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                    color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Estado HONESTO cuando el tema aún no tiene teoría (p.ej. C1).
class _NoTheoryYet extends StatelessWidget {
  const _NoTheoryYet();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(children: [
        const ParrotMascot(size: 68, mood: MascotMood.encourage),
        const SizedBox(height: 12),
        Text(l10n.studyNoTheoryTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
        const SizedBox(height: 6),
        Text(l10n.studyNoTheoryBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: AppColors.textMuted)),
      ]),
    );
  }
}
