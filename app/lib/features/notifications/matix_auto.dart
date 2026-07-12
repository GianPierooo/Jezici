import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/providers.dart';
import 'matix_service.dart';

/// T4 · TRIGGERS AUTOMÁTICOS del motor Matix (antes solo se disparaban desde
/// los botones de prueba admin). El cliente detecta la CONDICIÓN y delega en
/// `matix_fire` (server), que elige copy por estilo+idioma y aplica techo
/// 1/evento/día + quiet_hours + push_enabled. Aquí solo hay un throttle local
/// de cortesía (una evaluación por día) para no insertar filas "suppressed"
/// de más en `notifications`.
///
/// Triggers cableados:
///  - `goal_met`      → tras una lección que CUMPLE la meta diaria.
///  - `goal_unmet`    → tarde en el día (≥18 h) con la meta sin cumplir y sin racha.
///  - `streak_risk`   → tarde en el día con meta sin cumplir Y racha activa
///                      (escalado con techo: la escalera vive en el server).
///  - `behind_plan`   → vas ≥3 días detrás del plan (copy ligado al MOTIVO
///                      del onboarding vía {motivo} en el server).
///  - `hearts_out`    → al quedarte sin vidas en una lección (lo dispara la
///                      pantalla SinVidas, no este chequeo).
/// Re-encolados (necesitan señal server): `achievement` (complete_lesson no
/// expone el logro recién desbloqueado), `exam_countdown` (no hay fecha de
/// examen agendada), `winback`/evaluación para usuarios OFFLINE (requiere cron).
class MatixAuto {
  const MatixAuto(this._ref);
  final Ref _ref;

  static const _kDaily = 'matix_auto_day';
  static const _kGoalMet = 'matix_goalmet_day';

  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  /// Chequeo del ARRANQUE (HomeShell): tarde en el día + atraso vs plan.
  /// Una sola evaluación por día (throttle local); el server re-capa igual.
  Future<void> runDailyChecks() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getString(_kDaily) == _today) return;

      final now = DateTime.now();
      var fired = false;

      // Meta sin cumplir, tarde en el día (la mañana no se molesta).
      if (now.hour >= 18) {
        final stats = await _ref.read(progressRepositoryProvider).fetchHomeStats();
        if (stats.dailyXpEarned < stats.dailyGoalXp) {
          final trigger = stats.currentStreak > 0 ? 'streak_risk' : 'goal_unmet';
          await _ref.read(matixServiceProvider).fire(trigger);
          fired = true;
        }
      }

      // Atraso REAL vs plan (≥3 días detrás) → copy ligado al motivo (server).
      if (!fired) {
        final tracking = await _ref.read(progressRepositoryProvider).fetchPlanTracking();
        if (!tracking.onTrack && tracking.aheadBehind <= -3) {
          await _ref.read(matixServiceProvider).fire('behind_plan');
          fired = true;
        }
      }

      // El throttle solo se consume si la evaluación llegó a correr entera.
      await p.setString(_kDaily, _today);
    } catch (_) {
      // Best-effort: sin red o sin sesión no se molesta a nadie.
    }
  }

  /// Tras COMPLETAR una lección: ¿la meta diaria quedó cumplida con esta?
  /// (goal_met es positivo; 1/día por el techo del server + throttle local).
  Future<void> afterLesson({required int goalXp, required int earnedXp}) async {
    if (goalXp <= 0 || earnedXp < goalXp) return;
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getString(_kGoalMet) == _today) return;
      await p.setString(_kGoalMet, _today);
      await _ref.read(matixServiceProvider).fire('goal_met');
    } catch (_) {}
  }

  /// Al quedarte SIN VIDAS (lo llama la pantalla SinVidas).
  Future<void> onHeartsOut() async {
    try {
      await _ref.read(matixServiceProvider).fire('hearts_out');
    } catch (_) {}
  }
}

final matixAutoProvider = Provider<MatixAuto>((ref) => MatixAuto(ref));
