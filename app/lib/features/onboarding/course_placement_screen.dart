import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/course_models.dart';
import '../../data/providers.dart';
import 'onboarding_data.dart';
import 'placement_result_view.dart';
import 'placement_test.dart';

/// Re-ubicación en un curso concreto (multi-curso). Se lanza desde Ajustes al
/// cambiar de curso: corre el MISMO test de ubicación server-side (placement_next)
/// pero contra el banco de ESE curso (fr/it/de/nl), muestra la pantalla de resultado
/// reutilizada y aplica el nivel → unidad de entrada con el puente `create_plan`
/// (course-scoped al curso activo). Reusa PlacementTest + PlacementResultView + el
/// motor/estimador; NO duplica nada. Devuelve `true` si el usuario quedó re-ubicado.
class CoursePlacementScreen extends ConsumerStatefulWidget {
  const CoursePlacementScreen({
    super.key,
    required this.courseId,
    required this.courseLabel,
  });

  /// Curso META en el que ubicar (ya debe estar activo: create_plan usa el activo).
  final String courseId;

  /// Etiqueta para la UI (p. ej. "Alemán"). Solo cosmético.
  final String courseLabel;

  @override
  ConsumerState<CoursePlacementScreen> createState() => _CoursePlacementScreenState();
}

class _CoursePlacementScreenState extends ConsumerState<CoursePlacementScreen> {
  final OnboardingData _data = OnboardingData();
  bool _ready = false;
  int _phase = 0; // 0 = test · 1 = resultado
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  /// Reusa las preferencias del plan del usuario (coach/meta/ritmo/motivo) para no
  /// perderlas al re-ubicarse; el nivel lo fija el placement.
  Future<void> _loadPrefs() async {
    try {
      final p = await ref.read(progressRepositoryProvider).fetchPlanPrefs();
      _data.goalLevel = (p['goal_level'] as String?) ?? 'B1';
      _data.dailyMinutes = (p['daily_minutes'] as int?) ?? 15;
      _data.daysPerWeek = (p['days_per_week'] as int?) ?? 5;
      _data.motive = (p['motive'] as String?) ?? 'Placer';
      _data.coachStyle = (p['coach_style'] as String?) ?? 'suave';
      _data.intensity = (p['intensity'] as int?) ?? 2;
      // Tope del curso destino: capa la meta reusada (p. ej. venir de en/C1 a it/A2).
      final courses = ref
          .read(coursesProvider)
          .maybeWhen(data: (v) => v, orElse: () => const <CourseInfo>[]);
      for (final c in courses) {
        if (c.id == widget.courseId) _data.targetMaxLevel = c.maxLevel;
      }
      if (CefrTable.rank(_data.goalLevel) > CefrTable.rank(_data.targetMaxLevel)) {
        _data.goalLevel = _data.targetMaxLevel;
      }
    } catch (_) {
      // Defaults de OnboardingData bastan.
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _apply() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(progressRepositoryProvider);
      final est = estimatePlan(
        currentLevel: _data.currentLevel,
        goalLevel: _data.goalLevel,
        dailyMinutes: _data.dailyMinutes,
        daysPerWeek: _data.daysPerWeek,
        maxLevel: _data.targetMaxLevel,
      );
      // Puente course-scoped (usa jz_active_course = curso ya activado): nivel →
      // unidad de entrada + 4 habilidades + plan del curso.
      await repo.createPlan(
        coachStyle: _data.coachStyle,
        intensity: _data.intensity,
        currentLevel: _data.currentLevel,
        goalLevel: _data.goalLevel,
        dailyMinutes: _data.dailyMinutes,
        daysPerWeek: _data.daysPerWeek,
        motive: _data.motive,
        deadline: null,
        estimatedHours: est.hoursNeeded,
        estimatedCompletion: est.completionDate.toIso8601String().split('T').first,
        skillLevels: _data.skillLevels,
      );
      // Recarga lo que depende del curso/plan.
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(skillMasteryProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(levelExamStatusProvider);
      ref.invalidate(planTrackingProvider);
      ref.invalidate(userPlanProvider);
      if (!mounted) return;
      Navigator.of(context).pop(_data.placementLevel);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('No se pudo guardar la ubicación.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _saving) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_phase == 0) {
      return PlacementTest(
        data: _data,
        step: 1,
        total: 2,
        courseId: widget.courseId,
        onBack: () => Navigator.of(context).pop(null),
        onDone: () => setState(() => _phase = 1),
      );
    }
    return PlacementResultView(
      data: _data,
      step: 2,
      total: 2,
      onBack: () => setState(() => _phase = 0),
      onContinue: _apply,
    );
  }
}
