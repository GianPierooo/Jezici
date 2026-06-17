import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../ui/primary_button.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

/// Crear cuenta (paso 11): email/contraseña vía Supabase Auth y persiste el plan
/// con create_plan. Reemplaza el sign-in anónimo del paso E.
class CreateAccountView extends ConsumerStatefulWidget {
  const CreateAccountView({
    super.key,
    required this.data,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onComplete,
  });

  final OnboardingData data;
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  ConsumerState<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends ConsumerState<CreateAccountView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final email = _email.text.trim();
    final pw = _password.text;
    if (!email.contains('@') || pw.length < 6) {
      setState(() => _error = 'Pon un email válido y una contraseña de 6+ caracteres.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(progressRepositoryProvider);
      final data = widget.data;
      await repo.signUpEmail(email, pw);
      final est = estimatePlan(
        currentLevel: data.currentLevel,
        goalLevel: data.goalLevel,
        dailyMinutes: data.dailyMinutes,
        daysPerWeek: data.daysPerWeek,
      );
      await repo.createPlan(
        coachStyle: data.coachStyle,
        intensity: data.intensity,
        currentLevel: data.currentLevel,
        goalLevel: data.goalLevel,
        dailyMinutes: data.dailyMinutes,
        daysPerWeek: data.daysPerWeek,
        motive: data.motive,
        deadline: data.deadline?.toIso8601String().split('T').first,
        estimatedHours: est.hoursNeeded,
        estimatedCompletion: est.completionDate.toIso8601String().split('T').first,
        skillLevels: data.skillLevels,
      );
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(userPlanProvider);
      if (!mounted) return;
      widget.onComplete();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No se pudo crear la cuenta. Prueba con otro email.';
      });
    }
  }

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google/Apple llegan pronto. Usa email por ahora.')),
      );

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      onBack: widget.onBack,
      title: 'Crea tu cuenta',
      subtitle: 'Para guardar tu plan y tu progreso.',
      footer: PrimaryButton(
        label: _loading ? 'CREANDO…' : 'CREAR CUENTA',
        expand: true,
        onPressed: _loading ? null : _create,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(_email, 'Email', Icons.mail_outline_rounded,
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field(_password, 'Contraseña', Icons.lock_outline_rounded, obscure: true),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(
                    color: AppColors.hearts, fontWeight: FontWeight.w800, fontSize: 12.5)),
          ],
          const SizedBox(height: 18),
          Row(children: [
            const Expanded(child: Divider(color: Color(0xFFE5E7F1), thickness: 1.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('o',
                  style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w900)),
            ),
            const Expanded(child: Divider(color: Color(0xFFE5E7F1), thickness: 1.5)),
          ]),
          const SizedBox(height: 14),
          _social('Continuar con Google', Icons.g_mobiledata_rounded),
          const SizedBox(height: 10),
          _social('Continuar con Apple', Icons.apple_rounded),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {bool obscure = false, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      enabled: !_loading,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _social(String label, IconData icon) {
    return GestureDetector(
      onTap: _soon,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7F1), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.text, size: 24),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}
