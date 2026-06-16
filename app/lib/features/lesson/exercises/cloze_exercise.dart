import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import '../grading/grader.dart';

/// Rellenar el espacio. Si el payload trae `options`, se muestran como fichas
/// para elegir; si no, un campo de texto libre.
class ClozeExercise extends StatefulWidget {
  const ClozeExercise({
    super.key,
    required this.item,
    required this.answer,
    required this.locked,
  });

  final ContentItemModel item;
  final ValueNotifier<Object?> answer;
  final bool locked;

  @override
  State<ClozeExercise> createState() => _ClozeExerciseState();
}

class _ClozeExerciseState extends State<ClozeExercise> {
  late final TextEditingController _controller;
  String? _selected;

  List<String> get _options =>
      (widget.item.payload['options'] as List?)?.map((e) => e.toString()).toList() ??
      const [];

  bool get _hasOptions => _options.isNotEmpty;
  String get _correct => (widget.item.correctAnswer['value'] ?? '').toString();
  String get _text => (widget.item.payload['text'] ?? widget.item.prompt ?? '').toString();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer.value as String? ?? '');
    _selected = widget.answer.value as String?;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Coincide con el grader: acepta `value` + `accepted` (normalizados).
  bool _isUserCorrect() {
    final accepted = <String>[
      _correct,
      ...((widget.item.correctAnswer['accepted'] as List?)?.map((e) => e.toString()) ??
          const []),
    ];
    return accepted.any((a) => normalize(a) == normalize(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
            ],
          ),
          child: Text(
            _text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (_hasOptions)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final opt in _options)
                _ChoiceChip(
                  label: opt,
                  selected: _selected == opt,
                  locked: widget.locked,
                  isCorrect: widget.locked && normalize(opt) == normalize(_correct),
                  isWrong: widget.locked &&
                      _selected == opt &&
                      normalize(opt) != normalize(_correct),
                  onTap: widget.locked
                      ? null
                      : () {
                          setState(() => _selected = opt);
                          widget.answer.value = opt;
                        },
                ),
            ],
          )
        else
          TextField(
            controller: _controller,
            enabled: !widget.locked,
            autofocus: false,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta…',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _isUserCorrect() ? AppColors.success : AppColors.hearts,
                  width: 2,
                ),
              ),
            ),
            onChanged: (v) =>
                widget.answer.value = v.trim().isEmpty ? null : v,
          ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.locked,
    required this.isCorrect,
    required this.isWrong,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool isCorrect;
  final bool isWrong;
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
    } else if (isWrong) {
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: fg),
        ),
      ),
    );
  }
}
