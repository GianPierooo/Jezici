import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/error_reporter.dart';
import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/course_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'course_placement_screen.dart';
import 'onboarding_data.dart';

/// Lógica ÚNICA de cambio de curso + re-placement (antes privada en Ajustes;
/// ahora la comparten Ajustes y la bandera del top bar del mapa).
///
/// INVARIANTE (fix "dashboard vacío"): el curso activo SIEMPRE termina con un
/// plan (`user_plans`). Antes, "empezar desde cero" activaba el curso pero NUNCA
/// llamaba create_plan (bug heredado de Ajustes), y abandonar el test a mitad
/// también dejaba el curso sin plan → Mi Plan decía "Aún no tienes un plan" y el
/// mapa quedaba sin unidad de entrada. Ahora: curso con plan previo → solo se
/// activa (sin diálogo, sin resetear); "desde cero" → create_plan A1 real; test
/// abandonado → se REVIERTE al curso anterior (nada queda a medias).
Future<void> switchCourseFlow(BuildContext context, WidgetRef ref, CourseInfo c) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(progressRepositoryProvider);

  // Curso activo ANTERIOR (para revertir si el cambio queda a medias).
  CourseInfo? prev;
  for (final x in ref.read(coursesProvider).value ?? const <CourseInfo>[]) {
    if (x.active) prev = x;
  }

  // ¿El curso destino YA tiene plan? (el usuario VUELVE a un idioma que ya
  // estudiaba) → activar y listo: sin diálogo y sin tocar su progreso/plan.
  bool hasPlan = false;
  try {
    hasPlan = (await repo.fetchPlan(courseId: c.id)) != null;
  } catch (_) {/* lectura defensiva: si falla, tratamos como sin plan (el catch de abajo revierte) */}
  if (!context.mounted) return;

  String? choice = 'resume';
  if (!hasPlan) {
    choice = await showDialog<String>(
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
  }

  try {
    await repo.setActiveCourse(c.id);
    _invalidateCourseScope(ref);

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
      // Abandonó el examen a mitad → el curso quedó SIN plan: revertir al
      // anterior (mejor "no cambió nada" que un curso activo vacío).
      bool planNow = false;
      try {
        planNow = (await repo.fetchPlan(courseId: c.id)) != null;
      } catch (_) {/* lectura defensiva: sin señal → planNow=false → revertimos */}
      if (!planNow && prev != null && prev.id != c.id) {
        await repo.setActiveCourse(prev.id);
        _invalidateCourseScope(ref);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${prev.flag}  ${prev.targetName}')),
          );
        }
        return;
      }
    } else if (choice == 'scratch') {
      // "Desde el principio": crear el plan A1 REAL (el bug: antes no se creaba
      // nada → Mi Plan/mapa vacíos). Respeta el estilo de coach actual.
      var coach = 'suave';
      try {
        coach = (await repo.fetchSettings()).coachStyle;
      } catch (_) {/* fallback al estilo por defecto si no se pudo leer settings */}
      var goal = 'B1';
      if (CefrTable.rank(goal) > CefrTable.rank(c.maxLevel)) goal = c.maxLevel;
      final est = estimatePlan(
        currentLevel: 'A1',
        goalLevel: goal,
        dailyMinutes: OnboardingData().dailyMinutes,
        daysPerWeek: OnboardingData().daysPerWeek,
        maxLevel: c.maxLevel,
      );
      await repo.createPlan(
        coachStyle: coach,
        intensity: 3,
        currentLevel: 'A1',
        goalLevel: goal,
        dailyMinutes: OnboardingData().dailyMinutes,
        daysPerWeek: OnboardingData().daysPerWeek,
        motive: '',
        deadline: null,
        estimatedHours: est.hoursNeeded,
        estimatedCompletion: est.completionDate.toIso8601String().split('T').first,
        skillLevels: const {
          'reading': 'A1',
          'listening': 'A1',
          'writing': 'A1',
          'speaking': 'A1',
        },
      );
      _invalidateCourseScope(ref);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${c.flag}  ${c.targetName}')),
      );
    }
  } catch (e, st) {
    // El cambio de curso quedó a medias: se avisa al usuario Y se reporta (es un
    // fallo real del flujo de negocio, no ruido esperado).
    reportError(e, stackTrace: st, context: 'switch_course');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.courseSwitchFailed)),
      );
    }
  }
}

void _invalidateCourseScope(WidgetRef ref) {
  ref.invalidate(coursesProvider);
  ref.invalidate(lessonProgressProvider);
  ref.invalidate(skillsProvider);
  ref.invalidate(skillMasteryProvider);
  ref.invalidate(homeStatsProvider);
  ref.invalidate(levelExamStatusProvider);
  ref.invalidate(planTrackingProvider);
  ref.invalidate(userPlanProvider);
  ref.invalidate(mapUnitsProvider);
}

/// Hoja para CAMBIAR entre los idiomas que el usuario YA aprende (T5: solo los
/// `started`, no los 6). El activo se marca; tocar otro dispara el cambio. Al
/// pie, "Añadir idioma" abre el flujo de alta de un idioma nuevo.
Future<void> showCoursePickerSheet(BuildContext context, WidgetRef ref) async {
  final courses = ref.read(coursesProvider).value;
  if (courses == null || courses.isEmpty) return;
  // Solo los idiomas que el usuario ya está aprendiendo. Fallback defensivo: si
  // ninguno viene marcado (dato viejo), muestra el activo.
  final mine = courses.where((c) => c.started || c.active).toList();
  const kAdd = '__add__';
  final chosen = await showModalBottomSheet<Object>(
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
              Text(l10n.settingsMyLanguages,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 12),
              for (final c in mine)
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
              const Divider(height: 20, color: Color(0xFFEDEEF6)),
              InkWell(
                onTap: () => Navigator.pop(ctx, kAdd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.settingsAddLanguage,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
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
  if (chosen == kAdd) {
    await showAddLanguageSheet(context, ref);
    return;
  }
  await switchCourseFlow(context, ref, chosen as CourseInfo);
}

/// Hoja "Añadir idioma de aprendizaje" (T5): lista los idiomas que el usuario
/// AÚN NO estudia (no `started`) → al elegir uno, `switchCourseFlow` lo arranca
/// (placement o "desde cero") y crea su plan, sin tocar los otros cursos.
Future<void> showAddLanguageSheet(BuildContext context, WidgetRef ref) async {
  final courses = ref.read(coursesProvider).value;
  if (courses == null || courses.isEmpty) return;
  final available = courses.where((c) => !c.started && !c.active).toList();
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
              Text(l10n.settingsAddLanguage,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 4),
              Text(l10n.addLanguageSubtitle,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              if (available.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(l10n.addLanguageAllStarted,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                )
              else
                for (final c in available)
                  InkWell(
                    onTap: () => Navigator.pop(ctx, c),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Row(children: [
                        Text(c.flag, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(c.targetName,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text)),
                        ),
                        const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.primary, size: 22),
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
