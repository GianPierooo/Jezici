import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/league_models.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Blinda los arreglos de retención/sensación (P1/P2 del QA):
/// zonas de liga solo con movimiento real + claves i18n nuevas.
void main() {
  test('LeagueStanding.movementActive: 0/0 (beta) → false; 7/5 → true', () {
    final beta = LeagueStanding.fromJson(const {
      'division': 'bronce', 'my_rank': 3, 'promote': 0, 'demote': 0,
      'players': 8, 'warming_up': false, 'members': [],
    });
    expect(beta.movementActive, isFalse); // 8 jugadores < 13 → sin zonas engañosas

    final full = LeagueStanding.fromJson(const {
      'division': 'oro', 'my_rank': 3, 'promote': 7, 'demote': 5,
      'players': 20, 'warming_up': false, 'members': [],
    });
    expect(full.movementActive, isTrue);

    final warming = LeagueStanding.fromJson(const {
      'division': 'bronce', 'my_rank': 1, 'promote': 0, 'demote': 0,
      'players': 2, 'warming_up': true, 'members': [],
    });
    expect(warming.movementActive, isFalse);
  });

  Future<AppLocalizations> l10nFor(WidgetTester t, String code) async {
    late AppLocalizations cap;
    await t.pumpWidget(MaterialApp(
      locale: Locale(code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (ctx) {
        cap = AppLocalizations.of(ctx);
        return const SizedBox();
      }),
    ));
    return cap;
  }

  testWidgets('claves nuevas de retención resuelven por idioma', (t) async {
    final es = await l10nFor(t, 'es');
    final en = await l10nFor(t, 'en');
    final pt = await l10nFor(t, 'pt');

    // Meta diaria (número visible en el mapa).
    expect(es.dailyGoalSemantics(12, 30), contains('12'));
    expect(es.dailyGoalXpOf(12, 30), '12/30 XP');

    // Bono de bienvenida de la misión.
    expect(es.missionRewardBanner(25, 25), contains('25'));
    expect(en.missionWelcomeTitle, 'Your journey has begun!');
    expect(pt.missionWelcomeTitle, 'Sua jornada começou!');

    // Feedback de oro (gasto → saldo restante) localizado.
    expect(es.shopFreezeBought(120), contains('120'));
    expect(en.shopHeartsRefilled(80), contains('80'));
    expect(es.shopChestWon(40, 200), allOf(contains('40'), contains('200')));

    // Combo.
    expect(es.comboLabel(5), 'x5');

    // Nota de liga en beta (sin movimiento).
    expect(es.leagueNoMovementNote, isNot(en.leagueNoMovementNote));
  });
}
