import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/speech/speakable_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_glow_pulse.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/tip_models.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../lesson/lesson_preview_screen.dart';
import 'study_model.dart';

/// ESTUDIAR · tema → LA TEORÍA que ya existe (los tips curados de esa unidad),
/// con su ejemplo tocable (TTS del curso), + "Practícalo" que cierra el loop
/// estudiar → practicar.
///
/// HUECOS preparados para las fases siguientes (ESTUDIAR_ANALISIS §5), SIN
/// construirlas ni prometerlas en la UI:
///  · E-2 (teoría rica: explicación de sesión + ejemplos + prueba) → se
///    renderizará en la sección de conceptos, debajo/en lugar de los tips.
///  · E-3 (video de profesor, opcional por tema/idioma) → un slot antes de los
///    conceptos; hoy NO existe ningún video, así que no se pinta nada (no se
///    promete lo que no hay).
/// La navegación nivel → tema → teoría NO habrá que rehacerla para encajarlas.
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
                    // Cabecera del tema: nivel + título + avance real de la unidad.
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: AppColors.navActiveBg,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(topic.unit.cefrLevel,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            l10n.studyUnitProgress(topic.lessonsDone, topic.lessonsTotal),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted)),
                      ),
                    ]),
                    const SizedBox(height: 14),

                    // ── HUECO E-3 (video del profesor) ──────────────────────
                    // Cuando exista video para este tema/idioma se renderiza
                    // aquí. Hoy no hay ninguno → no se pinta nada.

                    if (topic.hasTheory) ...[
                      Text(l10n.studyConceptsHeader.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: AppColors.textMuted)),
                      const SizedBox(height: 10),
                      for (final tip in topic.tips) ...[
                        _ConceptCard(tip: tip),
                        const SizedBox(height: 12),
                      ],
                      // ── HUECO E-2 (teoría rica + prueba del tema) ─────────
                      // La "sesión de estudio" completa se añadirá aquí, sin
                      // tocar la navegación ni el desbloqueo.
                    ] else
                      _NoTheoryYet(),

                    const SizedBox(height: 10),
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
}

/// Un concepto = un tip curado que YA existe (title + body + ejemplo tocable).
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
              // Ejemplo en el idioma META: tócalo para oírlo (TTS del curso).
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

/// Estado HONESTO cuando el tema aún no tiene teoría escrita (p.ej. C1: 24 de
/// las 30 unidades tienen tips hoy). No es un vacío roto: dice la verdad y
/// ofrece lo que sí hay.
class _NoTheoryYet extends StatelessWidget {
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
