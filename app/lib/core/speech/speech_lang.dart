/// Idioma de HABLA del curso ACTIVO (lo que se APRENDE, no la UI). El TTS de tile
/// (Web Speech synthesis, al tocar una ficha) y el reconocedor del ejercicio de
/// speaking lo leen para pronunciar/reconocer en el idioma correcto (en/pt/fr/it),
/// en vez de inglés fijo. Se fija desde el shell al cargar/cambiar el curso activo.
/// Ambiente y estable (como el "locale actual"): los exercises son StatefulWidget sin
/// ref, así que un estático evita cablear el idioma por todo el árbol. Fallback en-US.
class SpeechLang {
  /// BCP-47 para `SpeechSynthesisUtterance.lang` (con guion).
  static String tts = 'en-US';

  /// localeId para el reconocedor de voz (con guion bajo; se normaliza a guion dentro).
  static String stt = 'en_US';

  /// Mapea el código de idioma META del curso (en/pt/fr/it) a los tags de habla.
  static void setFromCourseTarget(String? target) {
    switch (target) {
      case 'pt': // el curso es português do Brasil
        tts = 'pt-BR';
        stt = 'pt_BR';
        break;
      case 'fr':
        tts = 'fr-FR';
        stt = 'fr_FR';
        break;
      case 'it':
        tts = 'it-IT';
        stt = 'it_IT';
        break;
      case 'de':
        tts = 'de-DE';
        stt = 'de_DE';
        break;
      case 'nl':
        tts = 'nl-NL';
        stt = 'nl_NL';
        break;
      case 'ro':
        tts = 'ro-RO';
        stt = 'ro_RO';
        break;
      default:
        tts = 'en-US';
        stt = 'en_US';
    }
  }
}
