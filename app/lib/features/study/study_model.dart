import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plan/estimation.dart' show CefrTable;
import '../../data/models/tip_models.dart';
import '../../data/models/unit_model.dart';
import '../../data/providers.dart';

/// ESTUDIAR · Fase E-1 (ESTUDIAR_ANALISIS.md §3/§5) — el MODELO derivado.
///
/// Un TEMA de Estudiar = una UNIDAD del curso + la teoría que YA existe para
/// ella (`content_tips`, vía `get_reference`). No se inventa contenido ni un
/// temario paralelo: la estructura ES el currículo que ya está en la BD.
class StudyTopic {
  const StudyTopic({
    required this.unit,
    required this.tips,
    required this.unlocked,
    required this.lessonsDone,
    required this.lessonsTotal,
    this.practiceLessonId,
  });

  final UnitModel unit;

  /// Teoría existente de esta unidad (los tips curados). Puede estar VACÍA
  /// (p.ej. C1 aún no tiene tips) → estado honesto "teoría en camino".
  final List<TipModel> tips;

  /// ¿Abierto? DERIVADO del progreso REAL del mapa: el usuario ya ALCANZÓ esta
  /// unidad en Aprender (alguna lección no bloqueada). Sin gating paralelo.
  final bool unlocked;

  final int lessonsDone;
  final int lessonsTotal;

  /// Lección a la que lleva "Practícalo" (la primera abierta de la unidad).
  final String? practiceLessonId;

  bool get hasTheory => tips.isNotEmpty;

  /// Unidad que hay que completar para abrir esta (copy del candado).
  int get requiredUnitOrder => unit.orderIndex > 1 ? unit.orderIndex - 1 : 1;

  double get progress => lessonsTotal == 0 ? 0 : lessonsDone / lessonsTotal;
}

/// Un NIVEL (A1 → A2 → B1 → …) con sus temas, en orden pedagógico.
class StudyLevel {
  const StudyLevel({required this.cefr, required this.topics});
  final String cefr;
  final List<StudyTopic> topics;

  int get unlockedCount => topics.where((t) => t.unlocked).length;
  bool get anyUnlocked => unlockedCount > 0;
  int get theoryCount => topics.fold(0, (a, t) => a + t.tips.length);
}

/// Deriva la estructura de Estudiar del CONTENIDO (unidades + tips) y del
/// PROGRESO REAL del mapa (`user_lesson_progress`). Pura y testeable.
///
/// DESBLOQUEO (dirección elegida, ESTUDIAR_ANALISIS §3 la deja abierta): un tema
/// se abre cuando el usuario **llega** a esa unidad en Aprender — no cuando la
/// termina. Es coherente con "enseñar antes de examinar": la teoría del tema que
/// estás cursando debe estar disponible MIENTRAS lo cursas, no después. Las
/// unidades que aún no alcanzó (futuras) salen con candado.
List<StudyLevel> buildStudyPlan({
  required List<UnitModel> units,
  required Map<String, String> progress,
  required List<TipModel> tips,
}) {
  // Teoría existente, indexada por unidad (content_tips.unit_order casa 1:1 con
  // units.order_index en los 6 cursos — verificado contra la BD).
  final byUnit = <int, List<TipModel>>{};
  for (final t in tips) {
    final u = t.unitOrder;
    if (u == null) continue;
    (byUnit[u] ??= <TipModel>[]).add(t);
  }

  final sorted = [...units]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final topics = <StudyTopic>[];
  for (final u in sorted) {
    var done = 0, total = 0, reached = 0;
    String? open;
    for (final l in u.lessons) {
      total++;
      final s = progress[l.id];
      // Mismos estados que usa el mapa (learn_map_screen._stateFor).
      final isDone = s == 'completed' || s == 'golden';
      final isOpen = s == 'available' || s == 'in_progress';
      if (isDone) done++;
      if (isDone || isOpen) reached++;
      if (open == null && isOpen) open = l.id;
    }
    // Si no hay ninguna "en curso", "Practícalo" cae a la primera de la unidad
    // (ya completada = rejugable). Solo se ofrece si el tema está abierto.
    open ??= u.lessons.isNotEmpty ? u.lessons.first.id : null;
    topics.add(StudyTopic(
      unit: u,
      tips: List.unmodifiable(byUnit[u.orderIndex] ?? const <TipModel>[]),
      unlocked: reached > 0,
      lessonsDone: done,
      lessonsTotal: total,
      practiceLessonId: reached > 0 ? open : null,
    ));
  }

  final byLevel = <String, List<StudyTopic>>{};
  for (final t in topics) {
    (byLevel[t.unit.cefrLevel] ??= <StudyTopic>[]).add(t);
  }
  final keys = byLevel.keys.toList()
    ..sort((a, b) => CefrTable.rank(a).compareTo(CefrTable.rank(b)));
  return [
    for (final k in keys) StudyLevel(cefr: k, topics: List.unmodifiable(byLevel[k]!)),
  ];
}

/// La estructura de Estudiar del curso ACTIVO. Se recompone sola cuando cambia
/// el progreso (el mapa invalida `lessonProgressProvider` al completar).
final studyPlanProvider = Provider<List<StudyLevel>>((ref) {
  final units = ref.watch(mapUnitsProvider).value ?? const <UnitModel>[];
  final progress = ref.watch(lessonProgressProvider).value ?? const <String, String>{};
  final tips = ref.watch(referenceProvider).value?.tips ?? const <TipModel>[];
  return buildStudyPlan(units: units, progress: progress, tips: tips);
});
