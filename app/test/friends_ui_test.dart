import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/conversar/friends.dart';
import 'package:jezici/features/learn/widgets/parrot_mascot.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Hub de Amigos: agregar es SOLO por @usuario/nombre (el "agregar por código"
/// fue retirado de la UI — decisión de Gian). El chrome es i18n (sin español en
/// pt). La lógica social no se toca aquí.
MaterialApp _app(Widget child, Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  testWidgets('Amigos: SIN bloque de código; estado vacío con Jezi', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        suggestionsProvider.overrideWith((ref) async => const <Map<String, dynamic>>[]),
        socialStatusProvider.overrideWith((ref) async =>
            {'access': true, 'is_adult': true, 'handle': 'yo_test', 'friend_code': 'ABC1234'}),
        friendsProvider.overrideWith(
            (ref) async => {'incoming': <dynamic>[], 'friends': <dynamic>[]}),
      ],
      child: _app(const FriendsScreen(), const Locale('es')),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // El código YA NO aparece en la UI (ni el valor ni el CTA de copiar).
    expect(find.text('ABC1234'), findsNothing);
    expect(find.text('Copiar mi código'), findsNothing);
    expect(find.byType(ParrotMascot), findsWidgets); // Jezi presente (vacío)
  });

  testWidgets('Amigos: lista con racha 🔥 y subtítulo "toca para chatear"', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        suggestionsProvider.overrideWith((ref) async => const <Map<String, dynamic>>[]),
        socialStatusProvider.overrideWith(
            (ref) async => {'access': true, 'is_adult': true, 'friend_code': 'ABC1234'}),
        friendsProvider.overrideWith((ref) async => {
              'incoming': <dynamic>[],
              'friends': [
                {
                  'connection_id': 'c1',
                  'user_id': 'u1',
                  'name': 'María',
                  'avatar_color': '#FF6B6B',
                  'streak': 3,
                },
              ],
            }),
      ],
      child: _app(const FriendsScreen(), const Locale('es')),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('María'), findsOneWidget);
    expect(find.text('🔥'), findsOneWidget); // racha compartida pulsante
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Toca para chatear'), findsOneWidget);
  });

  testWidgets('PT: el hub social no deja español (chrome i18n)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        suggestionsProvider.overrideWith((ref) async => const <Map<String, dynamic>>[]),
        socialStatusProvider.overrideWith((ref) async =>
            {'access': true, 'is_adult': true, 'handle': 'eu_test', 'friend_code': 'ABC1234'}),
        friendsProvider.overrideWith(
            (ref) async => {'incoming': <dynamic>[], 'friends': <dynamic>[]}),
      ],
      child: _app(const FriendsScreen(), const Locale('pt')),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Estado vacío en portugués (sin español) — sin referencias a "código".
    expect(find.text('Você ainda não tem amigos. Busque pelo @usuário para adicionar.'),
        findsOneWidget);
    expect(find.text('Toca para chatear'), findsNothing);
  });
}
