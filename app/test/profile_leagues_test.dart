import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/league_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/leagues/division_theme.dart';
import 'package:jezici/features/leagues/leagues_screen.dart';
import 'package:jezici/features/profile/traveler_level.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Perfil.dc + Ligas.dc: nivel de viajero determinista, escalera de divisiones
/// y pantalla de Ligas con división real + countdown + tags, todo localizado.
void main() {
  test('travelerLevel: progresión triangular determinista', () {
    expect(travelerLevel(0), 1);
    expect(travelerLevel(99), 1);
    expect(travelerLevel(100), 2); // T(2)=100
    expect(travelerLevel(299), 2);
    expect(travelerLevel(300), 3); // T(3)=300
    expect(travelerLevel(2800), 8); // T(8)=2800
    expect(travelerLevel(12000), 16); // T(16)=12000
    expect(xpForTravelerLevel(2), 100);
    expect(xpForTravelerLevel(8), 2800);
    // Progreso dentro del nivel: a mitad de L1→L2 (50 XP de 100).
    expect(travelerProgress(50), closeTo(0.5, 0.001));
  });

  test('DivisionTheme.up/down: espejo de jz_div_up/down con topes', () {
    expect(DivisionTheme.up('oro'), 'zafiro');
    expect(DivisionTheme.down('oro'), 'plata');
    expect(DivisionTheme.up('diamante'), 'diamante'); // tope
    expect(DivisionTheme.down('bronce'), 'bronce'); // piso
  });

  testWidgets('Ligas: banner de división real + carrusel + countdown + tags (es)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final lg = LeagueStanding(
      division: 'oro',
      myRank: 2,
      promote: 7,
      demote: 5,
      players: 14,
      minPlayers: 5,
      warmingUp: false,
      weekStart: DateTime.now().toUtc().subtract(const Duration(days: 2)),
      members: [
        for (var i = 1; i <= 14; i++)
          LeagueMember.fromJson({
            'rank': i,
            'name': i == 2 ? 'Tú' : 'Jugador $i',
            'weekly_xp': 1000 - i * 10,
            'is_me': i == 2,
            'is_bot': false,
          }),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [leagueProvider.overrideWith((ref) async => lg)],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Scaffold(body: LeaguesScreen()),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();

    // Banner refleja la división REAL + carrusel de las 6 divisiones.
    expect(find.text('DIVISIÓN ACTUAL'), findsOneWidget);
    expect(find.text('Liga Oro'), findsOneWidget);
    expect(find.text('DIAMANTE'), findsOneWidget); // carrusel
    // Countdown del cierre (weekStart + 7d, quedan ~5 días).
    expect(find.textContaining('Termina en'), findsOneWidget);
    // Separadores con división DESTINO (oro sube a zafiro / baja a plata).
    expect(find.text('SUBEN A ZAFIRO'), findsOneWidget);
    expect(find.text('BAJAN A PLATA'), findsOneWidget);
    // Tags por zona.
    expect(find.text('Sube'), findsWidgets);
    expect(find.text('En riesgo'), findsWidgets);
    expect(find.text('¡Mantente arriba!'), findsOneWidget);
  });
}
