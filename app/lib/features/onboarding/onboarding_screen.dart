import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../legal/legal_screen.dart';
import '../../ui/primary_button.dart';
import 'create_account_view.dart';
import 'onboarding_data.dart';
import 'personality_test.dart';
import 'placement_test.dart';
import 'widgets/onboarding_scaffold.dart';
import 'your_plan_view.dart';

/// Flujo de onboarding (Estructura_App §2): 11 pasos hasta el mapa.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  /// Se llama cuando la cuenta queda creada y el plan persistido.
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _total = 11;
  final OnboardingData _data = OnboardingData();
  int _step = 0;

  void _next() => setState(() => _step++);
  void _back() => setState(() => _step = (_step - 1).clamp(0, _total - 1));

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
          subtitle: 'Personalizamos tu plan a tu objetivo.',
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
        return _select(
          title: '¿Cómo está tu inglés hoy?',
          subtitle: 'Lo confirmamos con un test rápido.',
          options: const [
            ('Soy principiante', 'A1', null),
            ('Sé lo básico', 'A2', null),
            ('Nivel intermedio', 'B1', null),
            ('Nivel avanzado', 'B2', null),
          ],
          current: _data.selfLevel,
          onSelect: (v) => _data.selfLevel = v,
          allowDefault: true,
        );
      case 4:
        return _select(
          title: '¿Cuánto tiempo al día?',
          subtitle: 'Tu meta diaria. Puedes cambiarla luego.',
          options: const [
            ('5 minutos', '5', null),
            ('10 minutos', '10', null),
            ('15 minutos', '15', null),
            ('20 minutos', '20', null),
            ('30 minutos', '30', null),
            ('45+ minutos', '45', null),
          ],
          current: '${_data.dailyMinutes}',
          onSelect: (v) => _data.dailyMinutes = int.parse(v),
          allowDefault: true,
        );
      case 5:
        return _select(
          title: '¿Con qué intensidad?',
          subtitle: 'Días por semana.',
          options: const [
            ('Relajado · 3 días', '3', Icons.spa_outlined),
            ('Constante · 5 días', '5', Icons.trending_up_rounded),
            ('Intenso · 7 días', '7', Icons.local_fire_department_outlined),
          ],
          current: '${_data.daysPerWeek}',
          onSelect: (v) => _data.daysPerWeek = int.parse(v),
          allowDefault: true,
        );
      case 6:
        return _goal();
      case 7:
        return PersonalityTest(
            data: _data, step: 8, total: _total, onBack: _back, onDone: _next);
      case 8:
        return PlacementTest(
            data: _data, step: 9, total: _total, onBack: _back, onDone: _next);
      case 9:
        return YourPlanView(
            data: _data, step: 10, total: _total, onBack: _back, onCreateAccount: _next);
      default:
        return CreateAccountView(
            data: _data, step: 11, total: _total, onBack: _back, onComplete: widget.onComplete);
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
              const Text('Aprende inglés de verdad',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              const Text(
                'Un plan con fecha real, examen que evalúa las 4 habilidades, y un coach que te trae de vuelta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4),
              ),
              const Spacer(),
              PrimaryButton(label: 'EMPEZAR', expand: true, onPressed: _next),
              const SizedBox(height: 12),
              const Text('Tu cuenta se crea al final, primero el valor.',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Al continuar aceptas los ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LegalScreen.terms())),
                    child: const Text('Términos',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ),
                  const Text(' y la ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LegalScreen.privacy())),
                    child: const Text('Privacidad',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _language() {
    return OnboardingScaffold(
      step: 2,
      total: _total,
      onBack: _back,
      title: '¿Qué quieres aprender?',
      subtitle: 'Por ahora: Inglés desde Español.',
      footer: PrimaryButton(label: 'CONTINUAR', expand: true, onPressed: _next),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingOption(
              label: '🇬🇧  Inglés', selected: true, onTap: () {}, trailing: 'objetivo'),
          OnboardingOption(
              label: '🇵🇹  Portugués', selected: false, onTap: _soon, trailing: 'pronto'),
          OnboardingOption(
              label: '🇫🇷  Francés', selected: false, onTap: _soon, trailing: 'pronto'),
          const SizedBox(height: 8),
          OnboardingOption(
              label: '🇪🇸  Español', selected: true, onTap: () {}, trailing: 'tu idioma'),
        ],
      ),
    );
  }

  Widget _goal() {
    return OnboardingScaffold(
      step: 7,
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

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Más idiomas llegan pronto. Arrancamos con Inglés.')),
      );
}
