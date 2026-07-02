import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/audio_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Botón grande para reproducir un audio (TTS) desde una URL. Reutilizado por
/// listening y speaking. Usa AudioEngine (Web Audio en web → sin reproductor en
/// la pantalla de bloqueo).
class AudioPlayButton extends StatefulWidget {
  const AudioPlayButton({super.key, required this.url, this.label, this.big = true});
  final String url;
  /// Etiqueta del botón pequeño; si es null usa el default localizado ("Escuchar").
  final String? label;
  final bool big;

  @override
  State<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends State<AudioPlayButton> {
  bool _playing = false;
  bool _unavailable = false;
  Timer? _failsafe;

  @override
  void initState() {
    super.initState();
    _probe();
  }

  /// Comprueba (best-effort) si el audio existe; si no, muestra "no disponible"
  /// en vez de un botón que cuelga 12 s al tocarlo.
  Future<void> _probe() async {
    if (widget.url.isEmpty) return;
    final ok = await AudioEngine.instance.isUrlAvailable(widget.url);
    if (mounted && !ok) setState(() => _unavailable = true);
  }

  @override
  void dispose() {
    _failsafe?.cancel();
    super.dispose();
  }

  Future<void> _play() async {
    if (widget.url.isEmpty || _unavailable) return;
    setState(() => _playing = true);
    // Failsafe: si el audio no llega/decodifica, no dejes el ícono colgado.
    _failsafe?.cancel();
    _failsafe = Timer(const Duration(seconds: 12), () {
      if (mounted) setState(() => _playing = false);
    });
    await AudioEngine.instance.playUrl(widget.url, onComplete: () {
      _failsafe?.cancel();
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_unavailable) {
      if (widget.big) {
        return Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(color: Color(0xFFE9EAF2), shape: BoxShape.circle),
            child: const Icon(Icons.volume_off_rounded, color: AppColors.textMuted, size: 48),
          ),
        );
      }
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.volume_off_rounded, size: 20),
        label: Text(AppLocalizations.of(context).lessonAudioUnavailableTitle,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          side: const BorderSide(color: Color(0xFFC9CDDD)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      );
    }
    if (widget.big) {
      return Center(
        child: GestureDetector(
          onTap: _play,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), offset: const Offset(0, 8), blurRadius: 20),
              ],
            ),
            child: Icon(_playing ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                color: Colors.white, size: 56),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: _play,
      icon: Icon(_playing ? Icons.volume_up_rounded : Icons.volume_up_outlined, size: 20),
      label: Text(widget.label ?? AppLocalizations.of(context).audioPlayDefault,
          style: const TextStyle(fontWeight: FontWeight.w900)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}
