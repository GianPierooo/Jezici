import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idiomas de UI soportados (el idioma OBJETIVO del curso es inglés en Fase 1).
const supportedUiLangs = ['es', 'en', 'pt'];

const uiLangNames = {'es': 'Español', 'en': 'English', 'pt': 'Português'};

/// Controla el idioma de la interfaz y lo PERSISTE (SharedPreferences).
/// El mecanismo y la preferencia quedan listos aquí; la traducción completa de
/// cadenas llega en la i18n (GA4 · Parte B6).
class LocaleController extends Notifier<String> {
  static const _key = 'ui_lang';

  @override
  String build() {
    _load();
    return 'es';
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString(_key);
      if (v != null && supportedUiLangs.contains(v)) state = v;
    } catch (_) {}
  }

  Future<void> set(String lang) async {
    if (!supportedUiLangs.contains(lang)) return;
    state = lang;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, lang);
    } catch (_) {}
  }
}

final localeProvider = NotifierProvider<LocaleController, String>(LocaleController.new);
