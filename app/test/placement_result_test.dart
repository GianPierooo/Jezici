import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/plan/estimation.dart';
import 'package:jezici/features/onboarding/onboarding_data.dart';
import 'package:jezici/features/onboarding/placement_result_view.dart';
import 'package:jezici/l10n/app_localizations.dart';

void main() {
  group('estimación de tiempo REALISTA (no "2 semanas a C1")', () {
    final t0 = DateTime(2026, 1, 1);

    test('A1→C1 a 10min×5: años, no semanas', () {
      final e = estimatePlan(
          currentLevel: 'A1', goalLevel: 'C1', dailyMinutes: 10, daysPerWeek: 5, now: t0);
      expect(e.weeks, greaterThan(300)); // honesto: cientos de semanas
      expect(e.humanDuration.contains('años'), isTrue);
      expect(e.bumpedGoal, isFalse);
    });

    test('placement ≥ meta NO da fecha fantasma: sube la meta al siguiente nivel', () {
      // Usuario ubicado C1 con meta B1 (< actual): antes daba "días/2 semanas".
      final e = estimatePlan(
          currentLevel: 'C1', goalLevel: 'B1', dailyMinutes: 30, daysPerWeek: 5, now: t0);
      expect(e.bumpedGoal, isTrue);
      expect(e.goalLevel, 'C2'); // siguiente nivel
      expect(e.hoursNeeded, greaterThanOrEqualTo(175)); // un nivel completo, no 1h
      expect(e.weeks, greaterThan(20)); // semanas reales, no "2 semanas"
    });

    test('meta == actual también sube (no needed=1)', () {
      final e = estimatePlan(
          currentLevel: 'B1', goalLevel: 'B1', dailyMinutes: 20, daysPerWeek: 5, now: t0);
      expect(e.bumpedGoal, isTrue);
      expect(e.goalLevel, 'B2');
      expect(e.hoursNeeded, greaterThan(100));
    });

    test('caso normal A1→B1 a 60min×7: meses/años, fecha futura', () {
      final e = estimatePlan(
          currentLevel: 'A1', goalLevel: 'B1', dailyMinutes: 60, daysPerWeek: 7, now: t0);
      expect(e.goalLevel, 'B1');
      expect(e.completionDate.isAfter(t0), isTrue);
      expect(e.humanDuration, anyOf(contains('meses'), contains('años')));
    });

    test('entryUnitFor mapea nivel→unidad de entrada', () {
      expect(entryUnitFor('A1').$1, 1);
      expect(entryUnitFor('B1').$1, 13);
      expect(entryUnitFor('B2').$1, 19);
      expect(entryUnitFor('C1').$1, 25);
    });
  });

  testWidgets('PlacementResultView muestra nivel, skills, unidad y fecha', (t) async {
    final data = OnboardingData()
      ..placementLevel = 'B1'
      ..goalLevel = 'B2'
      ..dailyMinutes = 20
      ..daysPerWeek = 5
      ..skillLevels = {
        'reading': 'B1',
        'writing': 'B1',
        'listening': 'B1',
        'speaking': 'B1',
      };
    await t.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PlacementResultView(
        data: data, step: 9, total: 10, onBack: () {}, onContinue: () {}),
    ));
    await t.pump();

    expect(find.text('Tu nivel: B1'), findsOneWidget); // ubicación, no "aprobaste"
    expect(find.text('Lectura'), findsOneWidget);
    expect(find.text('Comprensión auditiva'), findsOneWidget);
    expect(find.text('Expresión oral'), findsOneWidget);
    expect(find.textContaining('Empezarás en la Unidad 13'), findsOneWidget); // entrada B1
    expect(find.text('VER MI PLAN'), findsOneWidget);
  });
}
