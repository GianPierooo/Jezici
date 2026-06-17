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
