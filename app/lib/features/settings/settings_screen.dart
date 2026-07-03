import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../core/audio/music_controller.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/feedback/feedback_sheet.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/course_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../legal/legal_screen.dart';
import '../metrics/metrics_screen.dart';
import '../onboarding/course_placement_screen.dart';
import '../notifications/coach_styles.dart';
import '../notifications/matix_test_buttons.dart';
import '../premium/premium_screen.dart';

/// Ajustes (Estructura_App pantalla 24): recalibrar el estilo/intensidad de
/// Matix, definir la ventana de silencio (quiet_hours) y la meta diaria.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _minuteTiers = [5, 10, 15, 20, 30, 45];

  bool _init = false;
  bool _saving = false;

  late String _coach;
  late int _intensity;
  late bool _push;
  bool _quietOn = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);
  int _dailyMinutes = 10;

  void _seed(UserSettings s, int? planMinutes) {
    if (_init) return;
    _coach = s.coachStyle;
    _intensity = s.intensity;
    _push = s.pushEnabled;
    _quietOn = s.quietStart != null && s.quietEnd != null;
    if (s.quietStart != null) _quietStart = _parse(s.quietStart!, _quietStart);
    if (s.quietEnd != null) _quietEnd = _parse(s.quietEnd!, _quietEnd);
    _dailyMinutes = planMinutes ?? 10;
    _init = true;
  }

  TimeOfDay _parse(String hhmm, TimeOfDay fallback) {
    final p = hhmm.split(':');
    if (p.length < 2) return fallback;
    return TimeOfDay(hour: int.tryParse(p[0]) ?? 22, minute: int.tryParse(p[1]) ?? 0);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pick(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _quietStart : _quietEnd,
    );
    if (picked != null) {
      setState(() => start ? _quietStart = picked : _quietEnd = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(progressRepositoryProvider).updateSettings(
            coachStyle: _coach,
            intensity: _intensity,
            quietStart: _quietOn ? _fmt(_quietStart) : null,
            quietEnd: _quietOn ? _fmt(_quietEnd) : null,
            dailyMinutes: _dailyMinutes,
            pushEnabled: _push,
          );
      ref.invalidate(settingsProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(userPlanProvider);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text('Ajustes guardados ✓'),
        ));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No se pudieron guardar los ajustes.'),
        ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsProvider);
    final planMinutes = ref.watch(userPlanProvider).value?.dailyMinutes;

    // Sembrar el estado local SOLO con datos reales (no con el fallback de carga),
    // si no el selector se quedaría fijado en "Suave".
    if (settingsAsync.hasValue) _seed(settingsAsync.value!, planMinutes);

    if (!_init) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          foregroundColor: AppColors.text,
          title: const Text('Ajustes',
              style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final goalXp = _dailyMinutes < 10 ? 10 : _dailyMinutes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: const Text('Ajustes',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        actions: [
          IconButton(
            tooltip: 'Enviar feedback',
            icon: const Icon(Icons.feedback_outlined),
            onPressed: () => showFeedbackSheet(context, ref, screen: 'Ajustes'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 36),
        children: [
          // Idioma de la APP (chrome de la UI: es/en/pt). Distinto del idioma
          // del curso (lo que se aprende). Cambia la UI al instante.
          _section(l10n.settingsLanguageTitle, l10n.settingsLanguageSubtitle),
          _buildUiLangSwitcher(),
          const SizedBox(height: 18),

          // Idioma del curso (multi-curso: es→en / es→pt).
          _section('Idioma del curso', '¿Qué idioma quieres aprender?'),
          _buildCourseSwitcher(),
          const SizedBox(height: 18),

          // Estilo de coach.
          _section('Estilo de Matix', 'El tono de tus notificaciones.'),
          ...CoachStyle.all.map((s) => _CoachOption(
                style: s,
                selected: _coach == s.key,
                onTap: () => setState(() => _coach = s.key),
              )),
          const SizedBox(height: 18),

          // Intensidad.
          _section('Intensidad', '¿Cuánto insiste Matix?'),
          _SegmentRow(
            options: const ['Suave', 'Media', 'Alta'],
            index: (_intensity - 1).clamp(0, 2),
            onSelect: (i) => setState(() => _intensity = i + 1),
          ),
          const SizedBox(height: 18),

          // Meta diaria.
          _section('Meta diaria', 'Tu objetivo de XP por día: $goalXp XP.'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in _minuteTiers)
                      _Chip(
                        label: '$m min',
                        selected: _dailyMinutes == m,
                        onTap: () => setState(() => _dailyMinutes = m),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('≈ $goalXp XP/día (más minutos = meta más alta)',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Sonido (GA8).
          _section('Sonido', 'Efectos de las microinteracciones.'),
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  value: ref.watch(soundEnabledProvider),
                  onChanged: (v) => ref.read(soundEnabledProvider.notifier).set(v),
                  title: const Text('Efectos de sonido',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  value: ref.watch(musicEnabledProvider),
                  onChanged: (v) => ref.read(musicEnabledProvider.notifier).set(v),
                  title: const Text('Música del mapa',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                  subtitle: const Text('Loop ambiente suave en Aprender. Baja sola con los sonidos.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Notificaciones + quiet hours.
          _section('Notificaciones', 'Cuándo puede escribirte Matix.'),
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  value: _push,
                  onChanged: (v) => setState(() => _push = v),
                  title: const Text('Permitir notificaciones',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                ),
                const Divider(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  value: _quietOn,
                  onChanged: (v) => setState(() => _quietOn = v),
                  title: const Text('Horario de silencio',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                  subtitle: const Text('No molestar dentro de esta ventana',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                ),
                if (_quietOn) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _TimeField(label: 'Desde', value: _fmt(_quietStart), onTap: () => _pick(true))),
                      const SizedBox(width: 12),
                      Expanded(child: _TimeField(label: 'Hasta', value: _fmt(_quietEnd), onTap: () => _pick(false))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          PrimaryButton(
            label: _saving ? 'GUARDANDO…' : 'GUARDAR AJUSTES',
            expand: true,
            onPressed: _saving ? null : _save,
          ),
          const SizedBox(height: 26),

          // Premium (paywall, Fase 1: solo estructura).
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PremiumScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFF3D6), Color(0xFFFFFDF5)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(children: const [
                Text('👑', style: TextStyle(fontSize: 26)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Jezici Premium',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                    Text('Simulacros IELTS, vidas infinitas y más',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.goldDark),
              ]),
            ),
          ),
          const SizedBox(height: 22),

          // Probar el motor.
          _section('Probar a Matix', 'Simula un evento y mira el copy de tu estilo.'),
          const _Card(child: MatixTestButtons()),
          const SizedBox(height: 26),

          // Legal.
          _section('Legal', 'Cómo cuidamos tus datos.'),
          _Card(
            child: Column(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_rounded, color: AppColors.primary),
                title: const Text('Política de Privacidad',
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LegalScreen.privacy())),
              ),
              const Divider(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_rounded, color: AppColors.primary),
                title: const Text('Términos y Condiciones',
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LegalScreen.terms())),
              ),
            ]),
          ),
          const SizedBox(height: 22),

          // Métricas (interno).
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MetricsScreen())),
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: const Text('Ver métricas (interno)', style: TextStyle(fontWeight: FontWeight.w800)),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
          const SizedBox(height: 8),

          // Sesión.
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.w900)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.coral,
              side: const BorderSide(color: AppColors.coral),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _exportData,
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Exportar mis datos', style: TextStyle(fontWeight: FontWeight.w800)),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _deleteAccount,
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Borrar mi cuenta', style: TextStyle(fontWeight: FontWeight.w800)),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          // Sello de build (P0.5): qué bundle está corriendo (diagnóstico discreto).
          Center(
            child: Text(
              'Jezici ${buildLabel()}',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
    Map<String, dynamic>? data;
    try {
      data = await ref.read(progressRepositoryProvider).exportMyData();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pop(); // cierra el loading
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudieron exportar tus datos. Inténtalo de nuevo.')));
      return;
    }
    final json = const JsonEncoder.withIndent('  ').convert(data);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tus datos (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(json,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', height: 1.4)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (!ctx.mounted) return;
              ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Copiado al portapapeles')));
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar tu cuenta?'),
        content: const Text(
            'Esto elimina tu cuenta y TODO tu progreso (plan, niveles, certificados, racha) '
            'de forma permanente. No se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Borrar definitivamente'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(progressRepositoryProvider).deleteAccount();
      ref.invalidate(onboardingCompleteProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(userPlanProvider);
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo borrar la cuenta. Inténtalo de nuevo.')));
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tu progreso queda guardado en tu cuenta.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(progressRepositoryProvider).signOut();
    // Refrescar datos para el próximo usuario.
    ref.invalidate(homeStatsProvider);
    ref.invalidate(lessonProgressProvider);
    ref.invalidate(skillsProvider);
    ref.invalidate(userPlanProvider);
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  /// Selector del idioma de la APP (UI: es/en/pt). Cambia el locale al instante
  /// (MaterialApp escucha localeProvider). NO cambia el idioma del curso.
  Widget _buildUiLangSwitcher() {
    final current = ref.watch(localeProvider);
    return _Card(
      child: Column(
        children: [
          for (final code in supportedUiLangs)
            InkWell(
              onTap: () => ref.read(localeProvider.notifier).set(code),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        uiLangNames[code] ?? code,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: current == code ? AppColors.primary : AppColors.text,
                        ),
                      ),
                    ),
                    Icon(
                      current == code
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: current == code ? AppColors.primary : const Color(0xFFC9CDDD),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseSwitcher() {
    final coursesAsync = ref.watch(coursesProvider);
    return coursesAsync.when(
      loading: () => const _Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
            child: SizedBox(
                height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (courses) => _Card(
        child: Column(
          children: [
            for (final c in courses)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                title: Text(c.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppColors.text)),
                trailing: c.active
                    ? const Icon(Icons.check_circle, color: AppColors.success)
                    : const Icon(Icons.radio_button_unchecked,
                        color: AppColors.textMuted),
                onTap: c.active ? null : () => _switchCourse(c),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchCourse(CourseInfo c) async {
    final l10n = AppLocalizations.of(context);
    // Ofrece el test de ubicación del idioma meta (para no caer siempre en A1) o
    // empezar desde el principio. Cancelar no cambia nada.
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.coursePlacementOfferTitle),
        content: Text(l10n.coursePlacementOfferBody(c.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'scratch'),
            child: Text(l10n.coursePlacementFromScratch),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'test'),
            child: Text(l10n.coursePlacementDoTest),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    try {
      // Activa el curso (create_plan usa jz_active_course → hay que activarlo antes
      // del re-placement).
      await ref.read(progressRepositoryProvider).setActiveCourse(c.id);
      // Recarga lo que depende del curso activo. `coursesProvider` cascada a
      // `activeCourseIdProvider` → `mapUnitsProvider`.
      ref.invalidate(coursesProvider);
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(skillMasteryProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(levelExamStatusProvider);
      ref.invalidate(planTrackingProvider);
      ref.invalidate(userPlanProvider);

      if (choice == 'test' && mounted) {
        // Corre el placement del idioma meta y aplica nivel → unidad de entrada.
        final level = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => CoursePlacementScreen(courseId: c.id, courseLabel: c.label),
          ),
        );
        if (!mounted) return;
        ref.invalidate(coursesProvider);
        ref.invalidate(mapUnitsProvider);
        if (level != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.coursePlacementDone(level))),
          );
          return;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${c.flag}  ${c.label}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cambiar el curso.')),
        );
      }
    }
  }

  Widget _section(String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: child,
    );
  }
}

class _CoachOption extends StatelessWidget {
  const _CoachOption({required this.style, required this.selected, required this.onTap});
  final CoachStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? AppColors.navActiveBg : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE6E8F2),
              width: selected ? 2 : 1.4,
            ),
          ),
          child: Row(
            children: [
              Text(style.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(style.label,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                    Text(style.description,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(style.sample,
                        style: const TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({required this.options, required this.index, required this.onSelect});
  final List<String> options;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(options[i],
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: i == index ? Colors.white : AppColors.textMuted)),
                ),
              ),
            ),
        ],
      ),
    );
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF4F5FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.textMuted)),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5FB),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
              ],
            ),
            const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
