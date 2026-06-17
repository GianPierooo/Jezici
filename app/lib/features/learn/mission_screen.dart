import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/lesson_model.dart';
import '../../data/providers.dart';
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
    try {
      await ref.read(progressRepositoryProvider).completeMission(widget.lesson.id);
      ref.invalidate(lessonProgressProvider);
      ref.read(progressRepositoryProvider).logEvent('mission_started');
      FeedbackFx.lessonComplete();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('completeMission falló: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo empezar. Inténtalo de nuevo.')));
    }
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
