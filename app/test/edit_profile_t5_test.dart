import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/profile_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/l10n/app_localizations.dart';
import 'package:jezici/ui/edit_profile_sheet.dart';

/// T5 · editar perfil: género + cumpleaños OBLIGATORIOS (bloquean el guardado
/// si faltan), país por BUSCADOR con bandera, avatar por selector de colores.
/// La validación REAL server-side se prueba en tools/content/verify_t5.py.
class _FakeRepo implements ProgressRepository {
  int calls = 0;
  @override
  Future<ProfileInfo> setProfileRequired({
    required String name,
    required String gender,
    required int birthdayDay,
    required int birthdayMonth,
    String? country,
    String? bio,
    String? avatarColor,
    String? timezone,
  }) async {
    calls++;
    return ProfileInfo(name: name, gender: gender);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(WidgetRef Function(WidgetRef) grab, ProgressRepository repo, ProfileInfo p) =>
    ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(builder: (context, ref, _) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showEditProfileSheet(context, ref, p),
                child: const Text('abrir'),
              ),
            ),
          );
        }),
      ),
    );

void main() {
  testWidgets('género obligatorio: sin género NO guarda (error visible)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = _FakeRepo();
    // Perfil con cumpleaños pero SIN género.
    final p = ProfileInfo(name: 'Ana', birthdayDay: 9, birthdayMonth: 3);
    await tester.pumpWidget(_host((r) => r, repo, p));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    // Tocar Guardar sin género → error, no llama al repo.
    await tester.ensureVisible(find.text('GUARDAR'));
    await tester.tap(find.text('GUARDAR'));
    await tester.pump();
    expect(find.text('Elige tu género para guardar.'), findsOneWidget);
    expect(repo.calls, 0);
  });

  testWidgets('cumpleaños obligatorio: con género pero sin día/mes NO guarda',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = _FakeRepo();
    final p = ProfileInfo(name: 'Ana', gender: 'female'); // sin cumpleaños
    await tester.pumpWidget(_host((r) => r, repo, p));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('GUARDAR'));
    await tester.tap(find.text('GUARDAR'));
    await tester.pump();
    expect(find.text('Elige el día y el mes de tu cumpleaños.'), findsOneWidget);
    expect(repo.calls, 0);
  });

  testWidgets('completo: guarda (llama a setProfileRequired)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = _FakeRepo();
    final p = ProfileInfo(
        name: 'Ana', gender: 'female', birthdayDay: 9, birthdayMonth: 3, country: 'MX');
    await tester.pumpWidget(_host((r) => r, repo, p));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('GUARDAR'));
    await tester.tap(find.text('GUARDAR'));
    await tester.pump();
    await tester.pump();
    expect(repo.calls, 1);
  });
}
