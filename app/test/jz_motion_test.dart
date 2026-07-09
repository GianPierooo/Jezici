import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/ui/jz_glow_pulse.dart';
import 'package:jezici/core/ui/jz_sheen.dart';

/// Motion transversal (gap sistémico): sheen dorado + glow del CTA. Deben pintar
/// el hijo (animado) y, con reduce-motion, calmarse sin ocultarlo.
void main() {
  Widget wrap(Widget child, {required bool reduce}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduce),
          child: Scaffold(body: Center(child: child)),
        ),
      );

  for (final reduce in [false, true]) {
    testWidgets('JzSheen muestra el hijo (reduce=$reduce)', (tester) async {
      await tester.pumpWidget(wrap(
        const JzSheen(child: Text('ORO')),
        reduce: reduce,
      ));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('ORO'), findsOneWidget);
    });

    testWidgets('JzGlowPulse muestra el hijo (reduce=$reduce)', (tester) async {
      await tester.pumpWidget(wrap(
        const JzGlowPulse(child: Text('CONTINUAR')),
        reduce: reduce,
      ));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('CONTINUAR'), findsOneWidget);
    });
  }
}
