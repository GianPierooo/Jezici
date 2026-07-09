import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/course_models.dart';
import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/settings/settings_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Ajustes.dc: la pantalla se reestructura en SECCIONES (micro-headers) con
/// icon-tiles, toggles verdes y el loro Matix con burbuja de preview del tono.
/// La lógica no cambia; este test verifica la CAPA visual/estructura.
class _FakeRepo implements ProgressRepository {
  int saves = 0;
  Map<String, dynamic>? lastArgs;

  @override
  Future<void> updateSettings({
    String? coachStyle,
    int? intensity,
    String? quietStart,
    String? quietEnd,
    int? dailyMinutes,
    bool? pushEnabled,
  }) async {
    saves++;
    lastArgs = {
      'coachStyle': coachStyle,
      'intensity': intensity,
      'pushEnabled': pushEnabled,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget wrap(ProgressRepository repo) => ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(repo),
          settingsProvider.overrideWith((ref) async => const UserSettings(
                coachStyle: 'positivo',
                intensity: 2,
                pushEnabled: true,
              )),
          userPlanProvider.overrideWith((ref) async => const UserPlan(
                currentLevel: 'A2',
                goalLevel: 'B2',
                dailyMinutes: 15,
              )),
          coursesProvider.overrideWith((ref) async => [
                CourseInfo(
                    id: 'c-en',
                    source: 'es',
                    target: 'en',
                    targetName: 'Inglés',
                    active: true),
                CourseInfo(
                    id: 'c-pt',
                    source: 'es',
                    target: 'pt',
                    targetName: 'Português',
                    active: false),
              ]),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: SettingsScreen(),
          ),
        ),
      );

  testWidgets('Ajustes: secciones + Aprendes + badge de plan + preview del coach',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 2600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _FakeRepo();
    await tester.pumpWidget(wrap(repo));
    await tester.pump(); // resuelve settingsProvider/userPlan/courses
    await tester.pump();

    // Micro-headers de sección (mayúsculas) del mockup.
    expect(find.text('IDIOMA'), findsOneWidget);
    expect(find.text('NOTIFICACIONES'), findsOneWidget);
    expect(find.text('META Y RECORDATORIOS'), findsOneWidget);

    // Fila "Aprendes" course-aware: curso activo + objetivo real.
    expect(find.text('Aprendes'), findsOneWidget);
    expect(find.text('Inglés · Objetivo B2'), findsOneWidget);

    // Recordatorios (nuevos) + badge de plan.
    expect(find.text('Recordatorio diario'), findsOneWidget);
    expect(find.text('Aviso de racha en peligro'), findsOneWidget);
    expect(find.text('Plan gratis · Mejorar'), findsOneWidget);

    // Burbuja de preview del tono seleccionado (coach 'positivo').
    expect(find.text('«¡Vas genial, sigue así! 🎉»'), findsOneWidget);
  });

  testWidgets('Ajustes: cambiar la intensidad guarda en el servidor', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 2600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _FakeRepo();
    await tester.pumpWidget(wrap(repo));
    await tester.pump();
    await tester.pump();

    // Guardado IMPLÍCITO: tocar "Alta" en el segmento de intensidad persiste.
    await tester.tap(find.text('Alta'));
    await tester.pump();
    await tester.pump();
    expect(repo.saves, greaterThan(0));
    expect(repo.lastArgs?['intensity'], 3);
  });
}
