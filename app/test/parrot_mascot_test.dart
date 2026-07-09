import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/learn/widgets/parrot_mascot.dart';

/// Mascota SVG única (gap sistémico #3): el guacamayo escarlata se dibuja como
/// VECTOR (CustomPaint), no como emoji. Smoke: renderiza sin excepción en ambas
/// variantes (estática y animada) y muestra el globo de diálogo cuando hay mensaje.
void main() {
  testWidgets('ParrotArt: dibuja el vector (CustomPaint), sin emoji', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: ParrotArt(size: 80))),
    ));
    await tester.pump();
    expect(find.byType(ParrotArt), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    // Ya no se usa el emoji como carácter de mascota.
    expect(find.text('🦜'), findsNothing);
  });

  testWidgets('ParrotMascot: anima (idle) + globo de diálogo con el mensaje',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: ParrotMascot(size: 90, message: '¡Vamos!'),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(ParrotArt), findsOneWidget);
    expect(find.text('¡Vamos!'), findsOneWidget);
    expect(find.text('🦜'), findsNothing);
  });
}
