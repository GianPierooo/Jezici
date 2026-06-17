/// Fábrica del reconocedor de voz: Web Speech API cruda en web, speech_to_text
/// en móvil. Import condicional por plataforma.
library;

import 'speech_recognizer_api.dart';
import 'speech_recognizer_io.dart'
    if (dart.library.js_interop) 'speech_recognizer_web.dart';

export 'speech_recognizer_api.dart';
export 'text_match.dart';

SpeechRecognizer createSpeechRecognizer() => createSpeechRecognizerImpl();
