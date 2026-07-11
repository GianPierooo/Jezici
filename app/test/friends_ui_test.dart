import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/conversar/friends.dart';
import 'package:jezici/features/learn/widgets/parrot_mascot.dart';
import 'package:jezici/l10n/app_localizations.dart';
import 'package:jezici/ui/primary_button.dart';

/// Rediseño social (capa visual): el hub de Amigos usa el lenguaje de la casa
/// (código hero + estados con Jezi + tarjetas con labio), y el chrome es i18n
/// (sin español en pt). La lógica social no se toca aquí.
MaterialApp _app(Widget child, Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  testWidgets('Amigos: código HERO + estado vacío con Jezi y CTA copiar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        socialStatusProvider.overrideWith(
            (ref) async => {'access': true, 'is_adult': true, 'friend_code': 'ABC1234'}),
        friendsProvider.overrideWith(
            (ref) async => {'incoming': <dynamic>[], 'friends': <dynamic>[]}),
      ],
      child: _app(const FriendsScreen(), const Locale('es')),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('ABC1234'), findsOneWidget); // el código, destacado
    expect(find.text('Copiar mi código'), findsOneWidget); // CTA del vacío
    expect(find.byType(ParrotMascot), findsWidgets); // Jezi presente (hero + vacío)
    expect(find.byType(PrimaryButton), findsWidgets); // CTA 3D de la casa
  });

  testWidgets('Amigos: lista con racha 🔥 y subtítulo "toca para chatear"', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
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
        socialStatusProvider.overrideWith(
            (ref) async => {'access': true, 'is_adult': true, 'friend_code': 'ABC1234'}),
        friendsProvider.overrideWith(
            (ref) async => {'incoming': <dynamic>[], 'friends': <dynamic>[]}),
      ],
      child: _app(const FriendsScreen(), const Locale('pt')),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Copiar meu código'), findsOneWidget);
    expect(find.text('Copiar mi código'), findsNothing);
    expect(find.text('Toca para chatear'), findsNothing);
  });
}
