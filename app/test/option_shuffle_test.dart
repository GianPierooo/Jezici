import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/features/lesson/exercises/multiple_choice_exercise.dart';

// F2 (EVAL_AUDIT): las opciones se BARAJAN al servir/renderizar en la superficie
// de LECCIÓN (select directo, sin RPC). Grading es por VALOR → el barajado no
// rompe la corrección. (Checkpoints/exámenes ya llegan barajados del servidor.)

ContentItemModel _mc() => ContentItemModel(
      id: 'i1',
      type: ContentItemType.multipleChoice,
      skill: 'reading',
      cefrLevel: 'A1',
      prompt: '¿Cuál es correcta?',
      payload: {
        'options': ['alpha', 'bravo', 'charlie', 'delta', 'echo'],
      },
      correctAnswer: {'value': 'charlie'},
    );

// Lee el orden VISUAL de las opciones (por su posición vertical en pantalla).
List<String> _renderedOrder(WidgetTester t, List<String> opts) {
  final withY = opts.map((o) => (o, t.getTopLeft(find.text(o)).dy)).toList()
    ..sort((a, b) => a.$2.compareTo(b.$2));
  return withY.map((e) => e.$1).toList();
}

Future<List<String>> _pumpOnce(WidgetTester t) async {
  final answer = ValueNotifier<Object?>(null);
  await t.pumpWidget(MaterialApp(
    home: Scaffold(
      // key único por montaje → State nuevo → nuevo barajado.
      body: MultipleChoiceExercise(
          key: UniqueKey(), item: _mc(), answer: answer, locked: false),
    ),
  ));
  await t.pump();
  return _renderedOrder(t, const ['alpha', 'bravo', 'charlie', 'delta', 'echo']);
}

void main() {
  const original = ['alpha', 'bravo', 'charlie', 'delta', 'echo'];

  testWidgets('opciones = permutación del conjunto (nada perdido/añadido)',
      (t) async {
    final order = await _pumpOnce(t);
    expect(order.toSet(), original.toSet());
    expect(order.length, original.length);
  });

  testWidgets('varios montajes → el orden NO es siempre el mismo (baraja)',
      (t) async {
    final seen = <String>{};
    for (var i = 0; i < 12; i++) {
      seen.add((await _pumpOnce(t)).join('|'));
    }
    // Con 5 opciones (120 permutaciones) y 12 montajes, ver 1 solo orden es
    // astronómicamente improbable si baraja; imposible que colapse a fijo.
    expect(seen.length, greaterThan(1));
  });

  testWidgets('tap envía el VALOR (no el índice) → grading por valor intacto',
      (t) async {
    final answer = ValueNotifier<Object?>(null);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MultipleChoiceExercise(
            item: _mc(), answer: answer, locked: false),
      ),
    ));
    await t.pump();
    await t.tap(find.text('charlie'));
    await t.pump();
    // Se envía el texto de la opción, sea cual sea su posición barajada.
    expect(answer.value, 'charlie');
  });
}
