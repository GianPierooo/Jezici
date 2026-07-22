import '../../l10n/app_localizations.dart';

/// Nombre del idioma que se APRENDE, en el idioma de la APP (para copy course-aware:
/// "¿Por qué aprendes alemán?"). Distinto de los endónimos langEn/langPt (que se usan
/// para el selector de idioma de la app, cada uno en su propia lengua).
String learnLangName(AppLocalizations l10n, String code) => switch (code) {
      'en' => l10n.learnLangEn,
      'pt' => l10n.learnLangPt,
      'fr' => l10n.learnLangFr,
      'it' => l10n.learnLangIt,
      'de' => l10n.learnLangDe,
      'nl' => l10n.learnLangNl,
      'ro' => l10n.learnLangRo,
      _ => code,
    };
