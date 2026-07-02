import 'app_localizations.dart';

/// Nombre localizado de una habilidad a partir de su clave técnica
/// ('reading'/'writing'/'listening'/'speaking'). Devuelve la clave si no coincide.
String skillName(AppLocalizations l10n, String key) => switch (key) {
      'reading' => l10n.skillReading,
      'writing' => l10n.skillWriting,
      'listening' => l10n.skillListening,
      'speaking' => l10n.skillSpeaking,
      _ => key,
    };
