import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/course_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'course_placement_screen.dart';

/// Lógica ÚNICA de cambio de curso + re-placement (antes privada en Ajustes;
/// ahora la comparten Ajustes y la bandera del top bar del mapa). Ofrece hacer el
/// test de ubicación del idioma meta o empezar desde el principio, activa el curso
/// (`set_active_course` → `jz_active_course` rutea TODO el contenido al curso
/// elegido → aislamiento multicurso intacto) e invalida los providers dependientes
/// para que el mapa/perfil/ligas se recarguen con el curso nuevo.
Future<void> switchCourseFlow(BuildContext context, WidgetRef ref, CourseInfo c) async {
  final l10n = AppLocalizations.of(context);
  final choice = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.coursePlacementOfferTitle),
      content: Text(l10n.coursePlacementOfferBody(c.label)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'scratch'),
          child: Text(l10n.coursePlacementFromScratch),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'test'),
          child: Text(l10n.coursePlacementDoTest),
        ),
      ],
    ),
  );
  if (choice == null || !context.mounted) return;
  try {
    await ref.read(progressRepositoryProvider).setActiveCourse(c.id);
    ref.invalidate(coursesProvider);
    ref.invalidate(lessonProgressProvider);
    ref.invalidate(skillsProvider);
    ref.invalidate(skillMasteryProvider);
    ref.invalidate(homeStatsProvider);
    ref.invalidate(levelExamStatusProvider);
    ref.invalidate(planTrackingProvider);
    ref.invalidate(userPlanProvider);
    ref.invalidate(mapUnitsProvider);

    if (choice == 'test' && context.mounted) {
      final level = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => CoursePlacementScreen(courseId: c.id, courseLabel: c.label),
        ),
      );
      if (!context.mounted) return;
      ref.invalidate(coursesProvider);
      ref.invalidate(mapUnitsProvider);
      if (level != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.coursePlacementDone(level))),
        );
        return;
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${c.flag}  ${c.targetName}')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.courseSwitchFailed)),
      );
    }
  }
}

/// Hoja para elegir el idioma que se aprende (curso). Reusa `switchCourseFlow`.
/// El curso activo se marca; tocar otro dispara el cambio + re-placement.
Future<void> showCoursePickerSheet(BuildContext context, WidgetRef ref) async {
  final courses = ref.read(coursesProvider).value;
  if (courses == null || courses.isEmpty) return;
  final chosen = await showModalBottomSheet<CourseInfo>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE1E4F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(l10n.settingsChooseCourse,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 12),
              for (final c in courses)
                InkWell(
                  onTap: c.active ? () => Navigator.pop(ctx) : () => Navigator.pop(ctx, c),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    child: Row(children: [
                      Text(c.flag, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(c.targetName,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: c.active ? AppColors.primary : AppColors.text)),
                      ),
                      Icon(
                        c.active
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: c.active ? AppColors.success : const Color(0xFFC9CDDD),
                        size: 22,
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
  if (chosen == null || !context.mounted) return;
  await switchCourseFlow(context, ref, chosen);
}
