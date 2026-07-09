import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../core/audio/music_controller.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/feedback/feedback_sheet.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/prefs/notify_prefs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/course_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/edit_profile_sheet.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../legal/legal_screen.dart';
import '../metrics/metrics_screen.dart';
import '../notifications/coach_styles.dart';
import '../notifications/matix_test_buttons.dart';
import '../onboarding/course_placement_screen.dart';
import '../premium/premium_screen.dart';

const _kDivider = Color(0xFFF2F3F8);
const _kChevron = Color(0xFFC2C6D6);
const _kSubtle = Color(0xFF9A9FB8);

/// Ajustes (fiel a Ajustes.dc): secciones con micro-headers, icon-tiles por
/// fila, toggles verdes custom y el loro Matix con burbuja de preview del tono.
/// Capa visual + estructura: la lógica de settings/personalidad/economía no
/// cambia. Guardado IMPLÍCITO (como el mockup): cualquier cambio server-backed
/// llama a `_save()` en silencio; las prefs locales (sonido/música/vibración/
/// recordatorios) se persisten al instante en el dispositivo.
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
  bool _quietOn = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);
  int _dailyMinutes = 10;

  void _seed(UserSettings s, int? planMinutes) {
    if (_init) return;
    _coach = s.coachStyle;
    _intensity = s.intensity;
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

  /// Guardado silencioso en servidor. El maestro `push_enabled` real se DERIVA
  /// de las dos preferencias granulares (recordatorio diario / aviso de racha):
  /// si el usuario apaga ambas, Matix deja de empujar (preferencia respetada).
  Future<void> _save() async {
    if (_saving) return;
    _saving = true;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final push =
        ref.read(dailyReminderProvider) || ref.read(streakAlertProvider);
    try {
      await ref.read(progressRepositoryProvider).updateSettings(
            coachStyle: _coach,
            intensity: _intensity,
            quietStart: _quietOn ? _fmt(_quietStart) : null,
            quietEnd: _quietOn ? _fmt(_quietEnd) : null,
            dailyMinutes: _dailyMinutes,
            pushEnabled: push,
          );
      ref.invalidate(settingsProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(userPlanProvider);
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.settingsSaveError),
        ));
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsProvider);
    final planMinutes = ref.watch(userPlanProvider).value?.dailyMinutes;

    if (settingsAsync.hasValue) _seed(settingsAsync.value!, planMinutes);

    if (!_init) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(l10n),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final goalXp = _dailyMinutes < 10 ? 10 : _dailyMinutes;
    final plan = ref.watch(userPlanProvider).value;
    final courses = ref.watch(coursesProvider).value;
    final active = courses == null || courses.isEmpty
        ? null
        : courses.firstWhere((c) => c.active, orElse: () => courses.first);
    final uiLang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar(l10n),
      body: ResponsiveCenter(
        maxWidth: 480,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          children: [
            // ===== IDIOMA =====
            _header(l10n.settingsSecLanguage),
            _group([
              _tile(
                tileBg: AppColors.navActiveBg,
                icon: Text(active?.flag ?? '🌐', style: const TextStyle(fontSize: 18)),
                title: l10n.settingsLearns,
                subtitle: active == null
                    ? null
                    : l10n.settingsLearnsSub(active.targetName, plan?.goalLevel ?? 'B1'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(l10n.settingsChange,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w900, color: _kSubtle)),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: _kChevron, size: 20),
                ]),
                onTap: () => _openCoursePicker(courses ?? const []),
              ),
              _tile(
                tileBg: AppColors.navActiveBg,
                icon: const Icon(Icons.public_rounded, color: AppColors.primary, size: 19),
                title: l10n.settingsAppLanguageRow,
                subtitle: uiLangNames[uiLang] ?? uiLang,
                trailing: const Icon(Icons.chevron_right_rounded, color: _kChevron, size: 20),
                onTap: () => _openAppLangPicker(uiLang),
              ),
            ]),

            // ===== NOTIFICACIONES =====
            _header(l10n.settingsSecNotifications),
            _coachCard(l10n),
            const SizedBox(height: 14),
            _group([
              _tile(
                tileBg: const Color(0xFFEAF0FF),
                icon: const Icon(Icons.nightlight_round, color: Color(0xFF4A8CFF), size: 18),
                title: l10n.settingsQuiet,
                subtitle: l10n.settingsQuietSub,
                trailing: _quietOn
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        _pill(_fmt(_quietStart)),
                        const SizedBox(width: 5),
                        Text(l10n.settingsQuietTo.toLowerCase(),
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800, color: _kSubtle)),
                        const SizedBox(width: 5),
                        _pill(_fmt(_quietEnd)),
                      ])
                    : Text(l10n.settingsQuietOff,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w900, color: _kSubtle)),
                onTap: () => _openQuietSheet(l10n),
              ),
            ]),

            // ===== META Y RECORDATORIOS =====
            _header(l10n.settingsSecGoal),
            _group([
              _tile(
                tileBg: const Color(0xFFFFF4D6),
                icon: const Icon(Icons.bolt_rounded, color: Color(0xFFE09A00), size: 19),
                title: l10n.settingsMeta,
                subtitle: l10n.settingsMetaSub(_dailyMinutes, goalXp),
                trailing: const Icon(Icons.chevron_right_rounded, color: _kChevron, size: 20),
                onTap: () => _openMetaSheet(l10n),
              ),
              _tile(
                tileBg: AppColors.navActiveBg,
                icon: const Icon(Icons.notifications_active_rounded,
                    color: AppColors.primary, size: 18),
                title: l10n.settingsDailyReminder,
                subtitle: l10n.settingsDailyReminderSub,
                trailing: _GreenToggle(
                  value: ref.watch(dailyReminderProvider),
                  onChanged: (v) {
                    ref.read(dailyReminderProvider.notifier).set(v);
                    _save();
                  },
                ),
              ),
              _tile(
                tileBg: const Color(0xFFFFF1E3),
                icon: const Icon(Icons.local_fire_department_rounded,
                    color: Color(0xFFFF7A00), size: 19),
                title: l10n.settingsStreakAlert,
                subtitle: l10n.settingsStreakAlertSub,
                trailing: _GreenToggle(
                  value: ref.watch(streakAlertProvider),
                  onChanged: (v) {
                    ref.read(streakAlertProvider.notifier).set(v);
                    _save();
                  },
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 6, bottom: 4),
              child: Text(l10n.settingsReminderNote,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: _kSubtle)),
            ),
            const SizedBox(height: 12),

            // ===== CUENTA =====
            _header(l10n.settingsSecAccount),
            _group([
              _tile(
                tileBg: AppColors.navActiveBg,
                icon: const Icon(Icons.person_rounded, color: AppColors.primary, size: 19),
                title: l10n.settingsEditProfile,
                trailing: const Icon(Icons.chevron_right_rounded, color: _kChevron, size: 20),
                onTap: _openEditProfile,
              ),
              _tile(
                tileBg: const Color(0xFFFFF4D6),
                icon: const Icon(Icons.workspace_premium_rounded,
                    color: Color(0xFFF4B400), size: 19),
                title: l10n.settingsSubscription,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFDD7A), Color(0xFFF4B400)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l10n.settingsPlanFree,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF5B3A00))),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: _kChevron, size: 20),
                ]),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
              ),
              _tile(
                tileBg: const Color(0xFFFFEFEF),
                icon: const Icon(Icons.logout_rounded, color: AppColors.coral, size: 18),
                title: l10n.settingsLogout,
                titleColor: AppColors.coral,
                onTap: _logout,
              ),
            ]),

            // ===== OTROS =====
            _header(l10n.settingsSecOther),
            _group([
              _tile(
                tileBg: const Color(0xFFE7F9EF),
                icon: const Icon(Icons.volume_up_rounded, color: AppColors.success, size: 19),
                title: l10n.settingsSounds,
                trailing: _GreenToggle(
                  value: ref.watch(soundEnabledProvider),
                  onChanged: (v) => ref.read(soundEnabledProvider.notifier).set(v),
                ),
              ),
              _tile(
                tileBg: AppColors.navActiveBg,
                icon: const Icon(Icons.music_note_rounded, color: AppColors.primary, size: 19),
                title: l10n.settingsMusic,
                subtitle: l10n.settingsMusicSub,
                trailing: _GreenToggle(
                  value: ref.watch(musicEnabledProvider),
                  onChanged: (v) => ref.read(musicEnabledProvider.notifier).set(v),
                ),
              ),
              _tile(
                tileBg: AppColors.navActiveBg,
                icon: const Icon(Icons.vibration_rounded, color: AppColors.primary, size: 19),
                title: l10n.settingsVibration,
                trailing: _GreenToggle(
                  value: ref.watch(vibrationEnabledProvider),
                  onChanged: (v) => ref.read(vibrationEnabledProvider.notifier).set(v),
                ),
              ),
              _tile(
                tileBg: const Color(0xFFEEF0F6),
                icon: const Icon(Icons.shield_rounded, color: Color(0xFF7A809B), size: 19),
                title: l10n.settingsPrivacy,
                trailing: const Icon(Icons.chevron_right_rounded, color: _kChevron, size: 20),
                onTap: () => _openLegalSheet(l10n),
              ),
            ]),

            // ===== AVANZADO (interno / GDPR) =====
            _header(l10n.settingsSecAdvanced),
            const _Group(padding: EdgeInsets.all(14), children: [MatixTestButtons()]),
            const SizedBox(height: 10),
            _quietTextButton(
              icon: Icons.bar_chart_rounded,
              label: l10n.settingsMetrics,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const MetricsScreen())),
            ),
            _quietTextButton(
              icon: Icons.download_rounded,
              label: l10n.settingsExport,
              onTap: _exportData,
            ),
            _quietTextButton(
              icon: Icons.delete_forever_rounded,
              label: l10n.settingsDelete,
              onTap: _deleteAccount,
            ),
            const SizedBox(height: 16),

            Center(
              child: Text('Jezici · ${buildLabel()}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFA7ABC3))),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(AppLocalizations l10n) => AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text(l10n.settingsTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        actions: [
          IconButton(
            tooltip: 'Feedback',
            icon: const Icon(Icons.feedback_outlined),
            onPressed: () => showFeedbackSheet(context, ref, screen: 'Ajustes'),
          ),
        ],
      );

  // ---- Micro-header de sección ----
  Widget _header(String text) => Padding(
        padding: const EdgeInsets.only(left: 6, top: 20, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Color(0xFF9097AE))),
      );

  // ---- Card blanca con divisores automáticos entre filas ----
  Widget _group(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(const Divider(height: 1.5, thickness: 1.5, color: _kDivider));
      }
    }
    return _Group(children: children);
  }

  // ---- Fila con icon-tile + título/subtítulo + trailing ----
  Widget _tile({
    required Color tileBg,
    required Widget icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color titleColor = AppColors.text,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tileBg, borderRadius: BorderRadius.circular(11)),
              child: icon,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: titleColor)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w800, color: _kSubtle)),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
            color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(9)),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
      );

  Widget _quietTextButton(
          {required IconData icon, required String label, required VoidCallback onTap}) =>
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
        ),
      );

  // ---- Card de coach: loro + burbuja de preview + 4 opciones + intensidad ----
  Widget _coachCard(AppLocalizations l10n) {
    return _Group(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(l10n.settingsCoachIntensity,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 44,
                child: ParrotMascot(size: 40, mood: MascotMood.idle),
              ),
              const SizedBox(width: 10),
              Expanded(child: _coachBubble(_coachExample(l10n, _coach))),
            ],
          ),
          const SizedBox(height: 14),
          for (final s in CoachStyle.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CoachRadioRow(
                name: _coachName(l10n, s.key),
                selected: _coach == s.key,
                onTap: () {
                  setState(() => _coach = s.key);
                  _save();
                },
              ),
            ),
          const SizedBox(height: 6),
          Text(l10n.settingsCoachInsist,
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: _kSubtle)),
          const SizedBox(height: 8),
          _SegmentRow(
            options: [l10n.settingsIntensityLow, l10n.settingsIntensityMid, l10n.settingsIntensityHigh],
            index: (_intensity - 1).clamp(0, 2),
            onSelect: (i) {
              setState(() => _intensity = i + 1);
              _save();
            },
          ),
          ],
        ),
      ],
    );
  }

  Widget _coachBubble(String text) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F2FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
                bottomRight: Radius.circular(13),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
          Positioned(
            left: -5,
            bottom: 9,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(width: 11, height: 11, color: const Color(0xFFF4F2FF)),
            ),
          ),
        ],
      );

  String _coachName(AppLocalizations l10n, String key) => switch (key) {
        'mano_dura' => l10n.coachNameManoDura,
        'positivo' => l10n.coachNamePositivo,
        'rezago' => l10n.coachNameRezago,
        _ => l10n.coachNameSuave,
      };

  String _coachExample(AppLocalizations l10n, String key) => switch (key) {
        'mano_dura' => l10n.coachExManoDura,
        'positivo' => l10n.coachExPositivo,
        'rezago' => l10n.coachExRezago,
        _ => l10n.coachExSuave,
      };

  // ---- Sheets ----
  Future<void> _openAppLangPicker(String current) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return _sheet(l10n.settingsChooseAppLang, [
          for (final code in supportedUiLangs)
            _radioRow(
              label: uiLangNames[code] ?? code,
              selected: current == code,
              onTap: () {
                ref.read(localeProvider.notifier).set(code);
                Navigator.pop(ctx);
              },
            ),
        ]);
      },
    );
  }

  Future<void> _openCoursePicker(List<CourseInfo> courses) async {
    if (courses.isEmpty) return;
    final chosen = await showModalBottomSheet<CourseInfo>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return _sheet(l10n.settingsChooseCourse, [
          for (final c in courses)
            InkWell(
              onTap: c.active ? () => Navigator.pop(ctx) : () => Navigator.pop(ctx, c),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Row(children: [
                  Text(c.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(c.targetName,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: c.active ? AppColors.primary : AppColors.text)),
                  ),
                  Icon(
                    c.active
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: c.active ? AppColors.success : const Color(0xFFC9CDDD),
                    size: 22,
                  ),
                ]),
              ),
            ),
        ]);
      },
    );
    if (chosen != null && mounted) await _switchCourse(chosen);
  }

  Future<void> _openMetaSheet(AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final goalXp = _dailyMinutes < 10 ? 10 : _dailyMinutes;
          return _sheet(l10n.settingsMeta, [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in _minuteTiers)
                  _Chip(
                    label: '$m min',
                    selected: _dailyMinutes == m,
                    onTap: () {
                      setState(() => _dailyMinutes = m);
                      setSheet(() {});
                      _save();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.settingsMetaXpDay(goalXp),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ]);
        },
      ),
    );
  }

  Future<void> _openQuietSheet(AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return _sheet(l10n.settingsQuiet, [
            Row(children: [
              Expanded(
                child: Text(l10n.settingsQuietEnable,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
              ),
              _GreenToggle(
                value: _quietOn,
                onChanged: (v) {
                  setState(() => _quietOn = v);
                  setSheet(() {});
                  _save();
                },
              ),
            ]),
            if (_quietOn) ...[
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: _TimeField(
                    label: l10n.settingsQuietFrom,
                    value: _fmt(_quietStart),
                    onTap: () async {
                      final picked = await showTimePicker(context: ctx, initialTime: _quietStart);
                      if (picked != null) {
                        setState(() => _quietStart = picked);
                        setSheet(() {});
                        _save();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: l10n.settingsQuietTo,
                    value: _fmt(_quietEnd),
                    onTap: () async {
                      final picked = await showTimePicker(context: ctx, initialTime: _quietEnd);
                      if (picked != null) {
                        setState(() => _quietEnd = picked);
                        setSheet(() {});
                        _save();
                      }
                    },
                  ),
                ),
              ]),
            ],
          ]);
        },
      ),
    );
  }

  Future<void> _openLegalSheet(AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => _sheet(l10n.settingsPrivacy, [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.privacy_tip_rounded, color: AppColors.primary),
          title: Text(l10n.settingsPrivacyPolicy,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded, color: _kChevron),
          onTap: () {
            Navigator.pop(ctx);
            openLegalPage(kPrivacyPath);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description_rounded, color: AppColors.primary),
          title: Text(l10n.settingsTerms,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded, color: _kChevron),
          onTap: () {
            Navigator.pop(ctx);
            openLegalPage(kTermsPath);
          },
        ),
      ]),
    );
  }

  Widget _sheet(String title, List<Widget> children) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE1E4F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );

  Widget _radioRow({required String label, required bool selected, required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.primary : AppColors.text)),
            ),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : const Color(0xFFC9CDDD),
              size: 22,
            ),
          ]),
        ),
      );

  Future<void> _openEditProfile() async {
    final profile = ref.read(profileProvider).value;
    if (profile == null) {
      // Aún cargando: espera el valor real antes de abrir.
      final loaded = await ref.read(profileProvider.future);
      if (!mounted) return;
      await showEditProfileSheet(context, ref, loaded);
      return;
    }
    await showEditProfileSheet(context, ref, profile);
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
    Navigator.of(context).pop();
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
    ref.invalidate(homeStatsProvider);
    ref.invalidate(lessonProgressProvider);
    ref.invalidate(skillsProvider);
    ref.invalidate(userPlanProvider);
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _switchCourse(CourseInfo c) async {
    final l10n = AppLocalizations.of(context);
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
      await ref.read(progressRepositoryProvider).setActiveCourse(c.id);
      ref.invalidate(coursesProvider);
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(skillMasteryProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(levelExamStatusProvider);
      ref.invalidate(planTrackingProvider);
      ref.invalidate(userPlanProvider);

      if (choice == 'test' && mounted) {
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
          SnackBar(content: Text('${c.flag}  ${c.targetName}')),
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
}

/// Card blanca con la sombra dura del mockup (0 4 0 #E4E6EE + halo suave).
class _Group extends StatelessWidget {
  const _Group({required this.children, this.padding = EdgeInsets.zero});
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  static const _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(18)),
    boxShadow: [
      BoxShadow(color: Color(0xFFE4E6EE), offset: Offset(0, 4), blurRadius: 0),
      BoxShadow(color: Color(0x0D3C3778), offset: Offset(0, 10), blurRadius: 20),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: _decoration,
      child: Padding(
        padding: padding,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}

/// Toggle verde custom (Ajustes.dc): pista 48×28 verde/gris + perilla 22 blanca.
class _GreenToggle extends StatelessWidget {
  const _GreenToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final dur = reduce ? Duration.zero : const Duration(milliseconds: 190);
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: dur,
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.success : const Color(0xFFD0D5E2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 2),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: dur,
              curve: Curves.easeOut,
              left: value ? 23 : 3,
              top: 3,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Color(0x38000000), offset: Offset(0, 2), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opción de coach (radio con borde), fiel al mockup.
class _CoachRadioRow extends StatelessWidget {
  const _CoachRadioRow({required this.name, required this.selected, required this.onTap});
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF4F2FF) : const Color(0xFFFAFAFD),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFEDEEF4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                    color: selected ? AppColors.primary : const Color(0xFFCDD2E2), width: 2.5),
              ),
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.primary),
                    )
                  : null,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
            ),
          ],
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
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
