import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/speech/text_match.dart';

/// P0-B: la transcripción EN VIVO ya NO debe mostrar texto duplicado en bucle.
/// Reproduce el caso REAL de la captura del tester (Brave/Android): al decir
/// "Last weekend I played with my friends" el interim se escribió repetido.
void main() {
  group('collapseSpeechRepeats — dedup del bucle de interim (WebKit/Brave)', () {
    test('caso REAL de la captura: colapsa las frases repetidas', () {
      const buggy =
          'that that weekend that weekend that weekend Blade that weekend Blade with my friends';
      final out = collapseSpeechRepeats(buggy);
      // Sin repeticiones inmediatas: "weekend" no aparece 3 veces seguidas ni el
      // bigrama "that weekend" repetido, ni "that weekend Blade" duplicado.
      expect(out.contains('that weekend that weekend'), isFalse);
      expect(out, equals('that weekend Blade with my friends'));
    });

    test('frase de 2 palabras repetida en bucle → una sola copia', () {
      expect(collapseSpeechRepeats('good morning good morning good morning'),
          equals('good morning'));
    });

    test('palabra repetida 3+ veces (bucle) → una sola', () {
      expect(collapseSpeechRepeats('the the the house'), equals('the house'));
    });

    test('NO toca un texto limpio (sin repeticiones inmediatas)', () {
      const clean = 'I go to school every day';
      expect(collapseSpeechRepeats(clean), equals(clean));
    });

    test('NO toca repeticiones legítimas separadas por otro texto', () {
      // "the" aparece dos veces pero NO adyacente → se preserva.
      const s = 'the dog and the cat';
      expect(collapseSpeechRepeats(s), equals(s));
    });

    test('respeta cadena vacía / una palabra', () {
      expect(collapseSpeechRepeats(''), equals(''));
      expect(collapseSpeechRepeats('hola'), equals('hola'));
    });

    test('el matching leniente sigue aprobando tras el colapso', () {
      // La lectura correcta (colapsada) sigue por encima del umbral 0.6.
      final heard = collapseSpeechRepeats('last weekend last weekend I played with my friends');
      expect(speechPasses(heard, 'Last weekend I played with my friends'), isTrue);
    });
  });
}
