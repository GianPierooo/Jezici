import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/shop/chest_reveal_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Cofre.dc: pantalla dedicada de revelación. La recompensa la da el servidor
/// real (open_daily_chest); la pantalla es la escena visual. Verifica cerrado →
/// tap CTA → abierto con el premio real + "¡Reclamar!".
class _FakeRepo implements ProgressRepository {
  _FakeRepo(this.reward);
  final int reward;
  int calls = 0;
  @override
  Future<Map<String, dynamic>> openDailyChest() async {
    calls++;
    return {'ok': true, 'reward': reward, 'gold': 100 + reward};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget wrap(Widget child, ProgressRepository repo) => ProviderScope(
        overrides: [progressRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: child,
          ),
        ),
      );

  testWidgets('Cofre disponible: cerrado → Abrir → premio real + ¡Reclamar!',
      (tester) async {
    final repo = _FakeRepo(50);
    await tester.pumpWidget(wrap(const ChestRevealScreen(available: true), repo));
    await tester.pump();

    // Estado cerrado.
    expect(find.text('¡Un cofre te espera!'), findsOneWidget);
    expect(find.text('Abrir cofre'), findsOneWidget);

    // Abrir → llama al RPC real → estado abierto con la recompensa.
    await tester.tap(find.text('Abrir cofre'));
    await tester.pump();
    await tester.pump();
    expect(repo.calls, 1);
    expect(find.text('¡+50 de oro!'), findsOneWidget); // premio real del servidor
    expect(find.text('+50'), findsOneWidget);
    expect(find.text('¡Reclamar!'), findsOneWidget);
  });

  testWidgets('Cofre no disponible: estado mañana, sin RPC', (tester) async {
    final repo = _FakeRepo(30);
    await tester.pumpWidget(wrap(const ChestRevealScreen(available: false), repo));
    await tester.pump();
    expect(find.text('Ya abriste tu cofre'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);
    expect(repo.calls, 0);
  });
}
