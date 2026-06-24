import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/features/lesson/grading/grader.dart';

ContentItemModel _item(
  ContentItemType type, {
  Map<String, dynamic> payload = const {},
  Map<String, dynamic> correct = const {},
}) =>
    ContentItemModel(
      id: 'x',
      type: type,
      skill: 'reading',
      cefrLevel: 'A1',
      payload: payload,
      correctAnswer: correct,
    );

void main() {
  group('gradeItem · tipos jugables', () {
    test('multiple_choice', () {
      final it = _item(ContentItemType.multipleChoice,
          payload: {'options': ['hello', 'goodbye', 'please']},
          correct: {'value': 'hello'});
      expect(gradeItem(it, 'hello').correct, isTrue);
      expect(gradeItem(it, 'goodbye').correct, isFalse);
      expect(gradeItem(it, 'goodbye').correctDisplay, 'hello');
    });

    test('cloze (texto libre, normaliza)', () {
      final it = _item(ContentItemType.cloze,
          correct: {'value': 'Thank', 'accepted': ['thank']});
      expect(gradeItem(it, 'Thank').correct, isTrue);
      expect(gradeItem(it, ' thank ').correct, isTrue); // normaliza
      expect(gradeItem(it, 'please').correct, isFalse);
    });

    test('translation (acepta variantes)', () {
      final it = _item(ContentItemType.translation,
          correct: {'value': 'Goodbye', 'accepted': ['goodbye', 'bye', 'Bye']});
      expect(gradeItem(it, 'goodbye').correct, isTrue);
      expect(gradeItem(it, 'bye').correct, isTrue);
      expect(gradeItem(it, 'hello').correct, isFalse);
    });

    test('word_bank (secuencia)', () {
      final it = _item(ContentItemType.wordBank,
          correct: {'value': 'Good morning', 'sequence': ['Good', 'morning']});
      expect(gradeItem(it, ['Good', 'morning']).correct, isTrue);
      expect(gradeItem(it, ['morning', 'Good']).correct, isFalse);
    });

    test('reorder (secuencia exacta)', () {
      final it = _item(ContentItemType.reorder, correct: {'value': 'My name is Ana'});
      expect(gradeItem(it, ['My', 'name', 'is', 'Ana']).correct, isTrue);
      expect(gradeItem(it, ['name', 'My', 'is', 'Ana']).correct, isFalse);
    });

    test('match (keyeado por índice, todas las parejas)', () {
      final it = _item(ContentItemType.match, correct: {
        'pairs': [
          ['hello', 'hola'],
          ['goodbye', 'adiós'],
        ]
      });
      expect(gradeItem(it, {0: 'hola', 1: 'adiós'}).correct, isTrue);
      expect(gradeItem(it, {0: 'Hola', 1: 'ADIÓS'}).correct, isTrue); // normaliza
      expect(gradeItem(it, {0: 'adiós', 1: 'hola'}).correct, isFalse);
      expect(gradeItem(it, {0: 'hola'}).correct, isFalse); // incompleto
    });
  });

  group('gradeItem · robustez (jsonb mal formado no crashea)', () {
    test('accepted/sequence/pairs escalares no lanzan', () {
      expect(
        () => gradeItem(
            _item(ContentItemType.translation, correct: {'value': 'Goodbye', 'accepted': 'bye'}),
            'bye'),
        returnsNormally,
      );
      expect(
        () => gradeItem(
            _item(ContentItemType.wordBank, correct: {'value': 'Good morning', 'sequence': 'Good morning'}),
            ['Good', 'morning']),
        returnsNormally,
      );
      expect(
        () => gradeItem(_item(ContentItemType.match, correct: {'pairs': 'x'}), {0: 'hola'}),
        returnsNormally,
      );
    });
  });

  group('normalize · apóstrofes y contracciones (bug P0, mig 067)', () {
    test('contracción equivale a forma completa (ambos sentidos)', () {
      expect(normalize("I'm from Peru"), normalize('I am from Peru'));
      expect(normalize("don't"), normalize('do not'));
      expect(normalize("what's your name?"), normalize('what is your name'));
      expect(normalize("it's mine"), normalize('it is mine'));
      expect(normalize("can't"), normalize('cannot'));
    });
    test('apóstrofe tipográfico, doble y espacios se normalizan', () {
      expect(normalize('I’m from Peru'), normalize("I'm from Peru")); // curly
      expect(normalize("I''m from Peru"), normalize("I'm from Peru")); // doble (data corrupta)
      expect(normalize('  I AM   from  peru. '), normalize('i am from peru'));
    });
    test('NO acepta respuestas genuinamente distintas', () {
      expect(normalize("I'm from Peru") == normalize('I am from Brazil'), isFalse);
      expect(normalize("we're") == normalize('were'), isFalse); // we're ≠ were
    });
  });

  group('gradeItem · contracciones (translation y MC)', () {
    test('translation acepta contracción y forma completa; rechaza lo erróneo', () {
      final it = _item(ContentItemType.translation,
          correct: {'value': "I'm from Peru", 'accepted': ['i am from peru', 'im from peru']});
      expect(gradeItem(it, "I'm from Peru").correct, isTrue);
      expect(gradeItem(it, 'I am from Peru').correct, isTrue);
      expect(gradeItem(it, 'im from peru').correct, isTrue);
      expect(gradeItem(it, 'I am from Brazil').correct, isFalse);
      expect(gradeItem(it, 'x').correctDisplay, "I'm from Peru"); // feedback sin '' doble
    });
    test('multiple_choice equipara "I am fine" con la opción "I\'m fine"', () {
      final it = _item(ContentItemType.multipleChoice,
          payload: {'options': ["I'm fine, thanks", 'Goodbye']},
          correct: {'value': "I'm fine, thanks"});
      expect(gradeItem(it, 'I am fine, thanks').correct, isTrue);
      expect(gradeItem(it, 'Goodbye').correct, isFalse);
    });
  });

  group('tolerancia auditada (mig 070): variantes naturales vía accepted', () {
    test('sinónimos/variantes en accepted se aceptan; lo erróneo no', () {
      // "¿Dónde está mi equipaje?" — luggage/baggage (sinónimo aeropuerto LATAM)
      final it = _item(ContentItemType.translation, correct: {
        'value': 'Where is my luggage?',
        'accepted': ['where is my luggage', "where's my luggage", 'where is my baggage', "where's my baggage"],
      });
      expect(gradeItem(it, 'Where is my baggage?').correct, isTrue);
      expect(gradeItem(it, "Where's my luggage").correct, isTrue);
      expect(gradeItem(it, 'Where is my passport?').correct, isFalse);
    });
    test('have got se equipara con have (normalize) cuando accepted lo trae', () {
      final it = _item(ContentItemType.translation,
          correct: {'value': 'I have a sister', 'accepted': ['i have a sister', 'i have got a sister']});
      // "I've got a sister" → normalize expande I've→i have → coincide con "i have got a sister"
      expect(gradeItem(it, "I've got a sister").correct, isTrue);
      expect(gradeItem(it, 'I have a sister').correct, isTrue);
      expect(gradeItem(it, 'I have a brother').correct, isFalse);
    });
    test('cloze acepta el dígito cuando la pista es numérica', () {
      final it = _item(ContentItemType.cloze, correct: {'value': 'two', 'accepted': ['two', '2']});
      expect(gradeItem(it, '2').correct, isTrue);
      expect(gradeItem(it, 'two').correct, isTrue);
      expect(gradeItem(it, 'three').correct, isFalse);
    });
  });

  group('gradeItem · listening y speaking', () {
    test('listening AHORA se califica (audio real + opción)', () {
      final it = _item(ContentItemType.listening,
          payload: {'options': ['eight', 'six']}, correct: {'value': 'eight'});
      expect(gradeItem(it, 'eight').graded, isTrue);
      expect(gradeItem(it, 'eight').correct, isTrue);
      expect(gradeItem(it, 'six').correct, isFalse);
    });
    test('speaking sigue siendo participación (graded=false)', () {
      expect(gradeItem(_item(ContentItemType.speakingReadAloud), 'x').graded, isFalse);
    });
  });
}
