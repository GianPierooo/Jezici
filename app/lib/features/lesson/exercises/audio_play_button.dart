import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/audio_engine.dart';
import '../../../core/errors/error_reporter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Botón grande para reproducir un audio (TTS) desde una URL. Reutilizado por
/// listening y speaking. Usa AudioEngine (Web Audio en web → sin reproductor en
/// la pantalla de bloqueo).
///
/// Antes: si el MP3 no llegaba/decodificaba, el ícono quedaba "sonando" 12 s y
/// volvía a play SIN ningún mensaje ni telemetría → "no suena" indiagnosticable.
/// Ahora `playUrl` avisa por `onError` → estado de error LEGIBLE ("No se pudo
/// reproducir · reintentar") + evento a Sentry (jz_audio_play).
class AudioPlayButton extends StatefulWidget {
  const AudioPlayButton({super.key, required this.url, this.label, this.big = true, this.surface});
  final String url;

  /// Etiqueta del botón pequeño; si es null usa el default localizado ("Escuchar").
  final String? label;
  final bool big;

  /// Contexto para Sentry (p.ej. 'listening', 'placement', 'story') — sin PII.
  final String? surface;

  @override
  State<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends State<AudioPlayButton> {
  bool _playing = false;
  bool _unavailable = false;
  bool _error = false; // falló la reproducción (red/decode): mostrar reintentar
  Timer? _failsafe;

  @override
  void initState() {
    super.initState();
    _probe();
  }

  /// Comprueba (best-effort) si el audio existe; si no, muestra "no disponible"
  /// en vez de un botón que cuelga al tocarlo.
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

  void _reportFail(String reason) {
    _failsafe?.cancel();
    if (mounted) {
      setState(() {
        _playing = false;
        _error = true;
      });
    }
    // Telemetría: convierte "no suena en algunos dispositivos" en un dato. Sin PII.
    reportError(
      Exception('audio_play_failed'),
      rpc: 'jz_audio_play',
      context: 'surface=${widget.surface ?? 'audio'};reason=$reason;host=${_host(widget.url)}',
    );
  }

  static String _host(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return '?';
    }
  }

  Future<void> _play() async {
    if (widget.url.isEmpty || _unavailable) return;
    setState(() {
      _playing = true;
      _error = false;
    });
    // Backstop: si ni onComplete ni onError llegan (caso extremo), no colgar.
    _failsafe?.cancel();
    _failsafe = Timer(const Duration(seconds: 12), () {
      if (mounted) setState(() => _playing = false);
    });
    await AudioEngine.instance.playUrl(
      widget.url,
      onComplete: () {
        _failsafe?.cancel();
        if (mounted) setState(() => _playing = false);
      },
      onError: _reportFail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        label: Text(l10n.lessonAudioUnavailableTitle,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          side: const BorderSide(color: Color(0xFFC9CDDD)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      );
    }
    if (widget.big) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
          child: GestureDetector(
            onTap: _play,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: _error
                        ? const [Color(0xFFFFB199), AppColors.coral]
                        : const [AppColors.primaryLight, AppColors.primary]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: (_error ? AppColors.coral : AppColors.primary).withValues(alpha: 0.35),
                      offset: const Offset(0, 8),
                      blurRadius: 20),
                ],
              ),
              child: Icon(
                  _error
                      ? Icons.refresh_rounded
                      : (_playing ? Icons.volume_up_rounded : Icons.play_arrow_rounded),
                  color: Colors.white,
                  size: 56),
            ),
          ),
        ),
        if (_error) ...[
          const SizedBox(height: 10),
          Text(l10n.audioPlayError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.coral)),
        ],
      ]);
    }
    if (_error) {
      return OutlinedButton.icon(
        onPressed: _play,
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: Text(l10n.audioPlayError, style: const TextStyle(fontWeight: FontWeight.w900)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.coral,
          side: const BorderSide(color: AppColors.coral),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: _play,
      icon: Icon(_playing ? Icons.volume_up_rounded : Icons.volume_up_outlined, size: 20),
      label: Text(widget.label ?? l10n.audioPlayDefault,
          style: const TextStyle(fontWeight: FontWeight.w900)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}
