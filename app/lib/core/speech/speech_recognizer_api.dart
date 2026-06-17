/// Interfaz de reconocimiento de voz independiente de plataforma (GA8).
/// Web: Web Speech API cruda (manejo correcto de resultados). Móvil:
/// speech_to_text nativo. Permite degradar con gracia si no hay soporte.
library;

typedef SpeechResultCallback = void Function(String transcript, bool isFinal);
typedef SpeechErrorCallback = void Function(String error);

abstract class SpeechRecognizer {
  /// Inicializa y devuelve si el reconocimiento está disponible (soporte +
  /// permiso). Nunca lanza.
  Future<bool> init();

  bool get available;
  bool get listening;

  /// Empieza a escuchar. [onResult] se llama con transcript LIMPIO (sin
  /// duplicados); isFinal=true una sola vez al terminar.
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
