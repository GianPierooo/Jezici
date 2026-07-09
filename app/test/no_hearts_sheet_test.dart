import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/lesson/widgets/no_hearts_sheet.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// SinVidas.dc: la hoja muestra el estado HONESTO (no un contador de regeneración
/// que no existe): "vidas gratis en tu próxima lección", la recarga con precio
/// real, "Ver anuncio · Pronto" (Fase 2, no botón muerto) y el enlace a Premium.
void main() {
  testWidgets('SinVidas: copy honesto + opciones (sin timer falso)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late BuildContext ctx;
    await tester.pumpWidget(ProviderScope(
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
    await tester.pump();

    // Estado honesto (vidas gratis en la próxima lección), NO un contador.
    expect(find.text('Vidas gratis en tu próxima lección'), findsOneWidget);
    // Opciones fieles al mockup.
    expect(find.text('Ver un anuncio'), findsOneWidget);
    expect(find.text('Pronto'), findsOneWidget); // ad = Fase 2, estado honesto
    expect(find.text('Recargar todas'), findsOneWidget);
    expect(find.text('Vidas ilimitadas'), findsOneWidget);
    expect(find.text('PREMIUM'), findsOneWidget);
    // El precio real de recarga (50) sigue visible.
    expect(find.text('$kHeartRefillCost'), findsOneWidget);
  });
}
