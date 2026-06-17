import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/speech/text_match.dart';

void main() {
  group('speech matching tolerante (GA8)', () {
    test('una lectura razonable APRUEBA (normaliza puntuación/caso)', () {
      expect(speechPasses('Good morning!', 'Good morning'), isTrue);
      expect(speechPasses('good morning', 'Good morning.'), isTrue);
      expect(speechPasses('hello good morning', 'Hello! Good morning.'), isTrue);
      expect(speechPasses('I am from Peru', "I'm from Peru"), isTrue);
      expect(speechPasses('this is my family my mother and my father',
          'This is my family: my mother and my father.'), isTrue);
    });

    test('texto totalmente distinto NO aprueba', () {
      expect(speechPasses('completely different words here', 'Good morning'), isFalse);
    });

    test('idéntico (tras normalizar) = ratio 1.0', () {
      expect(speechMatchRatio('Good morning', 'good morning!'), closeTo(1.0, 0.001));
    });

    test('una palabra de menos sigue aprobando (lenient)', () {
      expect(speechPasses('would like a coffee please', 'I would like a coffee please'), isTrue);
    });
  });
}
