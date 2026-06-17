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
}
