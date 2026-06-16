import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/features/lesson/lesson_player_screen.dart';

/// Los 8 ejercicios reales de la Lección 1.1 (mismas formas que el seed).
List<ContentItemModel> _unit1Lesson1Items() => [
      ContentItemModel(
        id: 'e1',
        type: ContentItemType.match,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Empareja cada palabra con su traducción.',
        payload: {
          'pairs': [
            {'en': 'hello', 'es': 'hola'},
            {'en': 'goodbye', 'es': 'adiós'},
            {'en': 'good morning', 'es': 'buenos días'},
          ]
        },
        correctAnswer: {
          'pairs': [
            ['hello', 'hola'],
            ['goodbye', 'adiós'],
            ['good morning', 'buenos días'],
          ]
        },
      ),
      ContentItemModel(
        id: 'e2',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Como se dice hola',
        payload: {'options': ['hello', 'goodbye', 'please']},
        correctAnswer: {'value': 'hello'},
      ),
      ContentItemModel(
        id: 'e3',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Good morning significa',
        payload: {'options': ['buenas noches', 'buenos dias', 'adios']},
        correctAnswer: {'value': 'buenos dias'},
      ),
      ContentItemModel(
        id: 'e4',
        type: ContentItemType.listening, // STUB
        skill: 'listening',
        cefrLevel: 'A1',
        prompt: 'Escucha y elige',
        payload: {'audio_url': 'a.mp3', 'options': ['Hello', 'Goodbye']},
        correctAnswer: {'value': 'Goodbye'},
      ),
      ContentItemModel(
        id: 'e5',
        type: ContentItemType.wordBank,
        skill: 'writing',
        cefrLevel: 'A1',
        prompt: 'Arma la frase',
        payload: {'tiles': ['Good', 'morning', 'night', 'evening']},
        correctAnswer: {'value': 'Good morning', 'sequence': ['Good', 'morning']},
      ),
      ContentItemModel(
        id: 'e6',
        type: ContentItemType.translation,
        skill: 'writing',
        cefrLevel: 'A1',
        prompt: 'Traduce',
        payload: {'source': 'Adios'},
        correctAnswer: {'value': 'Goodbye', 'accepted': ['goodbye', 'bye']},
      ),
      ContentItemModel(
        id: 'e7',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Para despedirte de noche',
        payload: {'options': ['Good morning', 'Good night', 'Hello']},
        correctAnswer: {'value': 'Good night'},
      ),
      ContentItemModel(
        id: 'e8',
        type: ContentItemType.speakingReadAloud, // STUB
        skill: 'speaking',
        cefrLevel: 'A1',
        prompt: 'Lee en voz alta',
        payload: {'text': 'Hello! Good morning!'},
        correctAnswer: {'expected': 'Hello! Good morning!'},
      ),
    ];

void main() {
  const lesson = LessonModel(
    id: 'l1',
    unitId: 'u1',
    orderIndex: 1,
    title: 'Saludos básicos',
    type: LessonType.lesson,
    xpReward: 15,
  );

  setUp(() {
    // Surface tamaño teléfono para que todo sea visible/hittable.
  });

  testWidgets('Lección 1.1 se completa de inicio a fin con 100%',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: LessonPlayerScreen(lesson: lesson, items: _unit1Lesson1Items()),
    ));
    await tester.pumpAndSettle();

    Future<void> tap(String text) async {
      await tester.tap(find.text(text).first);
      await tester.pumpAndSettle();
    }

    // E1 match: emparejar las 3 (izquierda luego derecha).
    await tap('hello');
    await tap('hola');
    await tap('goodbye');
    await tap('adiós');
    await tap('good morning');
    await tap('buenos días');
    await tap('COMPROBAR');
    expect(find.text('¡Correcto! 🦜'), findsOneWidget);
    await tap('CONTINUAR');

    // E2 multiple_choice.
    await tap('hello');
    await tap('COMPROBAR');
    expect(find.text('¡Correcto! 🦜'), findsOneWidget);
    await tap('CONTINUAR');

    // E3 multiple_choice.
    await tap('buenos dias');
    await tap('COMPROBAR');
    await tap('CONTINUAR');

    // E4 listening → STUB (solo continuar).
    await tap('CONTINUAR');

    // E5 word_bank: arma "Good morning".
    await tap('Good');
    await tap('morning');
    await tap('COMPROBAR');
    expect(find.text('¡Correcto! 🦜'), findsOneWidget);
    await tap('CONTINUAR');

    // E6 translation: escribe "Goodbye".
    await tester.enterText(find.byType(TextField), 'Goodbye');
    await tester.pumpAndSettle();
    await tap('COMPROBAR');
    expect(find.text('¡Correcto! 🦜'), findsOneWidget);
    await tap('CONTINUAR');

    // E7 multiple_choice.
    await tap('Good night');
    await tap('COMPROBAR');
    await tap('CONTINUAR');

    // E8 speaking → STUB. Último ítem: al continuar se va a la pantalla de fin.
    await tester.tap(find.text('CONTINUAR').first);
    await tester.pump(); // navega a la pantalla de fin
    await tester.pump(const Duration(milliseconds: 400)); // no settle: confeti es infinito

    // Pantalla de fin.
    expect(find.text('¡Lo lograste! 🎉'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('Una respuesta incorrecta resta una vida y muestra la corrección',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final items = [
      ContentItemModel(
        id: 'w1',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Elige',
        payload: {'options': ['hello', 'goodbye']},
        correctAnswer: {'value': 'hello'},
      ),
    ];

    await tester.pumpWidget(MaterialApp(
      home: LessonPlayerScreen(lesson: lesson, items: items),
    ));
    await tester.pumpAndSettle();

    // Empieza con 5 vidas.
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.text('goodbye')); // respuesta incorrecta
    await tester.pumpAndSettle();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pumpAndSettle();

    expect(find.text('Casi… 🦜'), findsOneWidget);
    expect(find.textContaining('Respuesta correcta'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // una vida menos
  });
}
