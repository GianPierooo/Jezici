// Motor de estimación de tiempo (determinista) — Estructura_App §2.
// Horas-guía ACUMULADAS por nivel CEFR (referenciales, estilo Cambridge).

class CefrTable {
  CefrTable._();

  static const List<String> order = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  /// Horas acumuladas para alcanzar cada nivel.
  static const Map<String, int> hours = {
    'A1': 95,
    'A2': 190,
    'B1': 375,
    'B2': 550,
    'C1': 750,
    'C2': 1100,
  };

  static int rank(String level) {
    final i = order.indexOf(level);
    return i < 0 ? 0 : i;
  }

  static int hoursOf(String level) => hours[level] ?? 95;
}

/// Resultado de la estimación del plan.
class PlanEstimate {
  const PlanEstimate({
    required this.hoursNeeded,
    required this.hoursPerWeek,
    required this.weeks,
    required this.completionDate,
  });

  final int hoursNeeded;
  final double hoursPerWeek;
  final int weeks;
  final DateTime completionDate;
}

/// horas_necesarias = horas_acum(meta) − horas_acum(actual)
/// horas_semana = (min_día × días_semana) / 60
/// semanas = horas_necesarias / horas_semana ; fecha = hoy + semanas
PlanEstimate estimatePlan({
  required String currentLevel,
  required String goalLevel,
  required int dailyMinutes,
  required int daysPerWeek,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final needed = (CefrTable.hoursOf(goalLevel) - CefrTable.hoursOf(currentLevel))
      .clamp(1, 999999);
  final perWeek = (dailyMinutes * daysPerWeek) / 60.0;
  final weeks = perWeek > 0 ? (needed / perWeek).ceil() : 0;
  return PlanEstimate(
    hoursNeeded: needed,
    hoursPerWeek: perWeek,
    weeks: weeks,
    completionDate: today.add(Duration(days: weeks * 7)),
  );
}

/// Avance al nivel meta (0..1), basado en la posición de horas actual vs meta
/// partiendo de A1.
double planProgress({required String currentLevel, required String goalLevel}) {
  final base = CefrTable.hoursOf('A1');
  final cur = CefrTable.hoursOf(currentLevel) - base;
  final goal = (CefrTable.hoursOf(goalLevel) - base).clamp(1, 999999);
  return (cur / goal).clamp(0.0, 1.0);
}
