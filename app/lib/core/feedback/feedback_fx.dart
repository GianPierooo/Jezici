import 'package:flutter/services.dart';

import '../audio/sound_service.dart';

/// Microinteracciones de feedback (Sistema_Diseno §6): háptico + sonido.
/// Punto ÚNICO de "jugosidad" — usado en toda la app para consistencia (GA8).
class FeedbackFx {
  FeedbackFx._();

  /// Preferencia de vibración (Ajustes → Vibración). Sincronizada por
  /// VibrationController; cuando está apagada, ninguna llamada háptica vibra.
  static bool hapticsEnabled = true;

  static void _haptic(void Function() fn) {
    if (hapticsEnabled) fn();
  }

  static void correct() {
    _haptic(HapticFeedback.lightImpact);
    SoundService.instance.play(Sfx.correct);
  }

  static void wrong() {
    _haptic(HapticFeedback.heavyImpact);
    SoundService.instance.play(Sfx.wrong);
  }

  static void combo() {
    _haptic(HapticFeedback.mediumImpact);
    SoundService.instance.play(Sfx.combo);
  }

  static void lessonComplete({bool golden = false}) {
    _haptic(HapticFeedback.mediumImpact);
    SoundService.instance.play(golden ? Sfx.celebrate : Sfx.lessonComplete);
  }

  static void levelUp() {
    _haptic(HapticFeedback.heavyImpact);
    SoundService.instance.play(Sfx.levelUp);
  }

  static void celebrate() {
    _haptic(HapticFeedback.heavyImpact);
    SoundService.instance.play(Sfx.celebrate);
  }

  static void streak() {
    _haptic(HapticFeedback.mediumImpact);
    SoundService.instance.play(Sfx.streak);
  }

  static void tap() {
    _haptic(HapticFeedback.selectionClick);
  }
}
