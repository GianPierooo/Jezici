import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/config/auth_config.dart';
import 'package:jezici/data/models/profile_models.dart';
import 'package:jezici/features/conversar/friends.dart';
import 'package:jezici/l10n/app_localizations.dart';
import 'package:jezici/ui/primary_button.dart';

/// Reseteo + solo-Google + @handle obligatorio.
void main() {
  test('BETA: el acceso por email está OCULTO (solo Google)', () {
    // Fija el estado de la beta: el registro/login por email queda tras el flag
    // en false. Se reactiva a true en el lanzamiento oficial.
    expect(kAuthEmailEnabled, isFalse);
  });

  test('ProfileInfo parsea handle; ausente/vacío → null (gate de arranque)', () {
    expect(ProfileInfo.fromJson({'handle': 'nova'}).handle, 'nova');
    expect(ProfileInfo.fromJson({'handle': ''}).handle, isNull);
    expect(ProfileInfo.fromJson({'name': 'X'}).handle, isNull);
  });

  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );

  testWidgets('Gate de @handle en arranque: copy universal + no back + valida',
      (tester) async {
    await tester.pumpWidget(wrap(HandleGateScreen(startup: true, onDone: () {})));
    await tester.pump();

    // Subtítulo UNIVERSAL de arranque (identidad), no el de "así te encuentran
    // tus amigos" (contexto social).
    expect(find.textContaining('identidad en Jezici'), findsOneWidget);
    // Sin AppBar con "atrás" (es ineludible): no hay BackButton.
    expect(find.byType(BackButton), findsNothing);

    // El botón de confirmar arranca DESHABILITADO (sin @usuario válido).
    PrimaryButton btn() =>
        tester.widget<PrimaryButton>(find.byType(PrimaryButton));
    expect(btn().onPressed, isNull);

    // Un @usuario válido lo habilita.
    await tester.enterText(find.byType(TextField), 'nova_23');
    await tester.pump();
    expect(btn().onPressed, isNotNull);

    // Uno inválido (2 chars) lo vuelve a deshabilitar.
    await tester.enterText(find.byType(TextField), 'ab');
    await tester.pump();
    expect(btn().onPressed, isNull);
  });
}
