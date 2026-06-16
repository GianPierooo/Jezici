import 'package:flutter/material.dart';

import '../../../core/feedback/feedback_fx.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import 'common.dart';

/// Banco de palabras / reordenar: toca las fichas para formar la frase.
/// Zona de construcción arriba + banco abajo. Se usa para `word_bank` y `reorder`.
class TileArrangeExercise extends StatefulWidget {
  const TileArrangeExercise({
    super.key,
    required this.item,
    required this.answer,
    required this.locked,
  });

  final ContentItemModel item;
  final ValueNotifier<Object?> answer;
  final bool locked;

  @override
  State<TileArrangeExercise> createState() => _TileArrangeExerciseState();
}

class _TileArrangeExerciseState extends State<TileArrangeExercise> {
  // Cada ficha es (índice estable, texto), para permitir repetidos.
  late List<_Tok> _bank;
  final List<_Tok> _placed = [];

  @override
  void initState() {
    super.initState();
    final tiles =
        (widget.item.payload['tiles'] as List?)?.map((e) => e.toString()).toList() ??
            const <String>[];
    _bank = [for (var i = 0; i < tiles.length; i++) _Tok(i, tiles[i])];

    // Restaurar respuesta previa si la hubiera.
    final prev = widget.answer.value;
    if (prev is List) {
      for (final label in prev) {
        final idx = _bank.indexWhere((t) => t.label == label.toString());
        if (idx >= 0) {
          _placed.add(_bank[idx]);
          _bank.removeAt(idx);
        }
      }
    }
  }

  void _sync() {
    widget.answer.value = _placed.isEmpty ? null : _placed.map((t) => t.label).toList();
  }

  void _place(_Tok t) {
    if (widget.locked) return;
    FeedbackFx.tap();
    setState(() {
      _bank.remove(t);
      _placed.add(t);
    });
    _sync();
  }

  void _remove(_Tok t) {
    if (widget.locked) return;
    FeedbackFx.tap();
    setState(() {
      _placed.remove(t);
      _bank.add(t);
      _bank.sort((a, b) => a.id.compareTo(b.id));
    });
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Zona de construcción.
        Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF1F8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E5F0), width: 1.5),
          ),
          child: _placed.isEmpty
              ? const Text(
                  'Toca las palabras para formar la frase…',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC2C6D6),
                  ),
                )
              : Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final t in _placed)
                      JzTile(label: t.label, onTap: () => _remove(t)),
                  ],
                ),
        ),
        const SizedBox(height: 20),
        // Banco.
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final t in _bank)
              JzTile(
                label: t.label,
                depthColor: const Color(0xFFD4D8E8),
                onTap: () => _place(t),
              ),
            if (_bank.isEmpty)
              const SizedBox(
                height: 42,
                child: Center(
                  child: Text(
                    'Todas colocadas — pulsa COMPROBAR',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Tok {
  const _Tok(this.id, this.label);
  final int id;
  final String label;
}
