/// No-op fuera de web (móvil/desktop/VM de tests): sin Web Speech API.
void speakWord(String word, String lang) {}

/// No-op: no hay voces que precargar fuera de web.
void primeVoices() {}

/// Nativo: el SO siempre tiene TTS del idioma → sin aviso de "sin voz".
bool ttsVoicesReady() => true;
bool? ttsHasVoice(String lang) => true;
