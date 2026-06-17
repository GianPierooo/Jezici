import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/skills.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/practice_models.dart';
import '../../data/providers.dart';
import 'practice_player_screen.dart';

/// Pestaña PRACTICAR (Estructura_App): repaso espaciado, refuerzo de
/// debilidades, contrarreloj y práctica por habilidad. Da XP (menos que una
/// lección) y alimenta racha/meta. Todo el scoring es server-side.
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String? _loading; // modo que se está cargando

  // Fase 1 califica Lectura y Escritura (Listening/Speaking aún sin calificar).
  static const _gradableSkills = ['reading', 'writing'];

  Future<void> _start(String mode, {String? skill, int? timeLimit, required String title}) async {
    if (_loading != null) return;
    setState(() => _loading = mode + (skill ?? ''));
    try {
      final session =
          await ref.read(progressRepositoryProvider).startPractice(mode, skill: skill);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PracticePlayerScreen(
          mode: mode,
          title: title,
          items: session.items,
          timeLimitSec: timeLimit,
        ),
      ));
      ref.invalidate(practiceStatusProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('No se pudo iniciar la práctica.')));
      }
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  Future<void> _pickSkill() async {
    final skill = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Qué habilidad?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 4),
              const Text('En Fase 1 se califican Lectura y Escritura.',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 14),
              for (final s in _gradableSkills)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                      s == 'reading' ? Icons.menu_book_rounded : Icons.edit_rounded,
                      color: AppColors.primary),
                  title: Text(kSkillEs[s] ?? s,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => Navigator.pop(ctx, s),
                ),
            ],
          ),
        ),
      ),
    );
    if (skill != null) {
      await _start('skill', skill: skill, title: 'Práctica de ${kSkillEs[skill] ?? skill}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(practiceStatusProvider).value ?? PracticeStatus.empty;
    final weak = status.weakestSkill;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          const Text('Practicar',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 2),
          const Text('Refuerza lo aprendido. Suma XP (menos que una lección nueva).',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 18),
          _Card(
            emoji: '🔁',
            title: 'Rescate de palabras',
            subtitle: 'Repaso espaciado de tu vocabulario',
            badge: status.dueWords > 0 ? '${status.dueWords}' : null,
            loading: _loading == 'srs',
            color: AppColors.primary,
            onTap: () => _start('srs', title: 'Rescate de palabras'),
          ),
          _Card(
            emoji: '🎯',
            title: 'Refuerzo de debilidades',
            subtitle: weak != null
                ? 'Tu habilidad más débil: ${kSkillEs[weak] ?? weak}'
                : 'Trabaja tu punto flojo',
            loading: _loading == 'weakness',
            color: AppColors.coral,
            onTap: () => _start('weakness', title: 'Refuerzo de debilidades'),
          ),
          _Card(
            emoji: '⏱️',
            title: 'Contrarreloj',
            subtitle: 'Responde lo más que puedas en 60 s',
            loading: _loading == 'timed',
            color: AppColors.goldDark,
            onTap: () => _start('timed', timeLimit: 60, title: 'Contrarreloj'),
          ),
          _Card(
            emoji: '🛠️',
            title: 'Por habilidad',
            subtitle: 'Elige Lectura o Escritura',
            loading: _loading != null && _loading!.startsWith('skill'),
            color: AppColors.success,
            onTap: _pickSkill,
          ),
          // Simulacros IELTS/Cambridge: Fase 1 sin motor real → ocultos (GA6).
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
    this.loading = false,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(15)),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (loading)
                const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4))
              else if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
                  child: Text(badge!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                )
              else
                Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
