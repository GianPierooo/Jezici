import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../ui/primary_button.dart';
import 'onboarding_data.dart';
import 'personality_test.dart';
import 'placement_test.dart';
import 'widgets/onboarding_scaffold.dart';
import 'your_plan_view.dart';

/// Onboarding (GA4 · auth-first). La cuenta ya existe (pantalla de auth); aquí
/// SOLO se construye el plan y se personaliza. Cada paso cambia algo aguas abajo
/// (plan, contenido o coaching); nada redundante. 9 pasos:
///  0 bienvenida · 1 idioma de la app · 2 motivo · 3 meta+plazo ·
///  4 compromiso (min/día + días/sem en UNO) · 5 personalidad (4+1) ·
///  6 micro-arranque (siembra el placement) · 7 ubicación · 8 tu plan → mapa.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  /// Se llama cuando el plan queda persistido (onboarding_completed = true).
  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _total = 9;
  final OnboardingData _data = OnboardingData();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _logStep();
  }

  /// Analítica de drop-off por paso (GA4 · B7).
  void _logStep() =>
      ref.read(progressRepositoryProvider).logEvent('onboarding_step', props: {'step': _step});

  void _next() {
    setState(() => _step++);
    _logStep();
  }

  void _back() {
    setState(() => _step = (_step - 1).clamp(0, _total - 1));
    _logStep();
  }

  /// Último paso: persiste el plan (la cuenta ya existe) y entra al mapa.
  Future<void> _finish() async {
    try {
      final repo = ref.read(progressRepositoryProvider);
      final est = estimatePlan(
        currentLevel: _data.currentLevel,
        goalLevel: _data.goalLevel,
        dailyMinutes: _data.dailyMinutes,
        daysPerWeek: _data.daysPerWeek,
      );
      await repo.createPlan(
        coachStyle: _data.coachStyle,
        intensity: _data.intensity,
        currentLevel: _data.currentLevel,
        goalLevel: _data.goalLevel,
        dailyMinutes: _data.dailyMinutes,
        daysPerWeek: _data.daysPerWeek,
        motive: _data.motive,
        deadline: _data.deadline?.toIso8601String().split('T').first,
        estimatedHours: est.hoursNeeded,
        estimatedCompletion: est.completionDate.toIso8601String().split('T').first,
        skillLevels: _data.skillLevels,
      );
      await ref.read(localeProvider.notifier).set(_data.uiLang);
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(userPlanProvider);
      ref.read(progressRepositoryProvider).logEvent('onboarding_completed');
      if (!mounted) return;
      widget.onComplete();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('No se pudo guardar tu plan. Reinténtalo.')));
      rethrow; // YourPlanView resetea su estado de carga.
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0:
        return _welcome();
      case 1:
        return _language();
      case 2:
        return _select(
          title: '¿Por qué aprendes inglés?',
          subtitle: 'Personaliza tu plan, los escenarios y el coaching.',
          options: const [
            ('Trabajo', 'Trabajo', Icons.work_outline_rounded),
            ('Viajes', 'Viajes', Icons.flight_takeoff_rounded),
            ('Examen oficial', 'Examen', Icons.school_outlined),
            ('Estudios', 'Estudios', Icons.menu_book_rounded),
            ('Mudanza', 'Mudanza', Icons.home_outlined),
            ('Por placer', 'Placer', Icons.favorite_outline_rounded),
          ],
          current: _data.motive,
          onSelect: (v) => _data.motive = v,
        );
      case 3:
        return _goal();
      case 4:
        return _commitment();
      case 5:
        return PersonalityTest(
            data: _data, step: _step + 1, total: _total, onBack: _back, onDone: _next);
      case 6:
        return _select(
          title: '¿Cómo arrancas en inglés?',
          subtitle: 'Solo para empezar el test de ubicación en el punto justo.',
          options: const [
            ('Desde cero', '0', Icons.flag_outlined),
            ('Sé lo básico', '1', Icons.trending_up_rounded),
            ('Tengo buen nivel', '2', Icons.star_outline_rounded),
          ],
          current: '${_data.startLevelHint}',
          onSelect: (v) => _data.startLevelHint = int.parse(v),
          allowDefault: true,
        );
      case 7:
        return PlacementTest(
            data: _data,
            step: _step + 1,
            total: _total,
            startLevel: _data.startLevelHint,
            onBack: _back,
            onDone: _next);
      default:
        return YourPlanView(
            data: _data, step: _total, total: _total, onBack: _back, onFinish: _finish);
    }
  }

  // ── Pasos simples de selección ────────────────────────────────────────────
  Widget _select({
    required String title,
    String? subtitle,
    required List<(String, String, IconData?)> options,
    required String current,
    required void Function(String) onSelect,
    bool allowDefault = false,
  }) {
    final hasSelection = current.isNotEmpty;
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: title,
      subtitle: subtitle,
      footer: PrimaryButton(
        label: 'CONTINUAR',
        expand: true,
        onPressed: (hasSelection || allowDefault) ? _next : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (label, value, icon) in options)
            OnboardingOption(
              label: label,
              icon: icon,
              selected: current == value,
              onTap: () => setState(() => onSelect(value)),
            ),
        ],
      ),
    );
  }

  Widget _welcome() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const Text('🦜', style: TextStyle(fontSize: 96)),
              const SizedBox(height: 20),
              const Text('Construyamos tu plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              const Text(
                'Unas preguntas rápidas y un test de nivel para armar tu plan con fecha real. '
                'Cada respuesta personaliza tu camino.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4),
              ),
              const Spacer(),
              PrimaryButton(label: 'EMPEZAR', expand: true, onPressed: _next),
              const SizedBox(height: 12),
              const Text('Toma ~2 minutos.',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _language() {
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: '¿En qué idioma quieres la app?',
      subtitle: 'Aprenderás inglés; este es el idioma de la interfaz.',
      footer: PrimaryButton(label: 'CONTINUAR', expand: true, onPressed: _next),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (label, code) in const [
            ('🇪🇸  Español', 'es'),
            ('🇬🇧  English', 'en'),
            ('🇧🇷  Português', 'pt'),
          ])
            OnboardingOption(
              label: label,
              selected: _data.uiLang == code,
              onTap: () => setState(() => _data.uiLang = code),
            ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.translate_rounded, color: AppColors.textMuted, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('Idioma objetivo del curso: Inglés (Fase 1).',
                    style: TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goal() {
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: '¿A dónde quieres llegar?',
      subtitle: 'Tu meta. La cima del mapa.',
      footer: PrimaryButton(label: 'CONTINUAR', expand: true, onPressed: _next),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (label, value) in const [
            ('A2 · Superviviente', 'A2'),
            ('B1 · Independiente', 'B1'),
            ('B2 · Conversador fluido', 'B2'),
            ('C1 · Avanzado', 'C1'),
          ])
            OnboardingOption(
              label: label,
              selected: _data.goalLevel == value,
              onTap: () => setState(() => _data.goalLevel = value),
            ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDeadline,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7F1), width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, color: AppColors.textMuted, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _data.deadline == null
                          ? 'Fecha límite (opcional)'
                          : 'Meta: ${_data.deadline!.day}/${_data.deadline!.month}/${_data.deadline!.year}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _data.deadline == null ? AppColors.textMuted : AppColors.primary,
                      ),
                    ),
                  ),
                  if (_data.deadline != null)
                    GestureDetector(
                      onTap: () => setState(() => _data.deadline = null),
                      child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Compromiso UNIFICADO: minutos/día + días/semana en una sola pantalla ────
  Widget _commitment() {
    const minutes = [5, 10, 15, 20, 30, 45];
    const days = [(3, 'Relajado'), (5, 'Constante'), (7, 'Intenso')];
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: '¿Cuánto puedes dedicar?',
      subtitle: 'Esto fija tu meta diaria y la fecha de llegada.',
      footer: PrimaryButton(label: 'CONTINUAR', expand: true, onPressed: _next),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GroupLabel('Minutos al día'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final m in minutes)
                _Chip(
                  label: '$m min',
                  selected: _data.dailyMinutes == m,
                  onTap: () => setState(() => _data.dailyMinutes = m),
                ),
            ],
          ),
          const SizedBox(height: 22),
          const _GroupLabel('Días por semana'),
          const SizedBox(height: 10),
          Column(
            children: [
              for (final (d, tag) in days)
                OnboardingOption(
                  label: '$tag · $d días',
                  selected: _data.daysPerWeek == d,
                  onTap: () => setState(() => _data.daysPerWeek = d),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 180)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _data.deadline = picked);
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E7F1), width: 2),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.text)),
      ),
    );
  }
}
