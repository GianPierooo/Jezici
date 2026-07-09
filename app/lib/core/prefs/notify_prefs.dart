import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../feedback/feedback_fx.dart';

/// Preferencias locales de recordatorios y vibración (Ajustes.dc → sección
/// "META Y RECORDATORIOS" y "OTROS").
///
/// Por qué locales: `user_settings` solo tiene un maestro `push_enabled` (sin
/// columnas por-tipo). Estas dos preferencias granulares (recordatorio diario /
/// aviso de racha) se PERSISTEN en el dispositivo → no son toggles muertos: el
/// estado se recuerda entre sesiones y queda listo para el planificador de
/// notificaciones (Fase 2). Además, la pantalla de Ajustes deriva el maestro
/// real `push_enabled = dailyReminder || streakAlert` al guardar en el servidor,
/// de modo que si el usuario apaga ambos, Matix deja de empujar (preferencia
/// real respetada HOY).
class _BoolPref extends Notifier<bool> {
  _BoolPref(this._key, this._default);
  final String _key;
  final bool _default;

  @override
  bool build() {
    _load();
    return _default;
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getBool(_key);
      if (v != null) state = v;
    } catch (_) {}
  }

  Future<void> set(bool on) async {
    state = on;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_key, on);
    } catch (_) {}
  }
}

/// Recordatorio diario de práctica (default ON).
final dailyReminderProvider =
    NotifierProvider<_BoolPref, bool>(() => _BoolPref('notify_daily_reminder', true));

/// Aviso cuando la racha está en peligro (default ON).
final streakAlertProvider =
    NotifierProvider<_BoolPref, bool>(() => _BoolPref('notify_streak_alert', true));

/// Vibración/háptico (default ON). Sincroniza FeedbackFx.hapticsEnabled → cuando
/// está apagada, ninguna microinteracción de la app vibra.
class VibrationController extends Notifier<bool> {
  static const _key = 'haptics_enabled';

  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getBool(_key);
      if (v != null) {
        state = v;
        FeedbackFx.hapticsEnabled = v;
      }
    } catch (_) {}
  }

  Future<void> set(bool on) async {
    state = on;
    FeedbackFx.hapticsEnabled = on;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_key, on);
    } catch (_) {}
  }
}

final vibrationEnabledProvider =
    NotifierProvider<VibrationController, bool>(VibrationController.new);
