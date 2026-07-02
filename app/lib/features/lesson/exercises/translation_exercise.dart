import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import '../../../l10n/app_localizations.dart';
import '../grading/grader.dart';

/// Traducción: muestra la frase origen y un campo para escribir la traducción.
class TranslationExercise extends StatefulWidget {
  const TranslationExercise({
    super.key,
    required this.item,
    required this.answer,
    required this.locked,
  });

  final ContentItemModel item;
  final ValueNotifier<Object?> answer;
  final bool locked;

  @override
  State<TranslationExercise> createState() => _TranslationExerciseState();
}

class _TranslationExerciseState extends State<TranslationExercise> {
  late final TextEditingController _controller;

  String get _source => (widget.item.payload['source'] ?? '').toString();
  String get _correct => (widget.item.correctAnswer['value'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer.value as String? ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🦜', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
                  ],
                ),
                child: Text(
                  _source,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _controller,
          enabled: !widget.locked,
          minLines: 1,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            hintText: l10n.translationHint,
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
          onChanged: (v) => widget.answer.value = v.trim().isEmpty ? null : v,
        ),
      ],
    );
  }

  bool _isUserCorrect() {
    final accepted = <String>[
      _correct,
      ...((widget.item.correctAnswer['accepted'] as List?)?.map((e) => e.toString()) ??
          const []),
    ];
    return accepted.any((a) => normalize(a) == normalize(_controller.text));
  }
}
