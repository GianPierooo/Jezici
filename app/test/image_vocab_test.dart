import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/features/lesson/exercises/concept_image.dart';
import 'package:jezici/features/lesson/exercises/exercise_registry.dart';

/// La imagen referencial (Twemoji) se muestra ARRIBA del ejercicio cuando el ítem trae
/// payload.image_url, y el ejercicio sigue siendo funcional (opciones presentes). Sin
/// image_url no se añade nada. Degradación: si la imagen no carga (en test no hay red),
/// ConceptImage colapsa pero las opciones del MC siguen ahí.
ContentItemModel _mc({String? imageUrl}) => ContentItemModel(
      id: 'i1',
      type: ContentItemType.multipleChoice,
      skill: 'reading',
      cefrLevel: 'A1',
      prompt: '¿Qué es esto?',
      payload: {
        'options': const ['coffee', 'tea', 'water'],
        if (imageUrl != null) 'image_url': imageUrl,
      },
      correctAnswer: const {'value': 'coffee'},
    );

void main() {
  testWidgets('con image_url: ConceptImage presente + ejercicio funcional', (t) async {
    final answer = ValueNotifier<Object?>(null);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (ctx) => buildExerciseWidget(ctx, _mc(imageUrl: 'https://example.test/coffee.png'), answer, false)),
      ),
    ));
    await t.pump();
    expect(find.byType(ConceptImage), findsOneWidget);
    // El ejercicio sigue funcionando: las opciones se renderizan con o sin imagen.
    expect(find.text('coffee'), findsOneWidget);
    expect(find.text('tea'), findsOneWidget);
  });

  testWidgets('sin image_url: no se añade ConceptImage', (t) async {
    final answer = ValueNotifier<Object?>(null);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (ctx) => buildExerciseWidget(ctx, _mc(), answer, false)),
      ),
    ));
    await t.pump();
    expect(find.byType(ConceptImage), findsNothing);
    expect(find.text('coffee'), findsOneWidget);
  });
}
