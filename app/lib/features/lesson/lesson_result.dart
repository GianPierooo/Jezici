/// Resumen del intento de una lección (solo local, para la pantalla de fin).
/// La PERSISTENCIA real (XP/progreso/nodo en la BD) se hace en el paso E.
class LessonResult {
  const LessonResult({
    required this.xpEarned,
    required this.accuracy,
    required this.comboBonusXp,
    required this.maxCombo,
    required this.correct,
    required this.graded,
    required this.gold,
    required this.streakDays,
    required this.lessonTitle,
  });

  final int xpEarned;
  final double accuracy; // 0..1 sobre ítems calificados
  final int comboBonusXp;
  final int maxCombo;
  final int correct;
  final int graded;
  final int gold;
  final int streakDays;
  final String lessonTitle;

  int get accuracyPct => (accuracy * 100).round();
}
