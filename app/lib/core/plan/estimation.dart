// Motor de estimación de tiempo (determinista) — Estructura_App §2.
// Horas-guía ACUMULADAS por nivel CEFR (referenciales, estilo Cambridge): reaching
// C1 ≈ 700–800 h. La fecha debe ser HONESTA ("si cumples el plan, llegas" solo es
// verdad si la fecha es real) → nada de "2 semanas a C1".

class CefrTable {
  CefrTable._();

  static const List<String> order = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  /// Horas acumuladas para alcanzar cada nivel (desde cero).
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

  /// Siguiente nivel por encima (tope C2).
  static String next(String level) => order[(rank(level) + 1).clamp(0, order.length - 1)];
}

/// Unidad de ENTRADA del mapa según el nivel del placement (espejo del puente
/// create_plan, mig 077: A1=U1·A2=U7·B1=U13·B2=U19·C1=U25). Para mostrar al usuario
/// "empezarás en…". (es→en; fallback razonable para C2.)
const Map<String, (int, String)> _entryUnit = {
  'A1': (1, 'Saludos y presentarte'),
  'A2': (7, 'El pasado: lo que hice'),
  'B1': (13, 'Rutinas, hábitos y experiencias'),
  'B2': (19, 'Logros y trayectoria'),
  'C1': (25, 'Precisión y matiz'),
  'C2': (25, 'Precisión y matiz'),
};

(int, String) entryUnitFor(String level) => _entryUnit[level] ?? _entryUnit['A1']!;

/// Resultado de la estimación del plan.
class PlanEstimate {
  const PlanEstimate({
    required this.hoursNeeded,
    required this.hoursPerWeek,
    required this.weeks,
    required this.completionDate,
    required this.goalLevel,
    required this.bumpedGoal,
  });

  final int hoursNeeded;
  final double hoursPerWeek;
  final int weeks;
  final DateTime completionDate;

  /// Meta EFECTIVA usada para la estimación (puede subir si el placement quedó ≥ la
  /// meta elegida → siempre hay un objetivo hacia adelante; evita fechas fantasma).
  final String goalLevel;

  /// true si la meta se subió porque el usuario ya alcanzaba/superaba la elegida.
  final bool bumpedGoal;

  /// Duración legible (no "≈ 789 semanas"): semanas → meses → años.
  String get humanDuration => _humanizeWeeks(weeks);
}

String _humanizeWeeks(int weeks) {
  if (weeks <= 0) return 'menos de 1 semana';
  if (weeks <= 8) return '≈ $weeks semanas';
  if (weeks < 104) {
    final months = (weeks / 4.345).round().clamp(2, 23);
    return '≈ $months meses';
  }
  final years = weeks / 52.14;
  final txt = years < 10 ? years.toStringAsFixed(1).replaceAll('.', ',') : years.round().toString();
  return '≈ $txt años';
}

/// horas_necesarias = horas_acum(meta) − horas_acum(actual)
/// horas_semana = (min_día × días_semana) / 60 ; semanas = horas_nec / horas_semana
/// La meta efectiva nunca queda ≤ el nivel actual (si el placement ya alcanza/supera
/// la meta elegida, apuntamos al siguiente nivel) → fecha siempre real, sin "2 semanas".
PlanEstimate estimatePlan({
  required String currentLevel,
  required String goalLevel,
  required int dailyMinutes,
  required int daysPerWeek,
  DateTime? now,
  String? maxLevel, // tope real del curso: no promete por encima de lo que existe
}) {
  final today = now ?? DateTime.now();
  final bumped = CefrTable.rank(goalLevel) <= CefrTable.rank(currentLevel);
  var effGoal = bumped ? CefrTable.next(currentLevel) : goalLevel;
  // Capa la meta efectiva al tope del curso (p. ej. it topa en A2: no prometer B1).
  if (maxLevel != null && CefrTable.rank(effGoal) > CefrTable.rank(maxLevel)) {
    effGoal = maxLevel;
  }
  final needed =
      (CefrTable.hoursOf(effGoal) - CefrTable.hoursOf(currentLevel)).clamp(1, 999999);
  final perWeek = (dailyMinutes * daysPerWeek) / 60.0;
  final weeks = perWeek > 0 ? (needed / perWeek).ceil() : 0;
  return PlanEstimate(
    hoursNeeded: needed,
    hoursPerWeek: perWeek,
    weeks: weeks,
    completionDate: today.add(Duration(days: weeks * 7)),
    goalLevel: effGoal,
    bumpedGoal: bumped,
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
