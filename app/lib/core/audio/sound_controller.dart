import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sound_service.dart';

/// Preferencia de efectos de sonido (persistida). Silenciable en Ajustes.
/// Mantiene sincronizado SoundService.instance.enabled.
class SoundController extends Notifier<bool> {
  static const _key = 'sound_enabled';

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
        SoundService.instance.enabled = v;
      }
    } catch (_) {}
  }

  Future<void> set(bool on) async {
    state = on;
    SoundService.instance.enabled = on;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_key, on);
    } catch (_) {}
  }
}

final soundEnabledProvider = NotifierProvider<SoundController, bool>(SoundController.new);
