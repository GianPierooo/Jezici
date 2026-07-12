import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/conversar/friends.dart';
import 'package:jezici/features/learn/widgets/parrot_mascot.dart';
import 'package:jezici/l10n/app_localizations.dart';
import 'package:jezici/ui/primary_button.dart';

/// T3 · social fácil (capa visual): gate de @usuario obligatorio, buscador y
/// perfil público. La SEGURIDAD real (handle único, búsqueda que excluye
/// bloqueados/no-descubribles, perfil sin campos privados) se verifica
/// server-side con cliente real (tools/content/verify_conversar_t3.py).
class _FakeRepo implements ProgressRepository {
  _FakeRepo({this.profile, this.results = const []});
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> results;

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String q) async => results;

  @override
  Future<Map<String, dynamic>> getPublicProfile(String userId) async =>
      profile ?? (throw Exception('not found'));

  @override
  Future<List<Map<String, dynamic>>> suggestFriends() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MaterialApp _app(Widget child) => MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  testWidgets('GATE: sin @usuario, Amigos muestra la pantalla de elegir handle',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWithValue(_FakeRepo()),
        socialStatusProvider.overrideWith((ref) async =>
            {'access': true, 'is_adult': true, 'friend_code': 'ABC1234', 'needs_handle': true}),
        suggestionsProvider.overrideWith((ref) async => const <Map<String, dynamic>>[]),
        friendsProvider
            .overrideWith((ref) async => {'incoming': <dynamic>[], 'friends': <dynamic>[]}),
      ],
      child: _app(const FriendsScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Elige tu @usuario'), findsOneWidget); // el gate
    expect(find.byType(ParrotMascot), findsWidgets); // Jezi
    expect(find.text('ABC1234'), findsNothing); // el código aún no
  });

  testWidgets('BUSCADOR: escribir muestra resultados con @handle + CTA agregar',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = _FakeRepo(results: [
      {
        'user_id': 'u9',
        'handle': 'bob_m',
        'name': 'Bob',
        'avatar_color': '#6C5CE7',
        'relationship': 'none',
      },
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWithValue(repo),
        socialStatusProvider.overrideWith((ref) async => {
              'access': true,
              'is_adult': true,
              'friend_code': 'ABC1234',
              'handle': 'alicew',
              'needs_handle': false,
              'discoverable': true,
            }),
        suggestionsProvider.overrideWith((ref) async => const <Map<String, dynamic>>[]),
        friendsProvider
            .overrideWith((ref) async => {'incoming': <dynamic>[], 'friends': <dynamic>[]}),
      ],
      child: _app(const FriendsScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('@alicew', findRichText: true),
        findsWidgets); // chip de tu handle (RichText)

    await tester.enterText(find.byType(TextField).first, 'bob');
    await tester.pump(const Duration(milliseconds: 400)); // pasa el debounce
    await tester.pump();

    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('@bob_m'), findsOneWidget);
  });

  testWidgets('PERFIL PÚBLICO: solo campos públicos (nombre/@handle/idiomas/logros) + CTA agregar',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = _FakeRepo(profile: {
      'user_id': 'u2',
      'handle': 'bob_m',
      'name': 'Bob',
      'avatar_color': '#6C5CE7',
      'country': 'MX',
      'member_since': '2026',
      'relationship': 'none',
      'streak': 4,
      'levels': [
        {'lang': 'en', 'lang_name': 'English', 'level': 'B1'},
      ],
      'badges': [
        {'code': 'first', 'name': 'Primera lección'},
      ],
      // (el servidor NUNCA incluye email/birth_year; la UI tampoco los pintaría)
    });
    await tester.pumpWidget(ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(repo)],
      child: _app(const PublicProfileScreen(userId: 'u2')),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('@bob_m'), findsOneWidget);
    expect(find.text('English'), findsOneWidget); // idioma
    expect(find.text('B1'), findsOneWidget); // nivel
    expect(find.text('Primera lección'), findsOneWidget); // logro
    expect(find.text('Agregar amigo'), findsOneWidget); // CTA por relación 'none'
    expect(find.byType(PrimaryButton), findsWidgets);
  });
}
