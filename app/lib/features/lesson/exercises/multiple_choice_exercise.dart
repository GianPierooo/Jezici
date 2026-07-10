import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import '../grading/grader.dart';

/// Opción múltiple (y verdadero/falso). Botones verticales; al comprobar revela
/// la opción correcta en verde y, si fallaste, la tuya en rojo.
class MultipleChoiceExercise extends StatefulWidget {
  const MultipleChoiceExercise({
    super.key,
    required this.item,
    required this.answer,
    required this.locked,
  });

  final ContentItemModel item;
  final ValueNotifier<Object?> answer;
  final bool locked;

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? _selected;
  late final List<String> _options;

  @override
  void initState() {
    super.initState();
    _selected = widget.answer.value as String?;
    // Baraja el orden de las opciones UNA vez por ítem (no en cada build, para no
    // reordenar al comprobar). Cierra la memorización de posiciones del repetidor
    // ("siempre la 2ª"). El grading es por VALOR (grade_item/jz_grade compara el
    // texto, no el índice) → barajar el orden mostrado NO afecta la corrección.
    // Cubre la superficie de LECCIÓN (select directo, sin RPC); checkpoints y
    // exámenes ya llegan barajados desde el servidor (jz_shuffle_options).
    _options = ((widget.item.payload['options'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[])
      ..shuffle();
  }

  String get _correct => (widget.item.correctAnswer['value'] ?? '').toString();

  void _select(String opt) {
    setState(() => _selected = opt);
    widget.answer.value = opt;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final opt in _options) ...[
          _OptionButton(
            label: opt,
            selected: _selected == opt,
            locked: widget.locked,
            isCorrect: widget.locked && normalize(opt) == normalize(_correct),
            isWrongChoice: widget.locked &&
                _selected == opt &&
                normalize(opt) != normalize(_correct),
            onTap: widget.locked ? null : () => _select(opt),
          ),
          const SizedBox(height: 11),
        ],
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.locked,
    required this.isCorrect,
    required this.isWrongChoice,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool isCorrect;
  final bool isWrongChoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = const Color(0xFFE5E7F1);
    Color fg = AppColors.text;
    if (isCorrect) {
      bg = const Color(0xFFE5F8EE);
      border = AppColors.success;
      fg = AppColors.successDark;
    } else if (isWrongChoice) {
      bg = const Color(0xFFFFE9ED);
      border = AppColors.hearts;
      fg = const Color(0xFFD6294B);
    } else if (selected) {
      bg = AppColors.navActiveBg;
      border = AppColors.primary;
      fg = AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: border, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: fg),
              ),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22)
            else if (isWrongChoice)
              const Icon(Icons.cancel_rounded, color: AppColors.hearts, size: 22),
          ],
        ),
      ),
    );
  }
}
