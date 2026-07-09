/// Nivel de VIAJERO (Perfil.dc): gamificación visual derivada del XP TOTAL real.
/// La columna users.player_level existe pero NADA la actualiza (siempre 1) → en
/// vez de mostrar un dato muerto, el nivel se deriva client-side de xp_total con
/// una progresión triangular determinista (honesto: mismo XP ⇒ mismo nivel,
/// cross-device, sin tocar BD ni economía).
///
/// Umbral acumulado del nivel n (n ≥ 1): T(n) = 50·(n−1)·n
///   L1=0 · L2=100 · L3=300 · L4=600 · L5=1000 · L8=2800 · L16=12000 …
library;

import 'dart:math' as math;

/// XP acumulado necesario para ALCANZAR el nivel [n].
int xpForTravelerLevel(int n) => n <= 1 ? 0 : 50 * (n - 1) * n;

/// Nivel de viajero para [xp] total (≥1).
int travelerLevel(int xp) {
  if (xp <= 0) return 1;
  // n máx con 50(n−1)n ≤ xp  ⇔  n ≤ (1+√(1+4xp/50))/2
  final n = ((1 + math.sqrt(1 + xp / 12.5)) / 2).floor();
  return math.max(1, n);
}

/// Avance 0..1 dentro del nivel actual hacia el siguiente.
double travelerProgress(int xp) {
  final n = travelerLevel(xp);
  final lo = xpForTravelerLevel(n);
  final hi = xpForTravelerLevel(n + 1);
  if (hi <= lo) return 0;
  return ((xp - lo) / (hi - lo)).clamp(0.0, 1.0);
}
