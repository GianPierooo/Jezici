import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Resultado de la hoja "sin vidas".
enum NoHeartsChoice { refill, quit }

/// Hoja "te quedaste sin vidas" (mockup SinVidas, versión básica del paso D).
/// Recarga básica local; ads/premium/timer llegan después.
Future<NoHeartsChoice?> showNoHeartsSheet(BuildContext context) {
  return showModalBottomSheet<NoHeartsChoice>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NoHeartsSheet(),
  );
}

class _NoHeartsSheet extends StatelessWidget {
  const _NoHeartsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E6EE),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          // Corazones vacíos.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Icon(Icons.favorite_border_rounded,
                    color: Color(0xFFE2E5F0), size: 26),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Te quedaste sin vidas ❤️',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          const Text(
            '¡Tranqui, le pasa a todos! Las vidas se regeneran con el tiempo; '
            'si quieres seguir ahora, recárgalas con oro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _SheetButton(
              icon: Icons.favorite_rounded,
              label: 'Recargar vidas y seguir',
              color: AppColors.primary,
              onTap: () => Navigator.of(context).pop(NoHeartsChoice.refill),
            ),
          ),
          const SizedBox(height: 11),
          TextButton(
            onPressed: () => Navigator.of(context).pop(NoHeartsChoice.quit),
            child: const Text(
              'Salir de la lección',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
