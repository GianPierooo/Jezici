import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Imagen referencial de vocabulario (doble codificación). Se muestra cuando un ítem
/// trae `payload.image_url` (Twemoji CC-BY, alojado en Storage). Carga DIFERIDA por red
/// (cero peso de bundle), tamaño fijo (sin jank de scroll mientras carga) y DEGRADACIÓN
/// con gracia: si la imagen no carga, la tarjeta se colapsa y el ejercicio sigue con
/// texto (no se rompe). `cacheWidth` decodifica a baja resolución (perf).
class ConceptImage extends StatefulWidget {
  const ConceptImage({super.key, required this.url});

  final String url;

  @override
  State<ConceptImage> createState() => _ConceptImageState();
}

class _ConceptImageState extends State<ConceptImage> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed || widget.url.isEmpty) return const SizedBox.shrink();
    return Center(
      child: Container(
        width: 132,
        height: 132,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
        ),
        alignment: Alignment.center,
        child: Image.network(
          widget.url,
          width: 88,
          height: 88,
          fit: BoxFit.contain,
          cacheWidth: 176, // decodifica downscale (retina) → menos memoria/CPU
          gaplessPlayback: true,
          loadingBuilder: (ctx, child, progress) => progress == null
              ? child
              : const SizedBox(
                  width: 88,
                  height: 88,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                ),
          errorBuilder: (ctx, err, stack) {
            // Colapsa tras el frame actual (no se puede setState durante build).
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _failed = true);
            });
            return const SizedBox(width: 88, height: 88);
          },
        ),
      ),
    );
  }
}
