import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/achievement_models.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/data/models/unit_model.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/checkpoint/checkpoint_intro_screen.dart';
import 'package:jezici/features/level_exam/certificate_screen.dart';
import 'package:jezici/features/premium/premium_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

Widget _app(Widget home, {List<dynamic> overrides = const []}) => ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  testWidgets('Checkpoint intro: chips QUÉ ENTRA con lecciones REALES + loro con burbuja',
      (tester) async {
    const cp = LessonModel(
        id: 'cp1', unitId: 'u1', orderIndex: 5, title: 'Checkpoint', type: LessonType.checkpoint);
    const unit = UnitModel(
      id: 'u1',
      courseId: 'c1',
      cefrLevel: 'A1',
      orderIndex: 1,
      title: 'Unidad 1',
      lessons: [
        LessonModel(id: 'l1', unitId: 'u1', orderIndex: 1, title: 'Saludos', type: LessonType.lesson),
        LessonModel(id: 'l2', unitId: 'u1', orderIndex: 2, title: 'Presentarte', type: LessonType.lesson),
        cp,
      ],
    );
    await tester.pumpWidget(_app(
      const CheckpointIntroScreen(lesson: cp, unitTitle: 'Unidad 1'),
      overrides: [mapUnitsProvider.overrideWith((ref) async => const [unit])],
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    // Chips con los títulos reales de las lecciones (sin el checkpoint).
    expect(find.text('QUÉ ENTRA'), findsOneWidget);
    expect(find.text('Saludos'), findsOneWidget);
    expect(find.text('Presentarte'), findsOneWidget);
    expect(find.text('Checkpoint'), findsNothing);
    // Loro con burbuja (mensaje del coach en globo, no texto suelto).
    expect(find.textContaining('¡Demuestra'), findsOneWidget);
    // Stats = constantes REALES del RPC (300s / 0.80 / 10).
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('Certificado: título course-aware + titular + sello VERIFICADO', (tester) async {
    const cert = Certificate(
      cefrLevel: 'B1',
      folio: 'JZC-B1-XX',
      verificationCode: 'ABCD-1234',
      holderName: 'María Prueba',
      lang: 'en',
    );
    await tester.pumpWidget(_app(const CertificateScreen(cert: cert, celebrate: false)));
    await tester.pump();

    expect(find.textContaining('Certificado de'), findsOneWidget); // course-aware (en→inglés)
    expect(find.text('María Prueba'), findsOneWidget);
    expect(find.text('VERIFICADO'), findsOneWidget);
    expect(find.text('B1'), findsOneWidget);
  });

  testWidgets('Premium: chips por beneficio + CHECK verde (incluido) + copy course-aware',
      (tester) async {
    await tester.pumpWidget(_app(
      const PremiumScreen(),
      overrides: [activeCourseTargetProvider.overrideWith((ref) async => 'pt')],
    ));
    await tester.pump();
    await tester.pump();

    // Semántica del mockup: CHECK verde "incluido" (no candado) en los 5 beneficios.
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(5));
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
    // Copy course-aware: el idioma REAL del curso (pt), no "inglés" fijo.
    expect(find.textContaining('portugués'), findsOneWidget);
    expect(find.text('Vidas infinitas'), findsOneWidget);
  });
}
