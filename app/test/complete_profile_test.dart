import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/profile_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/profile/complete_profile_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Red de seguridad del registro: la pantalla "Completa tu perfil" exige nombre
/// + confirmación de mayoría de edad y persiste con set_profile.
class _FakeRepo implements ProgressRepository {
  final List<(String?, bool?)> calls = [];

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
    calls.add((name, isAdult));
    return ProfileInfo(name: name, isAdult: isAdult);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Gate: pide nombre + mayoría de edad y guarda con set_profile', (tester) async {
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
    expect(find.text('Confirmo que soy mayor de edad'), findsOneWidget);

    // Nombre sin checkbox → no guarda.
    await tester.enterText(find.byType(TextField), 'Gian');
    await tester.pump();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pump();
    expect(fake.calls, isEmpty);

    // Checkbox + CONTINUAR → set_profile(name, is_adult=true) + onDone.
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pump();
    await tester.pump();
    expect(fake.calls, contains(('Gian', true)));
    expect(done, isTrue);
  });
}
