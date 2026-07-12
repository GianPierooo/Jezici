import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/lesson/widgets/no_hearts_sheet.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// SinVidas.dc + T4 (mig 151): las vidas ahora SI se regeneran server-side ->
/// la hoja muestra el countdown REAL de la proxima vida (de get_hearts), la
/// recarga con precio real, "Ver anuncio - Pronto" (Fase 2, no boton muerto)
/// y el enlace a Premium.
class _FakeRepo implements ProgressRepository {
  @override
  Future<Map<String, dynamic>> getHearts() async =>
      {'hearts': 0, 'max': 5, 'seconds_to_next': 900, 'refill_cost': 50};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('SinVidas: countdown REAL de regeneracion + opciones', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late BuildContext ctx;
    await tester.pumpWidget(ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(_FakeRepo())],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(body: Builder(builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          })),
        ),
      ),
    ));
    showNoHeartsSheet(ctx);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Countdown REAL (900 s = 15:00) - la regeneracion existe (mig 151).
    expect(find.textContaining('15:00'), findsOneWidget);
    expect(find.textContaining('30 min'), findsWidgets);
    // Opciones fieles al mockup.
    expect(find.text('Ver un anuncio'), findsOneWidget);
    expect(find.text('Pronto'), findsOneWidget); // ad = Fase 2, estado honesto
    expect(find.text('Recargar todas'), findsOneWidget);
    expect(find.text('Vidas ilimitadas'), findsOneWidget);
    expect(find.text('PREMIUM'), findsOneWidget);
    // El precio real de recarga (50, del server/config) sigue visible.
    expect(find.text('$kHeartRefillCost'), findsOneWidget);
  });
}
