import 'package:flutter/widgets.dart';

/// Claves globales de los elementos REALES de la UI que el tour de bienvenida
/// resalta (coach marks). Se adjuntan una sola vez (solo hay una BottomNav y una
/// barra superior a la vez), así el overlay del tour puede medir su rect global
/// sin acoplar cada widget al tour. Si una clave no resuelve (elemento no montado
/// en ese estado), el paso del tour se muestra centrado, sin spotlight.
class TourKeys {
  TourKeys._();

  /// Los 6 botones del nav inferior: Aprender, Estudiar, Practicar, Conversar,
  /// Ligas, Perfil.
  static final List<GlobalKey> nav = List.generate(6, (_) => GlobalKey());

  /// La barra superior del mapa (vidas ❤️ · oro 🪙 · racha 🔥).
  static final GlobalKey topBar = GlobalKey();
}
