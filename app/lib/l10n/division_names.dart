import 'app_localizations.dart';

/// Nombre localizado de la división de liga a partir de su clave técnica
/// ('bronce'/'plata'/'oro'/'zafiro'/'rubi'/'diamante'). Devuelve la clave si no
/// coincide. Reemplaza el getter `divisionLabel` (español) del modelo.
String divisionLabel(AppLocalizations l10n, String division) => switch (division) {
      'bronce' => l10n.leagueDivisionBronce,
      'plata' => l10n.leagueDivisionPlata,
      'oro' => l10n.leagueDivisionOro,
      'zafiro' => l10n.leagueDivisionZafiro,
      'rubi' => l10n.leagueDivisionRubi,
      'diamante' => l10n.leagueDivisionDiamante,
      _ => division,
    };
