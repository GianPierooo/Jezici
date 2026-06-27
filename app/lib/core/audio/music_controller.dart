import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'music_service.dart';

/// Preferencia de MÚSICA ambiente del mapa (persistida). **Default: APAGADA** (opt-in).
/// Mantiene sincronizado MusicService.instance.enabled. Espejo de SoundController.
class MusicController extends Notifier<bool> {
  static const _key = 'music_enabled';

  @override
  bool build() {
    _load();
    return false; // default OFF
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getBool(_key);
      if (v != null) {
        state = v;
        MusicService.instance.setEnabled(v);
      }
    } catch (_) {}
  }

  Future<void> set(bool on) async {
    state = on;
    MusicService.instance.setEnabled(on);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_key, on);
    } catch (_) {}
  }
}

final musicEnabledProvider = NotifierProvider<MusicController, bool>(MusicController.new);
