import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/speech/text_match.dart';

/// P0-B + robustez de frases largas: la transcripción EN VIVO ya NO debe mostrar
/// texto duplicado en bucle, ni siquiera cuando el patrón repetido es una FRASE
/// LARGA (prefijo creciente que se acumula), como en las capturas reales de
/// tester (Brave/Android, WebKit/iOS).
void main() {
  group('collapseSpeechRepeats — dedup del bucle (WebKit/Brave)', () {
    test('CAPTURA REAL (frase larga · prefijo creciente): queda solo la final', () {
      // Dijo "Hello, my name is Valentina. Nice to meet you" y el reconocedor
      // re-emitió el prefijo creciente completo, acumulándolo.
      const buggy =
          'hello my name is Valentina hello my name is Valentina nice hello my '
          'name is Valentina nice to hello my name is Valentina nice to meet you';
      expect(collapseSpeechRepeats(buggy),
          equals('hello my name is Valentina nice to meet you'));
    });

    test('captura previa (that weekend…): sin bucle de frases repetidas', () {
      const buggy =
          'that that weekend that weekend that weekend Blade that weekend Blade with my friends';
      final out = collapseSpeechRepeats(buggy);
      // El bucle de frases desaparece: ni el bigrama "that weekend" repetido ni
      // "that weekend Blade" duplicado.
      expect(out.contains('that weekend that weekend'), isFalse);
      expect(out.contains('Blade that weekend Blade'), isFalse);
      // El "that that" inicial (doble de UNA palabra) se PRESERVA — no se puede
      // distinguir de un énfasis legítimo; el matching leniente lo cubre igual.
      expect(out, equals('that that weekend Blade with my friends'));
    });

    test('frase de 2 palabras repetida en bucle → una sola copia', () {
      expect(collapseSpeechRepeats('good morning good morning good morning'),
          equals('good morning'));
    });

    test('frase LARGA (5 palabras) repetida 3× → una sola copia', () {
      const s = 'nice to meet you all nice to meet you all nice to meet you all';
      expect(collapseSpeechRepeats(s), equals('nice to meet you all'));
    });

    test('palabra repetida 3+ veces (bucle) → una sola', () {
      expect(collapseSpeechRepeats('the the the house'), equals('the house'));
    });

    test('LEGÍTIMO: repetición de énfasis de UNA palabra (2×) se PRESERVA', () {
      // "very very good" NO se debe colapsar (énfasis real, no artefacto).
      expect(collapseSpeechRepeats('very very good'), equals('very very good'));
      expect(collapseSpeechRepeats('bye bye'), equals('bye bye'));
    });

    test('NO toca un texto limpio (sin repeticiones inmediatas)', () {
      const clean = 'I go to school every day';
      expect(collapseSpeechRepeats(clean), equals(clean));
    });

    test('NO toca repeticiones legítimas separadas por otro texto', () {
      const s = 'the dog and the cat';
      expect(collapseSpeechRepeats(s), equals(s));
    });

    test('respeta cadena vacía / una palabra', () {
      expect(collapseSpeechRepeats(''), equals(''));
      expect(collapseSpeechRepeats('hola'), equals('hola'));
    });

    test('el matching leniente sigue aprobando tras el colapso', () {
      // La lectura correcta (colapsada) sigue por encima del umbral 0.6.
      final heard = collapseSpeechRepeats(
          'last weekend last weekend I played with my friends');
      expect(speechPasses(heard, 'Last weekend I played with my friends'), isTrue);
      // Y el caso de la captura: tras colapsar, aprueba contra la frase esperada.
      final v = collapseSpeechRepeats(
          'hello my name is Valentina hello my name is Valentina nice to meet you');
      expect(speechPasses(v, 'Hello, my name is Valentina. Nice to meet you'), isTrue);
    });
  });
}
