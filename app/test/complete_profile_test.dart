import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/profile_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/profile/complete_profile_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Red de seguridad del registro + AGE GATE (Conversar P1): la pantalla exige
/// nombre (si falta) + AÑO de nacimiento (neutral) y persiste con set_profile +
/// submit_age_gate. El año habilita el gate 18+ SOLO social; un menor sigue.
class _FakeRepo implements ProgressRepository {
  final List<String?> names = [];
  final List<int> ageYears = [];

  @override
  Future<ProfileInfo> setProfile(
      {String? name,
      String? country,
      String? bio,
      String? avatarColor,
      int? birthdayDay,
      int? birthdayMonth,
      bool? isAdult,
      String? timezone,
      String? gender}) async {
    names.add(name);
    return ProfileInfo(name: name);
  }

  @override
  Future<Map<String, dynamic>> submitAgeGate(int birthYear) async {
    ageYears.add(birthYear);
    return {'age_tier': 'adult', 'is_adult': true};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Gate neutral: pide nombre + año y guarda (setProfile + submitAgeGate)',
      (tester) async {
    final fake = _FakeRepo();
    var done = false;
    await tester.pumpWidget(ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CompleteProfileScreen(
          profile: ProfileInfo(needsName: true),
          onDone: () => done = true,
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('Completa tu perfil'), findsOneWidget);
    // Ya NO hay checkbox de "mayoría de edad" (es un gate NEUTRAL por año).
    expect(find.byType(Checkbox), findsNothing);

    // Nombre sin año → no guarda.
    await tester.enterText(find.byType(TextField), 'Gian');
    await tester.pump();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pump();
    expect(fake.names, isEmpty);
    expect(fake.ageYears, isEmpty);

    // Elegir un año en el dropdown (sin pumpAndSettle: la mascota bob-ea sin fin).
    // Cerca del tope de la lista para que esté renderizado (el menú es scrollable).
    final year = DateTime.now().year - 2;
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // abre el overlay del menú
    await tester.tap(find.text('$year').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // cierra el menú

    await tester.tap(find.text('CONTINUAR'));
    await tester.pump();
    await tester.pump();
    expect(fake.names, contains('Gian'));
    expect(fake.ageYears, contains(year));
    expect(done, isTrue);
  });
}
