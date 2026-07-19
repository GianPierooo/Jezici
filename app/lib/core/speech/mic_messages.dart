import '../../l10n/app_localizations.dart';
import 'speech_recognizer_api.dart';

/// Mensaje HONESTO por código de error/razón del micrófono (la causa real:
/// navegador sin soporte / permiso bloqueado / sin mic / red — nunca un
/// "sube el volumen" engañoso). Compartido por lección, placement y Conversar.
String micMessageFor(AppLocalizations l10n, String? code) {
  switch (code) {
    case SpeechErrors.denied:
      return l10n.micDenied;
    case SpeechErrors.noMic:
      return l10n.micNoDevice;
    case SpeechErrors.network:
      return l10n.micNetwork;
    case SpeechErrors.webview:
      return l10n.micWebview; // navegador in-app: ábrelo en Chrome/Safari
    default:
      return l10n.micUnsupported;
  }
}

/// ¿El error apaga el mic para el resto de la sesión? (network es transitorio:
/// se muestra el aviso pero se puede reintentar).
bool micErrorIsFatal(String code) =>
    code == SpeechErrors.unsupported ||
    code == SpeechErrors.denied ||
    code == SpeechErrors.noMic ||
    code == SpeechErrors.webview;
