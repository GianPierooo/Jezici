import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/l10n/app_localizations.dart';
import 'package:jezici/l10n/division_names.dart';
import 'package:jezici/l10n/duration_format.dart';
import 'package:jezici/l10n/skill_names.dart';

/// Blinda que la i18n es REAL: cambiar el locale cambia el texto de la UI, los
/// 3 idiomas están completos, y los helpers (duración/habilidad) siguen el locale.
void main() {
  Future<AppLocalizations> l10nFor(WidgetTester t, String code) async {
    late AppLocalizations captured;
    await t.pumpWidget(MaterialApp(
      locale: Locale(code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (ctx) {
        captured = AppLocalizations.of(ctx);
        return const SizedBox();
      }),
    ));
    return captured;
  }

  testWidgets('el locale cambia el texto de la UI (es/en/pt)', (t) async {
    final es = await l10nFor(t, 'es');
    final en = await l10nFor(t, 'en');
    final pt = await l10nFor(t, 'pt');

    // Onboarding / auth (superficie del feedback "idioma raro").
    expect(es.authTitleSignUp, 'Crea tu cuenta');
    expect(en.authTitleSignUp, 'Create your account');
    expect(pt.authTitleSignUp, 'Crie sua conta');

    // Loop de lección.
    expect(es.commonContinue, 'CONTINUAR');
    expect(en.commonContinue, 'CONTINUE');
    expect(es.lessonFeedbackCorrect, isNot(en.lessonFeedbackCorrect));

    // El copy del "idioma de la app" es claro y distinto en cada idioma.
    expect(es.settingsLanguageTitle, isNot(en.settingsLanguageTitle));
    expect(en.settingsLanguageTitle, 'App language');
  });

  testWidgets('placeholders y plurales resuelven por idioma', (t) async {
    final es = await l10nFor(t, 'es');
    final en = await l10nFor(t, 'en');

    // Plural (racha): 1 vs N.
    expect(es.lessonCompleteStreakDays(1).contains('1 día'), isTrue);
    expect(es.lessonCompleteStreakDays(5).contains('5 días'), isTrue);

    // Placeholder simple.
    expect(en.placementResultTitle('B2'), 'Your level: B2');

    // Duración localizada (helper que espeja estimation.humanDuration).
    expect(formatPlanDuration(es, 4), '≈ 4 semanas');
    expect(formatPlanDuration(en, 4), '≈ 4 weeks');
    expect(formatPlanDuration(es, 0), 'menos de 1 semana');

    // Nombres de habilidad localizados.
    expect(skillName(es, 'reading'), 'Lectura');
    expect(skillName(en, 'reading'), 'Reading');
    expect(skillName(en, 'listening'), 'Listening');
  });

  test('los 3 idiomas están soportados', () {
    final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    expect(codes.containsAll({'es', 'en', 'pt'}), isTrue);
  });

  testWidgets('superficies nuevas (mapa/misión/tienda/racha/ligas/perfil) cambian por idioma', (t) async {
    final es = await l10nFor(t, 'es');
    final en = await l10nFor(t, 'en');
    final pt = await l10nFor(t, 'pt');

    // Home/mapa + misión.
    expect(es.mapEmptyState, isNot(en.mapEmptyState));
    expect(en.missionAppBarTitle, 'Mission');
    expect(pt.missionMainTitle, 'As 100 palavras essenciais');

    // Tienda + racha (plural del contador de racha).
    expect(es.shopTitle, 'Tienda');
    expect(en.shopTitle, 'Shop');
    expect(es.streakDaysCount(1), contains('1 día'));
    expect(es.streakDaysCount(5), contains('5 días'));

    // Ligas + leaderboards (plural de jugadores + división localizada).
    expect(es.leagueWarmingUpSubtitle(1), contains('1 jugador'));
    expect(es.leagueWarmingUpSubtitle(3), contains('3 jugadores'));
    expect(divisionLabel(es, 'oro'), 'Oro');
    expect(divisionLabel(en, 'oro'), 'Gold');
    expect(divisionLabel(pt, 'oro'), 'Ouro');
    expect(en.leaderboardWindowWeekly, 'Weekly');

    // Perfil (placeholders + plurales + reutilización de skill/planFocus).
    expect(es.profileExamCardTitle('B1'), 'Examen de nivel B1');
    expect(en.profileExamCardTitle('B1'), 'B1 level exam');
    expect(es.profilePlanAhead(1), contains('1 día'));
    expect(es.profilePlanAhead(3), contains('3 días'));
    expect(es.profileMasteryGateUnlocked('B2', 1), contains('1 habilidad'));
    expect(es.profileMasteryGateUnlocked('B2', 2), contains('2 habilidades'));
    // planFocus se reutiliza en "Para ti" (no se duplicó clave).
    expect(es.planFocusWork, isNot(en.planFocusWork));
  });
}
