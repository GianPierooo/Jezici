import 'package:flutter/services.dart';

import '../audio/sound_service.dart';

/// Microinteracciones de feedback (Sistema_Diseno §6): háptico + sonido.
/// Punto ÚNICO de "jugosidad" — usado en toda la app para consistencia (GA8).
class FeedbackFx {
  FeedbackFx._();

  static void correct() {
    HapticFeedback.lightImpact();
    SoundService.instance.play(Sfx.correct);
  }

  static void wrong() {
    HapticFeedback.heavyImpact();
    SoundService.instance.play(Sfx.wrong);
  }

  static void combo() {
    HapticFeedback.mediumImpact();
    SoundService.instance.play(Sfx.combo);
  }

  static void lessonComplete({bool golden = false}) {
    HapticFeedback.mediumImpact();
    SoundService.instance.play(golden ? Sfx.celebrate : Sfx.lessonComplete);
  }

  static void levelUp() {
    HapticFeedback.heavyImpact();
    SoundService.instance.play(Sfx.levelUp);
  }

  static void celebrate() {
    HapticFeedback.heavyImpact();
    SoundService.instance.play(Sfx.celebrate);
  }

  static void streak() {
    HapticFeedback.mediumImpact();
    SoundService.instance.play(Sfx.streak);
  }

  static void tap() {
    HapticFeedback.selectionClick();
  }
}
