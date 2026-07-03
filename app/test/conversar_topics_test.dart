import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/conversar/conversar_screen.dart';

/// Conversar Fase 1 (práctica en solitario) debe servir la respuesta MODELO en el
/// idioma del curso (en/pt/fr/it), no en inglés fijo. Verifica que TODOS los topics
/// cubren los 4 idiomas con 3 frases clave, y que un idioma desconocido cae a inglés.
void main() {
  test('Conversar: cada topic cubre en/pt/fr/it con modelo + 3 tips; fallback a en', () {
    expect(ConversarScreen.topics.length, 6);
    for (final t in ConversarScreen.topics) {
      for (final lang in const ['en', 'pt', 'fr', 'it']) {
        final m = t.modelFor(lang);
        expect(m.model.trim(), isNotEmpty, reason: '${t.title} · $lang: modelo vacío');
        expect(m.tips.length, 3, reason: '${t.title} · $lang: tips != 3');
      }
      // Idioma no cubierto → inglés (nunca rompe).
      expect(t.modelFor('xx').model, t.models['en']!.model);
    }
  });
}
