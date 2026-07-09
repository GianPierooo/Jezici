import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/learn/widgets/top_bar_panels.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Barra superior FUNCIONAL: cada stat abre un panel con info REAL + acción.
/// Verifica que los 3 paneles (vidas/oro/meta) rinden el contenido real de HomeStats.
void main() {
  const stats = HomeStats(
    xpTotal: 500,
    gold: 120,
    hearts: 2,
    playerLevel: 3,
    currentStreak: 4,
    longestStreak: 9,
    freezes: 1,
    dailyGoalXp: 30,
    dailyXpEarned: 10,
  );

  Widget harness(void Function(BuildContext) onTap) => ProviderScope(
        overrides: [homeStatsProvider.overrideWith((ref) async => stats)],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                    onPressed: () => onTap(context), child: const Text('open')),
              ),
            ),
          ),
        ),
      );

  testWidgets('❤️ panel de vidas: muestra vidas reales + recarga con precio', (tester) async {
    await tester.pumpWidget(harness(showHeartsPanel));
    await tester.pump(); // resuelve homeStatsProvider
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Vidas'), findsOneWidget);
    // 2/5 llenos → hay corazones llenos y vacíos.
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
    // Botón de recarga con el precio REAL (buy_hearts = 50).
    expect(find.textContaining('50'), findsOneWidget);
  });

  testWidgets('🪙 panel de oro: saldo real + acceso a la tienda', (tester) async {
    await tester.pumpWidget(harness(showGoldPanel));
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Oro'), findsOneWidget);
    expect(find.textContaining('120'), findsOneWidget); // saldo real
    expect(find.text('Abrir tienda'), findsOneWidget); // acción real
  });

  testWidgets('⚡ panel de meta diaria: progreso X/Y real', (tester) async {
    await tester.pumpWidget(harness(showDailyGoalPanel));
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Meta diaria'), findsOneWidget);
    expect(find.text('10/30'), findsOneWidget); // dailyXpEarned/dailyGoalXp reales
    expect(find.text('Seguir aprendiendo'), findsOneWidget);
  });
}
