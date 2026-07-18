import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../data/providers.dart';
import '../../ui/primary_button.dart';
import 'level_exam_player_screen.dart';

/// Intro del examen de nivel A1: explica las reglas y arranca el examen.
class LevelExamIntroScreen extends ConsumerStatefulWidget {
  const LevelExamIntroScreen({super.key});
  @override
  ConsumerState<LevelExamIntroScreen> createState() => _State();
}

class _State extends ConsumerState<LevelExamIntroScreen> {
  bool _loading = false;

  Future<void> _start() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(progressRepositoryProvider).startLevelExam();
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => LevelExamPlayerScreen(data: data)));
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).examStartError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // El nivel objetivo lo decide el servidor (A1, luego A2, …).
    final level = ref.watch(levelExamStatusProvider).value?.level ?? 'A1';
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: Text(l10n.examLevelTitle(level), style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 480,
          child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text('🎓', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              Text(l10n.examCertifyLevel(level),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 6),
              Text(
                l10n.examIntroDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
              ),
              const SizedBox(height: 22),
              _Bullet(icon: Icons.timer_outlined, text: l10n.examBulletTime),
              _Bullet(icon: Icons.insights_rounded, text: l10n.examBulletSkills),
              _Bullet(icon: Icons.verified_rounded, text: l10n.examBulletPass),
              _Bullet(icon: Icons.workspace_premium_rounded, text: l10n.examBulletCertificate(level)),
              const Spacer(),
              // Botón 3D de la casa (labio + hundido).
              PrimaryButton(
                label: _loading ? '…' : l10n.examStart,
                expand: true,
                onPressed: _loading ? null : _start,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 40, height: 40, alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text))),
      ]),
    );
  }
}
