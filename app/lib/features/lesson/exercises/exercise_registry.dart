import 'package:flutter/material.dart';

import '../../../data/models/content_item_model.dart';
import '../grading/grader.dart';
import 'cloze_exercise.dart';
import 'common.dart';
import 'match_exercise.dart';
import 'multiple_choice_exercise.dart';
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
  final builder = exerciseRegistry[item.type];
  if (builder == null || isStubType(item.type)) {
    return StubExercise(item: item);
  }
  return builder(context, item, answer, locked);
}
