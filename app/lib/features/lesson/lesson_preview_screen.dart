import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../data/models/content_item_model.dart';
import '../../data/models/lesson_model.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/skill_names.dart';
import '../../ui/primary_button.dart';
import '../study/study_model.dart';
import '../study/study_topic_screen.dart';
import 'lesson_player_screen.dart';

/// Tarjeta de previsualización: al tocar un nodo del mapa se muestra qué se
/// aprende, los ejercicios y el XP, con el botón "Empezar".
class LessonPreviewScreen extends ConsumerWidget {
  const LessonPreviewScreen({super.key, required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(lessonItemsProvider(lesson.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _CircleButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: itemsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(AppLocalizations.of(context).lessonPreviewLoadError('$e'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted)),
                  ),
                ),
                // ENLACE INVERSO mapa→Estudiar (E-1 lo dejó diferido). Solo se
                // ofrece si la unidad de ESTA lección ya es un tema ABIERTO del
                // plan de estudio — así el enlace nunca es un botón muerto ni
                // puede llevar a una pantalla que se quede cargando. No toca el
                // tap del nodo del mapa ni el gating: esta pantalla ya es un
                // destino aparte y el desbloqueo se deriva del MISMO progreso.
                data: (items) => _Preview(
                  lesson: lesson,
                  items: items,
                  studyOpen: ref.watch(studyPlanProvider).any((lv) => lv.topics
                      .any((t) => t.unit.id == lesson.unitId && t.unlocked)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.lesson, required this.items, required this.studyOpen});
  final LessonModel lesson;
  final List<ContentItemModel> items;

  /// ¿La unidad de esta lección es un tema ABIERTO en Estudiar? Si no, el
  /// enlace a la teoría no se pinta (nada de botones muertos).
  final bool studyOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final skills = items.map((e) => e.skill).toSet();
    return ResponsiveCenter(
      maxWidth: 480,
      child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  offset: const Offset(0, 10),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 5), blurRadius: 0),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  lesson.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                if (lesson.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    lesson.description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _MetaChip(
                      icon: Icons.format_list_numbered_rounded,
                      label: l10n.lessonPreviewExerciseCount(items.length),
                    ),
                    _MetaChip(
                      icon: Icons.bolt_rounded,
                      label: '+${lesson.xpReward} XP',
                      color: AppColors.gold,
                      fg: AppColors.goldDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [for (final s in skills) _SkillChip(skill: s)],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.commonStart,
            expand: true,
            onPressed: items.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      jzRoute(LessonPlayerScreen(lesson: lesson, items: items)),
                    ),
          ),
          // ── Enlace inverso: de la lección a la TEORÍA de su tema ──
          if (studyOpen) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                jzRoute(StudyTopicScreen(unitId: lesson.unitId)),
              ),
              icon: const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.primary),
              label: Text(l10n.lessonStudyTheory,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: AppColors.primary)),
            ),
          ],
          const Spacer(),
        ],
      ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.color = AppColors.navActiveBg,
    this.fg = AppColors.primary,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: fg)),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill});
  final String skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        skillName(AppLocalizations.of(context), skill),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          color: AppColors.textMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEDF5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
      ),
    );
  }
}
