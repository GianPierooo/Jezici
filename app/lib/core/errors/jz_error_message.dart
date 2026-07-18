import '../../l10n/app_localizations.dart';
import 'jz_error.dart';

/// Traduce un `JzError` a un mensaje legible para el usuario, por TIPO (no por el
/// texto crudo de Postgres). i18n es/en/pt. Un solo lugar → cambiar la copia aquí.
String jzErrorMessage(JzError e, AppLocalizations l10n) {
  switch (e.kind) {
    case JzErrorKind.network:
      return l10n.errNetwork;
    case JzErrorKind.auth:
      return l10n.errAuth;
    case JzErrorKind.denied:
      return l10n.errDenied;
    case JzErrorKind.rateLimited:
      return l10n.errRateLimited;
    case JzErrorKind.conflict:
      return l10n.errConflict;
    case JzErrorKind.notFound:
      return l10n.errNotFound;
    case JzErrorKind.validation:
      return l10n.errValidation;
    case JzErrorKind.server:
      return l10n.errServer;
    case JzErrorKind.unknown:
      return l10n.errUnknown;
  }
}

/// Mensaje a partir de un error CRUDO (atajo): `JzError.from` + `jzErrorMessage`.
String errorMessageFor(Object? e, AppLocalizations l10n) =>
    jzErrorMessage(JzError.from(e), l10n);
