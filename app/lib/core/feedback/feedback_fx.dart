import 'package:flutter/services.dart';

/// Microinteracciones de feedback (Sistema_Diseno §6): háptico + sonido.
/// En Fase 1 usamos hápticos del sistema y un click sutil (sin assets de audio).
/// `correctSfx`/`wrongSfx` quedan como gancho para sonidos dedicados luego.
class FeedbackFx {
  FeedbackFx._();

  static void correct() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  static void wrong() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
  }

  static void tap() {
    HapticFeedback.selectionClick();
  }
}
