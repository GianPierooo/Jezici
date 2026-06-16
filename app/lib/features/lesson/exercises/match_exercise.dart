import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/feedback/feedback_fx.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import '../grading/grader.dart';

/// Emparejar: dos columnas (palabra ↔ traducción). Toca una de la izquierda y
/// luego su pareja a la derecha. Toca una pareja hecha para deshacerla.
/// Se keyea por ÍNDICE (no por texto) para soportar tokens repetidos.
class MatchExercise extends StatefulWidget {
  const MatchExercise({
    super.key,
    required this.item,
    required this.answer,
    required this.locked,
  });

  final ContentItemModel item;
  final ValueNotifier<Object?> answer;
  final bool locked;

  @override
  State<MatchExercise> createState() => _MatchExerciseState();
}

class _MatchExerciseState extends State<MatchExercise> {
  late final List<String> _lefts; // en, en orden de payload.pairs
  late final List<String> _rights; // es, barajados
  final Map<int, int> _pairs = {}; // leftIndex -> rightIndex
  int? _selectedLeft;

  Map<String, String> get _correctMap {
    final pairs = widget.item.correctAnswer['pairs'];
    final list = pairs is List ? pairs : const [];
    return {
      for (final p in list)
        if (p is List && p.length >= 2) p[0].toString(): p[1].toString(),
    };
  }

  @override
  void initState() {
    super.initState();
    final pairs = widget.item.payload['pairs'];
    final list = pairs is List ? pairs : const [];
    _lefts = [for (final p in list) (p as Map)['en'].toString()];
    _rights = [for (final p in list) (p as Map)['es'].toString()];
    _rights.shuffle(math.Random(widget.item.id.hashCode));
  }

  void _sync() {
    widget.answer.value = _pairs.length == _lefts.length
        ? {for (final e in _pairs.entries) e.key: _rights[e.value]}
        : null;
  }

  int? _ownerOf(int rightIndex) {
    for (final e in _pairs.entries) {
      if (e.value == rightIndex) return e.key;
    }
    return null;
  }

  void _tapLeft(int i) {
    if (widget.locked) return;
    FeedbackFx.tap();
    setState(() {
      if (_pairs.containsKey(i)) {
        _pairs.remove(i); // deshacer
        _selectedLeft = null;
      } else {
        _selectedLeft = _selectedLeft == i ? null : i;
      }
    });
    _sync();
  }

  void _tapRight(int j) {
    if (widget.locked) return;
    FeedbackFx.tap();
    setState(() {
      final owner = _ownerOf(j);
      if (owner != null) {
        _pairs.remove(owner); // deshacer
        _selectedLeft = null;
      } else if (_selectedLeft != null) {
        _pairs[_selectedLeft!] = j;
        _selectedLeft = null;
      }
    });
    _sync();
  }

  _RevealState _revealLeft(int i) {
    if (!widget.locked || !_pairs.containsKey(i)) return _RevealState.none;
    final chosen = _rights[_pairs[i]!];
    final expected = _correctMap[_lefts[i]] ?? '';
    return normalize(chosen) == normalize(expected) ? _RevealState.ok : _RevealState.bad;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < _lefts.length; i++) ...[
                _MatchChip(
                  label: _lefts[i],
                  partner: _pairs.containsKey(i) ? _rights[_pairs[i]!] : null,
                  selected: _selectedLeft == i,
                  state: _revealLeft(i),
                  onTap: () => _tapLeft(i),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              for (var j = 0; j < _rights.length; j++) ...[
                _MatchChip(
                  label: _rights[j],
                  used: _pairs.values.contains(j),
                  onTap: () => _tapRight(j),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

enum _RevealState { none, ok, bad }

class _MatchChip extends StatelessWidget {
  const _MatchChip({
    required this.label,
    this.partner,
    this.selected = false,
    this.used = false,
    this.state = _RevealState.none,
    this.onTap,
  });

  final String label;
  final String? partner;
  final bool selected;
  final bool used;
  final _RevealState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = const Color(0xFFE5E7F1);
    Color fg = AppColors.text;

    if (state == _RevealState.ok) {
      bg = const Color(0xFFE5F8EE);
      border = AppColors.success;
      fg = AppColors.successDark;
    } else if (state == _RevealState.bad) {
      bg = const Color(0xFFFFE9ED);
      border = AppColors.hearts;
      fg = const Color(0xFFD6294B);
    } else if (selected || partner != null) {
      bg = AppColors.navActiveBg;
      border = AppColors.primary;
      fg = AppColors.primary;
    }

    return Opacity(
      opacity: used ? 0.4 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: fg),
                ),
              ),
              if (partner != null)
                Text(
                  '→ $partner',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
