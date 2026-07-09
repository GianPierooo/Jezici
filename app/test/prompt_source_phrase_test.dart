import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/features/lesson/lesson_player_screen.dart';

/// F2 (Leccion.dc): el altavoz de la frase origen solo aparece en word_bank/
/// reorder con una frase ENTRECOMILLADA (« », " ", " "). Extrae esa frase para
/// pronunciarla (voz española). Sin comillas o tipo distinto → null (no altavoz).
ContentItemModel _item(ContentItemType type, String? prompt) => ContentItemModel(
      id: 'x', type: type, skill: 'reading', cefrLevel: 'A1', prompt: prompt,
    );

void main() {
  test('word_bank con comillas rectas → extrae la frase origen', () {
    expect(promptSourcePhrase(_item(ContentItemType.wordBank, 'Arma la frase: "Buenos días".')),
        'Buenos días');
  });

  test('word_bank con guillemets → extrae la frase origen', () {
    expect(promptSourcePhrase(_item(ContentItemType.wordBank, 'Arma la frase en inglés: «Muchas gracias».')),
        'Muchas gracias');
  });

  test('reorder con enunciado genérico (sin comillas) → null (sin altavoz)', () {
    expect(promptSourcePhrase(_item(ContentItemType.reorder, 'Ordena las palabras para formar la oración.')),
        isNull);
  });

  test('tipo que no aplica (multiple_choice) → null', () {
    expect(promptSourcePhrase(_item(ContentItemType.multipleChoice, 'Elige: "algo".')), isNull);
  });
}
