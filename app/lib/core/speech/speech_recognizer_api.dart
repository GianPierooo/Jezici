/// Interfaz de reconocimiento de voz independiente de plataforma (GA8).
/// Web: Web Speech API cruda (manejo correcto de resultados). Móvil:
/// speech_to_text nativo. Permite degradar con gracia si no hay soporte.
library;

typedef SpeechResultCallback = void Function(String transcript, bool isFinal);
typedef SpeechErrorCallback = void Function(String error);

/// Códigos de error ESTANDARIZADOS que reciben los callbacks/estado. La UI los
/// mapea a mensajes honestos (la causa real, no "sube el volumen"):
/// - [unsupported]: el navegador no tiene Web Speech API (Firefox, etc.).
/// - [denied]: permiso de micrófono denegado/bloqueado (o el servicio de voz
///   deshabilitado por el navegador, p.ej. Brave).
/// - [noMic]: no hay micrófono en el dispositivo.
/// - [network]: el servicio de voz no respondió (Chrome reconoce en servidores).
/// - [webview]: navegador IN-APP (Instagram/Facebook/TikTok/WebView) sin voz ni
///   candado para activar el permiso → hay que abrir en Chrome/Safari.
/// Otros códigos crudos ('no-speech', 'aborted', 'start-failed') pasan tal cual.
abstract final class SpeechErrors {
  static const unsupported = 'unsupported';
  static const denied = 'denied';
  static const noMic = 'no-mic';
  static const network = 'network';
  static const webview = 'webview';
}

abstract class SpeechRecognizer {
  /// Inicializa y devuelve si el reconocimiento está disponible (soporte +
  /// permiso no denegado). Nunca lanza. NO abre prompt de permiso.
  Future<bool> init();

  bool get available;

  /// Cuando [available] es false: por qué ([SpeechErrors.unsupported] |
  /// [SpeechErrors.denied] | [SpeechErrors.noMic]). null si está disponible.
  String? get unavailableReason;

  bool get listening;

  /// Empieza a escuchar (llamar desde un GESTO del usuario: el permiso de mic
  /// se resuelve aquí la primera vez). [onResult] se llama con transcript
  /// LIMPIO (sin duplicados); isFinal=true una sola vez al terminar. Ante un
  /// error FATAL (denied/no-mic/network) se llama [onError] con el código y NO
  /// se emite un final vacío engañoso.
  void listen({
    required SpeechResultCallback onResult,
    SpeechErrorCallback? onError,
    void Function()? onDone,
    String localeId = 'en_US',
    Duration listenFor = const Duration(seconds: 8),
  });

  void stop();
  void dispose();
}
