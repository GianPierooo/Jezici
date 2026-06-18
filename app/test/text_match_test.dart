import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/speech/text_match.dart';

void main() {
  group('speaking · normalización de números (bug iOS real)', () {
    // El reconocedor devuelve dígitos donde se esperan palabras.
    test('"one two three four five" pasa contra dígitos separados', () {
      expect(speechPasses('1 2 3 4 5', 'one two three four five'), isTrue);
    });
    test('"one two three four five" pasa contra dígitos pegados', () {
      expect(speechPasses('12345', 'one two three four five'), isTrue);
    });
    test('"one two three four five" pasa contra dígitos con comas', () {
      expect(speechPasses('1,2,3,4,5', 'one two three four five'), isTrue);
    });
    test('palabras vs palabras siguen pasando', () {
      expect(speechPasses('one two three four five', 'one two three four five'), isTrue);
    });
    test('decenas compuestas: "twenty one" == "21"', () {
      expect(speechPasses('21', 'twenty one'), isTrue);
      expect(speechPasses('twenty one', '21'), isTrue);
    });
    test('número embebido: "I have three apples" == "i have 3 apples"', () {
      expect(speechPasses('i have 3 apples', 'I have three apples'), isTrue);
    });
    test('"a hundred" == "100"', () {
      expect(speechPasses('100', 'a hundred'), isTrue);
    });
  });

  group('speaking · tolerancia', () {
    test('contracciones: "I dont know" pasa contra "I don\'t know"', () {
      expect(speechPasses('I dont know', "I don't know"), isTrue);
    });
    test('mayúsculas/puntuación no penalizan', () {
      expect(speechPasses('Good Morning!', 'good morning'), isTrue);
    });
    test('falta una palabra menor → aún pasa (indulgente)', () {
      expect(speechPasses('nice to meet you', 'very nice to meet you'), isTrue);
    });
    test('una lectura razonable aprueba', () {
      expect(speechPasses('how much is it', 'How much is it?'), isTrue);
    });
  });

  group('speaking · rechazos correctos', () {
    test('vacío no pasa', () {
      expect(speechPasses('', 'one two three'), isFalse);
    });
    test('texto totalmente distinto no pasa', () {
      expect(speechPasses('apple banana orange', 'one two three four five'), isFalse);
    });
    test('número equivocado no pasa', () {
      expect(speechPasses('6 7 8', 'one two three'), isFalse);
    });
  });
}
