import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/progress_models.dart';
import '../../data/providers.dart';

/// Envoltura de notificaciones LOCALES del sistema (flutter_local_notifications).
/// En móvil dispara una notificación real de la bandeja; en web el plugin no
/// aplica, así que el "centro de notificaciones in-app" es la prueba visible
/// del tono (push remoto FCM/APNs queda para la siguiente iteración).
class LocalNotifier {
  LocalNotifier._();
  static final LocalNotifier instance = LocalNotifier._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb || _ready) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      await _plugin.initialize(const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ));
      _ready = true;
    } catch (_) {
      // Sin canal de plataforma (p. ej. test/headless) → ignorar en silencio.
    }
  }

  Future<void> show(String title, String body) async {
    if (kIsWeb) return; // web: lo muestra el centro in-app + el banner
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'matix', 'Matix',
          channelDescription: 'Recordatorios y motivación de Matix',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );
      await _plugin.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000, title, body, details);
    } catch (_) {
      // Best-effort: si la plataforma no lo soporta, el in-app ya lo cubre.
    }
  }
}

/// El puente cliente del motor: dispara `matix_fire` en el servidor (que elige
/// el copy del estilo del usuario y respeta techo + quiet_hours) y, si el envío
/// procede, lanza la notificación local y refresca el centro in-app.
class MatixService {
  const MatixService(this._ref);
  final Ref _ref;

  Future<MatixResult> fire(String trigger) async {
    final repo = _ref.read(progressRepositoryProvider);
    final res = await repo.matixFire(trigger);
    if (res.sent) {
      await LocalNotifier.instance.show('Matix · Jezici', res.copy);
    }
    _ref.invalidate(notificationsProvider);
    return res;
  }
}

final matixServiceProvider = Provider<MatixService>((ref) => MatixService(ref));

/// Etiqueta humana del trigger (para el centro in-app y los botones de prueba).
String triggerLabel(String trigger) {
  switch (trigger) {
    case 'goal_unmet':
      return 'Meta sin cumplir';
    case 'streak_risk':
      return 'Racha en riesgo';
    case 'behind_plan':
      return 'Vas detrás del plan';
    case 'achievement':
      return 'Logro desbloqueado';
    case 'exam_countdown':
      return 'Cuenta atrás del examen';
    case 'winback':
      return 'Te extrañamos';
    case 'league':
      return 'Liga';
    default:
      return trigger;
  }
}

/// Motivo por el que el motor suprimió un envío (para feedback al usuario).
String suppressReason(String reason) {
  switch (reason) {
    case 'capped':
      return 'Techo del día alcanzado (máx. 1 por evento)';
    case 'quiet_hours':
      return 'Dentro de tu horario de silencio';
    case 'push_off':
      return 'Tienes las notificaciones desactivadas';
    default:
      return 'No se envió';
  }
}
