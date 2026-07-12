import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/lesson/widgets/no_hearts_sheet.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// T4 · UI de vidas con regeneración + revive. La ECONOMÍA real (cobros, tope,
/// ventana, regen del server) se verifica con cliente real (verify_t4.py).
class _FakeRepo implements ProgressRepository {
  _FakeRepo({this.secondsToNext});
  final int? secondsToNext;

  @override
  Future<Map<String, dynamic>> getHearts() async => {
        'hearts': 0,
        'max': 5,
        'seconds_to_next': secondsToNext,
        'refill_cost': 50,
      };

  @override
  Future<Map<String, dynamic>> streakReviveStatus() async => {
        'available': true,
        'lost_streak': 12,
        'cost': 300,
        'days_left': 5,
        'used_this_period': false,
        'gold': 500,
      };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('formatCountdown: MM:SS y horas legibles', () {
    expect(formatCountdown(0), '0:00');
    expect(formatCountdown(59), '0:59');
    expect(formatCountdown(1799), '29:59');
    expect(formatCountdown(3660), '1 h 01 min');
  });

  testWidgets('SinVidas: muestra el countdown REAL de la próxima vida', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(_FakeRepo(secondsToNext: 754))],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showNoHeartsSheet(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 754 s = 12:34 → el contador REAL aparece (y el sub explica la regla).
    expect(find.textContaining('12:34'), findsOneWidget);
    expect(find.textContaining('30 min'), findsWidgets);
  });
}
