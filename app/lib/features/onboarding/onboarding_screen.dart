import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/learn_lang_names.dart';
import '../../core/i18n/locale_controller.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/course_models.dart';
import '../../data/providers.dart';
import '../../ui/primary_button.dart';
import 'onboarding_data.dart';
import 'personality_test.dart';
import 'placement_result_view.dart';
import 'placement_test.dart';
import 'widgets/onboarding_scaffold.dart';
import 'your_plan_view.dart';

/// Onboarding (GA4 · auth-first). La cuenta ya existe (pantalla de auth); aquí
/// SOLO se construye el plan y se personaliza. Cada paso cambia algo aguas abajo
/// (plan, contenido o coaching); nada redundante. Pasos:
///  0 bienvenida · 1 idioma de la app · 2 NOMBRE (se persiste en Perfil) ·
///  3 idioma META (qué se aprende) · 4 motivo · 5 meta+plazo · 6 compromiso ·
///  7 personalidad (4+1) · 8 micro-arranque · 9 ubicación (banco del curso META) ·
///  10 resultado · 11 tu plan → mapa.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  /// Se llama cuando el plan queda persistido (onboarding_completed = true).
  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _total = 12;
  final OnboardingData _data = OnboardingData();
  final TextEditingController _nameCtrl = TextEditingController();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _logStep();
    _prefillName();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  /// Pre-rellena el nombre: primero el metadata de Google (OAuth, síncrono), luego
  /// el perfil ya guardado (alta por email lo fijó). Solo autocompleta si el campo
  /// sigue vacío (no pisa lo que el usuario escriba).
  Future<void> _prefillName() async {
    final repo = ref.read(progressRepositoryProvider);
    try {
      final metaName = repo.authMetadataName;
      if (metaName != null && _nameCtrl.text.isEmpty) {
        _nameCtrl.text = metaName;
        _data.name = metaName;
      }
    } catch (_) {}
    try {
      final p = await repo.fetchProfile();
      final saved = p.name?.trim();
      if (saved != null && saved.isNotEmpty && _nameCtrl.text.isEmpty && mounted) {
        setState(() {
          _nameCtrl.text = saved;
          _data.name = saved;
        });
      }
    } catch (_) {}
  }

  /// Analítica de drop-off por paso (GA4 · B7).
  void _logStep() =>
      ref.read(progressRepositoryProvider).logEvent('onboarding_step', props: {'step': _step});

  // Pasos: 8 = nivel de arranque · 9 = ubicación · 10 = resultado · 11 = plan.
  static const _stepStartLevel = 8;
  static const _stepPlan = 11;

  /// "Empezar desde cero" (startLevelHint == 0) → SALTA el examen: el usuario ya
  /// declaró que es principiante, no tiene sentido examinarlo. Va directo a A1/U1.
  bool get _skipPlacement => _data.startLevelHint == 0;

  void _next() {
    // Al salir del paso de nivel de arranque: si eligió "desde cero", salta la
    // ubicación (8) y el resultado (9) → plan (10) con nivel A1 fijado.
    if (_step == _stepStartLevel && _skipPlacement) {
      _data.placementLevel = 'A1';
      _data.skillLevels = {
        'reading': 'A1',
        'listening': 'A1',
        'writing': 'A1',
        'speaking': 'A1',
      };
      setState(() => _step = _stepPlan);
      _logStep();
      return;
    }
    setState(() => _step++);
    _logStep();
  }

  void _back() {
    // Desde el plan, si se saltó la ubicación, vuelve al paso de nivel de arranque.
    final target =
        (_step == _stepPlan && _skipPlacement) ? _stepStartLevel : _step - 1;
    setState(() => _step = target.clamp(0, _total - 1));
    _logStep();
  }

  /// Último paso: persiste el plan (la cuenta ya existe) y entra al mapa.
  Future<void> _finish() async {
    try {
      final repo = ref.read(progressRepositoryProvider);
      // Persiste el nombre (safety idempotente; ya se intentó al salir del paso).
      final nm = _data.name.trim();
      if (nm.isNotEmpty) {
        try {
          await repo.setProfile(name: nm);
        } catch (_) {}
      }
      // Asegura que el curso ACTIVO sea el META elegido antes de create_plan
      // (que usa jz_active_course). Idempotente; robustez si el pick falló.
      if (_data.targetCourseId != null) {
        try {
          await repo.setActiveCourse(_data.targetCourseId!);
        } catch (_) {}
      }
      final est = estimatePlan(
        currentLevel: _data.currentLevel,
        goalLevel: _data.goalLevel,
        dailyMinutes: _data.dailyMinutes,
        daysPerWeek: _data.daysPerWeek,
        maxLevel: _data.targetMaxLevel,
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
      // El curso activo puede haber cambiado (idioma META) → recarga lo course-scoped.
      ref.invalidate(coursesProvider);
      ref.invalidate(mapUnitsProvider);
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(skillMasteryProvider);
      ref.invalidate(userPlanProvider);
      ref.read(progressRepositoryProvider).logEvent('onboarding_completed');
      if (!mounted) return;
      widget.onComplete();
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.onbSaveError)));
      // No relanzamos: YourPlanView resetea su carga en su finally y relanzar
      // generaría un error async sin capturar.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final courseName = learnLangName(l10n, _data.targetCourseCode);
    switch (_step) {
      case 0:
        return _welcome();
      case 1:
        return _language();
      case 2:
        return _nameStep();
      case 3:
        return _targetLanguage();
      case 4:
        return _select(
          title: l10n.onbMotiveTitle(courseName),
          subtitle: l10n.onbMotiveSubtitle,
          options: [
            (l10n.onbMotiveWork, 'Trabajo', Icons.work_outline_rounded),
            (l10n.onbMotiveTravel, 'Viajes', Icons.flight_takeoff_rounded),
            (l10n.onbMotiveExam, 'Examen', Icons.school_outlined),
            (l10n.onbMotiveStudies, 'Estudios', Icons.menu_book_rounded),
            (l10n.onbMotiveRelocation, 'Mudanza', Icons.home_outlined),
            (l10n.onbMotivePleasure, 'Placer', Icons.favorite_outline_rounded),
          ],
          current: _data.motive,
          onSelect: (v) => _data.motive = v,
        );
      case 5:
        return _goal();
      case 6:
        return _commitment();
      case 7:
        return PersonalityTest(
            data: _data, step: _step + 1, total: _total, onBack: _back, onDone: _next);
      case 8:
        return _select(
          title: l10n.onbStartLevelTitle(courseName),
          subtitle: l10n.onbStartLevelSubtitle,
          options: [
            (l10n.onbStartLevelZero, '0', Icons.flag_outlined),
            (l10n.onbStartLevelBasic, '1', Icons.trending_up_rounded),
            (l10n.onbStartLevelGood, '2', Icons.star_outline_rounded),
          ],
          current: '${_data.startLevelHint}',
          onSelect: (v) => _data.startLevelHint = int.parse(v),
          allowDefault: true,
        );
      case 9:
        // Ubicación sobre el BANCO del curso META elegido (placement_next(courseId)).
        return PlacementTest(
            data: _data,
            step: _step + 1,
            total: _total,
            startLevel: _data.startLevelHint,
            courseId: _data.targetCourseId,
            onBack: _back,
            onDone: _next);
      case 10:
        // RESULTADO del placement (momento "¡saliste en B1!"): nivel + skills + a
        // qué unidad entra + fecha realista. No es aprobar/reprobar: es ubicación.
        return PlacementResultView(
            data: _data, step: _step + 1, total: _total, onBack: _back, onContinue: _next);
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
    final l10n = AppLocalizations.of(context);
    final hasSelection = current.isNotEmpty;
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: title,
      subtitle: subtitle,
      footer: PrimaryButton(
        label: l10n.commonContinue,
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const ParrotMascot(size: 96),
              const SizedBox(height: 20),
              Text(l10n.onbWelcomeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              Text(
                l10n.onbWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4),
              ),
              const Spacer(),
              PrimaryButton(label: l10n.commonStart, expand: true, onPressed: _next),
              const SizedBox(height: 12),
              Text(l10n.onbWelcomeNote,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _language() {
    final l10n = AppLocalizations.of(context);
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: l10n.onbLanguageTitle,
      subtitle: l10n.onbLanguageSubtitle,
      footer: PrimaryButton(label: l10n.commonContinue, expand: true, onPressed: _next),
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
              onTap: () {
                setState(() => _data.uiLang = code);
                ref.read(localeProvider.notifier).set(code);
              },
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.translate_rounded, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.onbLanguageInfoEn,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Nombre real: se muestra en Perfil / saludos / certificado ──────────────
  // Se pide ANTES del examen (correctitud: hoy el alta por Google nunca lo pedía).
  Widget _nameStep() {
    final l10n = AppLocalizations.of(context);
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: l10n.onbNameTitle,
      subtitle: l10n.onbNameSubtitle,
      footer: PrimaryButton(
        label: l10n.commonContinue,
        expand: true,
        onPressed: _nameCtrl.text.trim().isNotEmpty ? _continueName : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 40,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_nameCtrl.text.trim().isNotEmpty) _continueName();
            },
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
            decoration: InputDecoration(
              hintText: l10n.onbNameHint,
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Guarda el nombre (set_profile) y avanza. Degrada con gracia: si la escritura
  /// falla (offline), continúa igual — se reintenta en _finish (idempotente).
  Future<void> _continueName() async {
    final n = _nameCtrl.text.trim();
    _data.name = n;
    if (n.isNotEmpty) {
      try {
        await ref.read(progressRepositoryProvider).setProfile(name: n);
      } catch (_) {}
    }
    _next();
  }

  // ── Idioma META: QUÉ se aprende (distinto del idioma de la app) ─────────────
  Widget _targetLanguage() {
    final l10n = AppLocalizations.of(context);
    final coursesAsync = ref.watch(coursesProvider);
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: l10n.onbTargetTitle,
      subtitle: l10n.onbTargetSubtitle,
      footer: PrimaryButton(
        label: l10n.commonContinue,
        expand: true,
        onPressed: _data.targetCourseId != null ? _next : null,
      ),
      child: coursesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        error: (_, _) => Text(l10n.onbSaveError,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        data: (courses) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final c in courses)
              OnboardingOption(
                label: '${c.flag}  ${learnLangName(l10n, c.target)}',
                selected: _data.targetCourseId == c.id,
                onTap: () => _pickTarget(c),
              ),
          ],
        ),
      ),
    );
  }

  /// Fija el curso META y lo activa server-side (set_active_course) → el placement
  /// (paso 8) y create_plan (final) usan ESE curso. Idempotente; degrada con gracia.
  Future<void> _pickTarget(CourseInfo c) async {
    setState(() {
      _data.targetCourseId = c.id;
      _data.targetCourseCode = c.target;
      _data.targetMaxLevel = c.maxLevel;
      // Capa la meta al tope real del curso (p. ej. it topa en A2: la meta B1 por
      // defecto pasa a A2). Evita prometer un nivel sin contenido.
      if (CefrTable.rank(_data.goalLevel) > CefrTable.rank(c.maxLevel)) {
        _data.goalLevel = c.maxLevel;
      }
    });
    try {
      await ref.read(progressRepositoryProvider).setActiveCourse(c.id);
    } catch (_) {
      // Se reintenta en _finish antes de create_plan.
    }
  }

  /// Nivel CEFR más alto CON contenido del curso META elegido (para capar la meta).
  String _targetMaxLevel() {
    final courses = ref
        .watch(coursesProvider)
        .maybeWhen(data: (v) => v, orElse: () => const <CourseInfo>[]);
    var maxLvl = 'C1';
    for (final c in courses) {
      if (c.id == _data.targetCourseId) maxLvl = c.maxLevel;
    }
    return maxLvl;
  }

  Widget _goal() {
    final l10n = AppLocalizations.of(context);
    final maxRank = CefrTable.rank(_targetMaxLevel());
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: l10n.onbGoalTitle,
      subtitle: l10n.onbGoalSubtitle,
      footer: PrimaryButton(label: l10n.commonContinue, expand: true, onPressed: _next),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Solo metas ALCANZABLES: no ofrecer un nivel por encima del tope real del curso.
          for (final (label, value) in [
            (l10n.onbGoalA2, 'A2'),
            (l10n.onbGoalB1, 'B1'),
            (l10n.onbGoalB2, 'B2'),
            (l10n.onbGoalC1, 'C1'),
          ].where((o) => CefrTable.rank(o.$2) <= maxRank))
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
                          ? l10n.onbDeadlineEmpty
                          : l10n.onbDeadlineFilled(_data.deadline!.day, _data.deadline!.month,
                              _data.deadline!.year),
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
    final l10n = AppLocalizations.of(context);
    const minutes = [5, 10, 15, 20, 30, 45];
    final days = [
      (3, l10n.onbFrequencyRelaxed),
      (5, l10n.onbFrequencyConstant),
      (7, l10n.onbFrequencyIntense),
    ];
    return OnboardingScaffold(
      step: _step + 1,
      total: _total,
      onBack: _back,
      title: l10n.onbCommitmentTitle,
      subtitle: l10n.onbCommitmentSubtitle,
      footer: PrimaryButton(label: l10n.commonContinue, expand: true, onPressed: _next),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupLabel(l10n.onbCommitmentMinutesLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final m in minutes)
                _Chip(
                  label: l10n.onbMinutesShort(m),
                  selected: _data.dailyMinutes == m,
                  onTap: () => setState(() => _data.dailyMinutes = m),
                ),
            ],
          ),
          const SizedBox(height: 22),
          _GroupLabel(l10n.onbCommitmentDaysLabel),
          const SizedBox(height: 10),
          Column(
            children: [
              for (final (d, tag) in days)
                OnboardingOption(
                  label: '$tag · ${l10n.onbDaysShort(d)}',
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
