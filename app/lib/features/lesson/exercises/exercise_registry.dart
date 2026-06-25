import 'package:flutter/material.dart';

import '../../../data/models/content_item_model.dart';
import '../grading/grader.dart';
import 'cloze_exercise.dart';
import 'common.dart';
import 'concept_image.dart';
import 'listening_exercise.dart';
import 'match_exercise.dart';
import 'multiple_choice_exercise.dart';
import 'speaking_exercise.dart';
import 'stub_exercise.dart';
import 'tile_arrange_exercise.dart';
import 'translation_exercise.dart';

/// Registro tipo→widget. Enchufar un tipo nuevo = añadir su widget y una
/// entrada aquí (más una rama en el grader). El resto del loop no cambia.
final Map<ContentItemType, ExerciseBuilder> exerciseRegistry = {
  ContentItemType.multipleChoice: (c, i, a, l) =>
      MultipleChoiceExercise(item: i, answer: a, locked: l),
  ContentItemType.trueFalse: (c, i, a, l) =>
      MultipleChoiceExercise(item: i, answer: a, locked: l),
  ContentItemType.cloze: (c, i, a, l) => ClozeExercise(item: i, answer: a, locked: l),
  ContentItemType.translation: (c, i, a, l) =>
      TranslationExercise(item: i, answer: a, locked: l),
  ContentItemType.wordBank: (c, i, a, l) =>
      TileArrangeExercise(item: i, answer: a, locked: l),
  ContentItemType.reorder: (c, i, a, l) =>
      TileArrangeExercise(item: i, answer: a, locked: l),
  ContentItemType.match: (c, i, a, l) => MatchExercise(item: i, answer: a, locked: l),
  // Audio real (paso Audio): listening jugable, speaking con Web Speech.
  ContentItemType.listening: (c, i, a, l) =>
      ListeningExercise(item: i, answer: a, locked: l),
  ContentItemType.speakingReadAloud: (c, i, a, l) => SpeakingExercise(item: i),
};

/// ¿Hay un widget jugable para este tipo? (los stubs no se califican)
bool isPlayable(ContentItemType type) =>
    exerciseRegistry.containsKey(type) && !isStubType(type);

/// Construye el widget del ejercicio; si no hay jugable, cae a un stub elegante.
Widget buildExerciseWidget(
  BuildContext context,
  ContentItemModel item,
  ValueNotifier<Object?> answer,
  bool locked,
) {
  // listening y speaking ahora tienen widget real (audio / Web Speech); solo
  // los tipos sin widget (dictation, guided_writing, unknown) caen al stub.
  final builder = exerciseRegistry[item.type];
  final exercise = builder == null ? StubExercise(item: item) : builder(context, item, answer, locked);
  // Imagen referencial (doble codificación) si el ítem la trae; se muestra ARRIBA del
  // ejercicio en TODAS las superficies (lección/checkpoint/examen/práctica). Carga
  // diferida + degradación con gracia (ConceptImage colapsa si no carga → el ejercicio
  // sigue con texto). Para image-MC la imagen es el estímulo, así que debe ir siempre.
  final imageUrl = (item.payload['image_url'] ?? '').toString();
  if (imageUrl.isEmpty) return exercise;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [ConceptImage(url: imageUrl), exercise],
  );
}
