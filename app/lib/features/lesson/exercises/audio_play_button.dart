import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Botón grande para reproducir un audio (TTS) desde una URL. Reutilizado por
/// listening y speaking (modelo de pronunciación).
class AudioPlayButton extends StatefulWidget {
  const AudioPlayButton({super.key, required this.url, this.label = 'Escuchar', this.big = true});
  final String url;
  final String label;
  final bool big;

  @override
  State<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends State<AudioPlayButton> {
  // Player perezoso: no se crea hasta el primer play (evita tocar el plugin en
  // tests/headless y al primer render).
  AudioPlayer? _player;
  bool _playing = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (widget.url.isEmpty) return;
    try {
      _player ??= AudioPlayer()
        ..onPlayerComplete.listen((_) {
          if (mounted) setState(() => _playing = false);
        });
      setState(() => _playing = true);
      await _player!.stop();
      await _player!.play(UrlSource(widget.url));
    } catch (_) {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      label: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w900)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}
