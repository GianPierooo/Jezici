import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/speech/speech_lang.dart';

/// El idioma de HABLA (TTS de tile + reconocedor de speaking) debe seguir al idioma
/// META del curso activo (en/pt/fr/it), no ser inglés fijo. Antes: hardcodeado 'en-US'
/// → en pt/fr/it la voz no correspondía al idioma (feedback real de un usuario).
void main() {
  test('SpeechLang mapea el idioma meta del curso a los tags de habla', () {
    SpeechLang.setFromCourseTarget('fr');
    expect(SpeechLang.tts, 'fr-FR');
    expect(SpeechLang.stt, 'fr_FR');

    SpeechLang.setFromCourseTarget('it');
    expect(SpeechLang.tts, 'it-IT');
    expect(SpeechLang.stt, 'it_IT');

    SpeechLang.setFromCourseTarget('pt'); // el curso es português do Brasil
    expect(SpeechLang.tts, 'pt-BR');
    expect(SpeechLang.stt, 'pt_BR');

    SpeechLang.setFromCourseTarget('en');
    expect(SpeechLang.tts, 'en-US');
    expect(SpeechLang.stt, 'en_US');

    // Desconocido / null → fallback seguro a inglés (nunca rompe).
    SpeechLang.setFromCourseTarget(null);
    expect(SpeechLang.tts, 'en-US');
    expect(SpeechLang.stt, 'en_US');
  });
}
