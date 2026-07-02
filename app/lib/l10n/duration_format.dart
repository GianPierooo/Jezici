import 'app_localizations.dart';

/// Versión localizada de la duración legible del plan (semanas → meses → años).
/// Espeja la lógica de `PlanEstimate.humanDuration` (estimation.dart), que se
/// mantiene en español para tests/back-compat, pero aquí sale en el idioma de la
/// UI (es/en/pt). Se usa en el resultado del placement y en "tu plan".
String formatPlanDuration(AppLocalizations l10n, int weeks) {
  if (weeks <= 0) return l10n.planDurationLessThanWeek;
  if (weeks <= 8) return l10n.planDurationWeeks(weeks);
  if (weeks < 104) {
    final months = (weeks / 4.345).round().clamp(2, 23);
    return l10n.planDurationMonths(months);
  }
  final years = weeks / 52.14;
  // Separador decimal por idioma (evita depender de intl NumberFormat + su init).
  final sep = l10n.localeName.startsWith('en') ? '.' : ',';
  final txt = years < 10
      ? years.toStringAsFixed(1).replaceAll('.', sep)
      : years.round().toString();
  return l10n.planDurationYears(txt);
}
