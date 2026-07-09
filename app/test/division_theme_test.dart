import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/leagues/division_theme.dart';

/// F2: el header de Ligas ya no es bronce hardcodeado — cada división tiene su
/// paleta/emblema. Bloquea que 2 divisiones distintas rindan temas distintos.
void main() {
  test('DivisionTheme varía por división (no bronce fijo)', () {
    final bronce = DivisionTheme.of('bronce');
    final oro = DivisionTheme.of('oro');
    final diamante = DivisionTheme.of('diamante');

    // Colores y emblema distintos entre divisiones.
    expect(oro.start, isNot(equals(bronce.start)));
    expect(diamante.start, isNot(equals(bronce.start)));
    expect(diamante.icon, isNot(equals(bronce.icon)));

    // Las 6 divisiones resuelven a un tema definido.
    for (final d in ['bronce', 'plata', 'oro', 'zafiro', 'rubi', 'diamante']) {
      expect(DivisionTheme.of(d), isNotNull);
    }
    // División desconocida → fallback a bronce (no crash).
    expect(DivisionTheme.of('desconocida').start, equals(bronce.start));
  });
}
