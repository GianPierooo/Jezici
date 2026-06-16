// Test de humo de un componente puro del sistema de diseño (sin Supabase/red).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jezici/features/shared/placeholder_screen.dart';

void main() {
  testWidgets('PlaceholderScreen muestra título y "Próximamente"',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlaceholderScreen(title: 'Ligas', icon: Icons.emoji_events_rounded),
        ),
      ),
    );

    expect(find.text('Ligas'), findsOneWidget);
    expect(find.text('Próximamente'), findsOneWidget);
  });
}
