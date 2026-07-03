import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/onboarding/onboarding_data.dart';
import 'package:jezici/features/onboarding/placement_test.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Fake del repo que GUIONA las respuestas de placement_next (servidor) para probar
/// el relay del cliente: muestra ítems, envía la opción elegida y aplica el nivel
/// final. El cliente NUNCA califica (eso es del servidor).
class _PlacementFakeRepo implements ProgressRepository {
  _PlacementFakeRepo(this.script);
  final List<Map<String, dynamic>> script;
  int _i = 0;
  final List<List<Map<String, dynamic>>> calls = [];
  final List<String?> courseIds = [];

  @override
  Future<Map<String, dynamic>> placementNext({
    required String startLevel,
    required List<Map<String, dynamic>> history,
    String? courseId,
  }) async {
    courseIds.add(courseId);
    calls.add(history.map((e) => Map<String, dynamic>.from(e)).toList());
    final r = script[_i < script.length ? _i : script.length - 1];
    _i++;
    return r;
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? props}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _item(String id, List<String> options, {String level = 'A2'}) => {
      'done': false,
      'asked': 1,
      'max': 12,
      'item': {
        'id': id,
        'type': 'multiple_choice',
        'skill': 'reading',
        'cefr_level': level,
        'prompt': 'P-$id',
        'payload': {'options': options},
      },
    };

/// Avanza frames sin `pumpAndSettle` (el spinner de carga es una animación infinita
/// que nunca "asienta"); deja resolver el Future de placementNext.
Future<void> _flush(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 30));
}

void main() {
  testWidgets('El placement relaya ítems del servidor y aplica el nivel final', (tester) async {
    final fake = _PlacementFakeRepo([
      _item('i1', ['hola', 'gracias']),
      _item('i2', ['am', 'is']),
      {
        'done': true,
        'asked': 2,
        'level': 'B2',
        'skill_levels': {'reading': 'B2', 'listening': 'B2', 'writing': 'B1', 'speaking': 'B2'},
      },
    ]);
    final data = OnboardingData()..startLevelHint = 2; // hint B1
    var done = false;

    await tester.pumpWidget(ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlacementTest(
          data: data,
          step: 8,
          total: 9,
          startLevel: 2,
          onBack: () {},
          onDone: () => done = true,
        ),
      ),
    ));
    await _flush(tester);

    // Primer ítem visible.
    expect(find.text('P-i1'), findsOneWidget);
    expect(find.text('hola'), findsOneWidget);

    // Responde el 1º → aparece el 2º.
    await tester.tap(find.text('hola'));
    await _flush(tester);
    expect(find.text('P-i2'), findsOneWidget);

    // Responde el 2º → done → onDone + nivel aplicado.
    await tester.tap(find.text('am'));
    await _flush(tester);

    expect(done, isTrue);
    expect(data.placementLevel, 'B2');
    expect(data.skillLevels['writing'], 'B1'); // per-skill respetado
    expect(data.skillLevels['reading'], 'B2');

    // El hint se envía como CEFR y el historial crece con la opción elegida.
    expect(fake.calls.first, isEmpty); // 1ª llamada sin historial
    expect(fake.calls[1].length, 1);
    expect(fake.calls[1].first['item_id'], 'i1');
    expect(fake.calls[1].first['answer'], 'hola');
    expect(fake.calls[2].last['item_id'], 'i2');
    expect(fake.calls[2].last['answer'], 'am');
  });

  testWidgets('Si el servidor responde done en la 1ª llamada, no rompe', (tester) async {
    final fake = _PlacementFakeRepo([
      {'done': true, 'level': 'A1', 'skill_levels': const {}},
    ]);
    final data = OnboardingData();
    var done = false;
    await tester.pumpWidget(ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlacementTest(
          data: data, step: 8, total: 9, startLevel: 0, onBack: () {}, onDone: () => done = true),
      ),
    ));
    await _flush(tester);
    expect(done, isTrue);
    expect(data.placementLevel, 'A1');
  });

  testWidgets('El placement propaga el courseId al motor (re-ubicación no-inglés)', (tester) async {
    const deCourse = '20000000-0000-0000-0000-000000000005';
    final fake = _PlacementFakeRepo([
      {'done': true, 'level': 'A2', 'skill_levels': const {}},
    ]);
    final data = OnboardingData();
    await tester.pumpWidget(ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlacementTest(
          data: data, step: 1, total: 2, courseId: deCourse, onBack: () {}, onDone: () {}),
      ),
    ));
    await _flush(tester);
    // El curso META llega al motor (placement_next(p_course=de)) → ubica en SU banco.
    expect(fake.courseIds.first, deCourse);
    expect(data.placementLevel, 'A2');
  });
}
