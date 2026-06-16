import 'package:flutter/material.dart';

import '../../../data/models/content_item_model.dart';
import '../../../core/theme/app_colors.dart';

/// Firma del builder de un ejercicio. El registry mapea cada `type` a uno.
/// El widget reporta la respuesta del usuario en [answer] (null = sin responder)
/// y, cuando [locked] es true (feedback visible), congela la interacción y puede
/// revelar la corrección.
typedef ExerciseBuilder = Widget Function(
  BuildContext context,
  ContentItemModel item,
  ValueNotifier<Object?> answer,
  bool locked,
);

/// Ficha/botón "jugoso" reutilizable (banco de palabras, opciones, fichas).
class JzTile extends StatelessWidget {
  const JzTile({
    super.key,
    required this.label,
    this.onTap,
    this.bg = Colors.white,
    this.fg = AppColors.text,
    this.borderColor = const Color(0xFFECEEF6),
    this.depthColor = const Color(0xFFD4D8E8),
    this.dim = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Color bg;
  final Color fg;
  final Color borderColor;
  final Color depthColor;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim ? 0.35 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.6),
            boxShadow: [
              BoxShadow(color: depthColor, offset: const Offset(0, 4), blurRadius: 0),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: fg),
          ),
        ),
      ),
    );
  }
}
