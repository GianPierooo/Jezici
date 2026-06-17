import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/lesson_model.dart';
import '../../data/providers.dart';
import 'checkpoint_player_screen.dart';

/// Intro del checkpoint (mockup Checkpoint, Frame A): portal + condiciones de
/// examen (cronometrado, 80%, nº de preguntas) y "Empezar checkpoint".
class CheckpointIntroScreen extends ConsumerWidget {
  const CheckpointIntroScreen({super.key, required this.lesson, required this.unitTitle});

  final LessonModel lesson;
  final String unitTitle;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );
    try {
      final data = await ref.read(progressRepositoryProvider).startCheckpoint(lesson.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CheckpointPlayerScreen(lesson: lesson, unitTitle: unitTitle, data: data),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar el examen. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Escena del portal.
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5B4ECF), AppColors.primary, Color(0xFF8273E8)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            unitTitle.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Portal.
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              AppColors.gold.withValues(alpha: 0.5),
                              AppColors.gold.withValues(alpha: 0.0),
                            ]),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 138,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8474F0), Color(0xFF5E51C9)],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(60),
                              bottom: Radius.circular(14),
                            ),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF4B3FA8), offset: Offset(0, 6), blurRadius: 0),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFE9A8), AppColors.gold],
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(44),
                                bottom: Radius.circular(8),
                              ),
                            ),
                            child: const Icon(Icons.star_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('⚑ CHECKPOINT',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Color(0xFF5B3A00))),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'El portal de la unidad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unitTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14, right: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('🦜  ¡Demuestra lo que sabes!',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Hoja de info.
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            transform: Matrix4.translationValues(0, -22, 0),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Supera el portal para abrir la siguiente región del mapa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    _StatCard(icon: Icons.timer_outlined, value: '5 min', label: 'cronometrado'),
                    SizedBox(width: 10),
                    _StatCard(icon: Icons.adjust_rounded, value: '80%', label: 'para pasar'),
                    SizedBox(width: 10),
                    _StatCard(icon: Icons.help_outline_rounded, value: '10', label: 'preguntas'),
                  ],
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => _start(context, ref),
                  child: Container(
                    width: double.infinity,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFDD7A), AppColors.gold]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFD69400), offset: Offset(0, 6), blurRadius: 0),
                      ],
                    ),
                    child: const Text('EMPEZAR CHECKPOINT',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
                  ),
                ),
                const SizedBox(height: 11),
                const Text('No cuesta vidas · puedes reintentarlo cuando quieras',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            Text(label,
                style: const TextStyle(
                    fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
