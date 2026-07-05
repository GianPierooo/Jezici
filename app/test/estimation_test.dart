import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/plan/estimation.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1);

  test('estimatePlan: horas y semanas deterministas (A2→B1)', () {
    final e = estimatePlan(
        currentLevel: 'A2', goalLevel: 'B1', dailyMinutes: 20, daysPerWeek: 5, now: fixedNow);
    expect(e.hoursNeeded, 185); // 375 - 190
    expect(e.hoursPerWeek, closeTo(1.6667, 0.001)); // 20*5/60
    expect(e.weeks, 111); // ceil(185/1.6667)
    expect(e.completionDate, fixedNow.add(Duration(days: 111 * 7)));
  });

  test('la palanca acerca la fecha: más min/día → menos semanas', () {
    final slow = estimatePlan(
        currentLevel: 'A2', goalLevel: 'B1', dailyMinutes: 10, daysPerWeek: 5, now: fixedNow);
    final fast = estimatePlan(
        currentLevel: 'A2', goalLevel: 'B1', dailyMinutes: 30, daysPerWeek: 5, now: fixedNow);
    expect(fast.weeks, lessThan(slow.weeks));
    expect(fast.completionDate.isBefore(slow.completionDate), isTrue);
  });

  test('planProgress', () {
    expect(planProgress(currentLevel: 'A1', goalLevel: 'B1'), 0.0);
    expect(planProgress(currentLevel: 'A2', goalLevel: 'B1'), closeTo(0.339, 0.01));
    expect(planProgress(currentLevel: 'B1', goalLevel: 'B1'), 1.0);
  });

  test('cap de meta: la meta efectiva no supera el tope del curso', () {
    // it topa en A2: aunque se pida B2, la meta efectiva se capa a A2.
    final e = estimatePlan(
        currentLevel: 'A1', goalLevel: 'B2', dailyMinutes: 15, daysPerWeek: 5,
        maxLevel: 'A2', now: fixedNow);
    expect(e.goalLevel, 'A2');

    // Placement en el tope (A2) del curso que topa en A2: el "bump" a B1 se capa a A2
    // (no promete un nivel sin contenido).
    final atTop = estimatePlan(
        currentLevel: 'A2', goalLevel: 'A2', dailyMinutes: 15, daysPerWeek: 5,
        maxLevel: 'A2', now: fixedNow);
    expect(atTop.goalLevel, 'A2');

    // Sin maxLevel (en, tope C1) el comportamiento previo se mantiene: bump A2→B1.
    final uncapped = estimatePlan(
        currentLevel: 'A2', goalLevel: 'A2', dailyMinutes: 15, daysPerWeek: 5, now: fixedNow);
    expect(uncapped.goalLevel, 'B1');
  });
}
