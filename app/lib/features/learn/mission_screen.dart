import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/lesson_model.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/parrot_mascot.dart';

/// Nodo MISIÓN "100 esenciales" (GA9): primer nodo del mapa. Explica la misión
/// (coleccionas las 100 palabras de alta frecuencia al avanzar) y arranca el
/// viaje — al empezar, desbloquea la primera lección.
class MissionScreen extends ConsumerStatefulWidget {
  const MissionScreen({super.key, required this.lesson});
  final LessonModel lesson;

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> {
  bool _loading = false;

  static const _cats = [
    ('👋', 'Saludos y cortesía', '12'),
    ('🧍', 'Pronombres y "to be"', '14'),
    ('⚡', 'Verbos frecuentes', '15'),
    ('🔢', 'Números 1–20', '20'),
    ('👨‍👩‍👧', 'Personas y familia', '10'),
    ('☕', 'Cotidiano', '15'),
    ('❓', 'Preguntas y útiles', '14'),
  ];

  Future<void> _start() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context);
    try {
      final res =
          await ref.read(progressRepositoryProvider).completeMission(widget.lesson.id);
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(homeStatsProvider); // el bono cambió oro/XP
      ref.read(progressRepositoryProvider).logEvent('mission_started');
      FeedbackFx.celebrate();
      if (!mounted) return;
      // Confirmación clara del arranque + bono de bienvenida (one-time).
      await _showStarted(
        l10n,
        xp: (res['xp_earned'] as num?)?.toInt() ?? 0,
        gold: (res['gold_earned'] as num?)?.toInt() ?? 0,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('completeMission falló: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.missionStartError)));
    }
  }

  /// Momento "empezaste tu viaje": confirma el arranque y muestra el bono de
  /// bienvenida (si lo hubo). No bloquea: un solo botón para entrar al mapa.
  Future<void> _showStarted(AppLocalizations l10n, {required int xp, required int gold}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ParrotMascot(size: 64, mood: MascotMood.celebrate),
              const SizedBox(height: 12),
              Text(l10n.missionWelcomeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              Text(l10n.missionWelcomeBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.35)),
              if (xp > 0 || gold > 0) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('🎁 ${l10n.missionRewardBanner(xp, gold)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF9A7A1E))),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.commonContinue,
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: const Text('Misión', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  const Center(child: ParrotMascot(size: 72, mood: MascotMood.celebrate)),
                  const SizedBox(height: 12),
                  const Text('Las 100 palabras esenciales',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu primer gran objetivo: dominar las 100 palabras y frases de más alta '
                    'frecuencia del inglés. Las irás coleccionando al completar tus lecciones. '
                    'Al juntarlas, ganas el badge "100 esenciales".',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
                    child: Column(
                      children: [
                        for (final (emoji, name, n) in _cats)
                          ListTile(
                            dense: true,
                            leading: Text(emoji, style: const TextStyle(fontSize: 22)),
                            title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                            trailing: Text('$n palabras', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(_loading ? 'PREPARANDO…' : '¡EMPEZAR MI VIAJE! 🚀',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.4)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
