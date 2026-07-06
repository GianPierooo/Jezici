import 'package:flutter/material.dart';

/// Centra el contenido con un ancho máximo sensato para que en pantallas anchas
/// (tablet/desktop/web) no quede estirado edge-to-edge ni en una columna perdida.
/// En móvil (ancho de pantalla ≤ maxWidth) el `ConstrainedBox` no tiene efecto →
/// el layout móvil (target principal) queda IDÉNTICO. Determinista, sin breakpoints
/// mágicos: una sola regla (máximo + centrado) que se degrada sola en angosto.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
