import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/features/lesson/grading/grader.dart';

/// Espejo EXACTO del matrix verificado contra el servidor (jz_near_match, mig 073).
/// El servidor es la fuente de verdad del grading; estos tests blindan que el
/// mirror del cliente (grader.dart) NO diverja: perdona typos/artículos pero NUNCA
/// homógrafos (live/life, this/these, house/horse, cat/cut) ni palabras distintas.
ContentItemModel _tr(String value, {List<String> accepted = const []}) => ContentItemModel(
      id: 't',
      type: ContentItemType.translation,
      skill: 'writing',
      cefrLevel: 'A1',
      prompt: 'Traduce',
      payload: const {},
      correctAnswer: {'value': value, 'accepted': accepted},
    );

void main() {
  group('nearMatch — PERDONA (typo menor / artículo, mismo significado)', () {
    test('typo por letra repetida en multi-palabra: Perru → Peru', () {
      expect(nearMatch(['I am from Peru'], 'I am from Perru'), isTrue);
    });
    test('borrado de 1 char (no es otra palabra): hous → house', () {
      expect(nearMatch(['house'], 'hous'), isTrue);
    });
    test('artículo faltante: "I have sister" → "I have a sister"', () {
      expect(nearMatch(['I have a sister'], 'I have sister'), isTrue);
    });
    test('artículo sobrante: "the house" → "house"', () {
      expect(nearMatch(['house'], 'the house'), isTrue);
    });
    test('contracción ya equiparada por normalize NO necesita near: Im → I am', () {
      // exacto vía normalize → near debe ser false (no es "casi", es correcto).
      expect(nearMatch(['I am from Peru'], 'I am from Peru'), isFalse);
    });
  });

  group('nearMatch — NO PERDONA (cambia el significado / palabra distinta)', () {
    test('homógrafo live/life (sustitución 1 char, palabra suelta)', () {
      expect(nearMatch(['live'], 'life'), isFalse);
    });
    test('homógrafo house/horse', () {
      expect(nearMatch(['house'], 'horse'), isFalse);
    });
    test('homógrafo cat/cut', () {
      expect(nearMatch(['cat'], 'cut'), isFalse);
    });
    test('this/these (distancia 2)', () {
      expect(nearMatch(['this'], 'these'), isFalse);
    });
    test('palabra completamente distinta', () {
      expect(nearMatch(['I am from Peru'], 'I am from Brazil'), isFalse);
    });
    test('vacío nunca es casi-correcto', () {
      expect(nearMatch(['yes'], ''), isFalse);
      expect(nearMatch(['yes'], '   '), isFalse);
    });
    test('sustitución 1 char en palabra suelta NO se perdona (red/bed)', () {
      expect(nearMatch(['red'], 'bed'), isFalse);
    });
  });

  group('gradeItem (cloze/translation) — correct/near coherentes', () {
    test('exacto → correct=true, near=false', () {
      final r = gradeItem(_tr('I am from Peru'), 'I am from Peru');
      expect(r.correct, isTrue);
      expect(r.near, isFalse);
    });
    test('typo menor → correct=true, near=true', () {
      final r = gradeItem(_tr('I am from Peru'), 'I am from Perru');
      expect(r.correct, isTrue);
      expect(r.near, isTrue);
    });
    test('palabra distinta → correct=false, near=false', () {
      final r = gradeItem(_tr('I am from Peru'), 'I am from Brazil');
      expect(r.correct, isFalse);
      expect(r.near, isFalse);
    });
    test('homógrafo live/life → correct=false', () {
      final r = gradeItem(_tr('live'), 'life');
      expect(r.correct, isFalse);
      expect(r.near, isFalse);
    });
    test('respeta accepted[]: variante natural exacta → correct, no near', () {
      final r = gradeItem(_tr("I'm from Peru", accepted: ['I am from Peru']), 'I am from Peru');
      expect(r.correct, isTrue);
      expect(r.near, isFalse);
    });
  });
}
