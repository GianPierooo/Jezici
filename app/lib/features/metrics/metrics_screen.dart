import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/monitoring/sentry_config.dart';
import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Panel mínimo de métricas (Especificacion §13). Lee get_metrics() —
/// herramienta interna; los números son agregados, no datos personales.
/// i18n es/en/pt (era la última pantalla con español hardcodeado).
class MetricsScreen extends ConsumerWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(metricsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: Text(l10n.metricsTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: () => ref.invalidate(metricsProvider), icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) =>
            Center(child: Text('${l10n.metricsLoadError}\n$e', textAlign: TextAlign.center)),
        data: (m) {
          int i(String k) => (m[k] as num?)?.toInt() ?? 0;
          String pct(String k) => '${(((m[k] as num?)?.toDouble() ?? 0) * 100).toStringAsFixed(1)}%';
          String num2(String k) => ((m[k] as num?)?.toDouble() ?? 0).toStringAsFixed(2);
          return ResponsiveCenter(
            maxWidth: 560,
            child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _group(l10n.metricsSecUsers, [
                _row(l10n.metricsTotal, '${i('total_users')}'),
                _row(l10n.metricsNew7d, '${i('new_users_7d')}'),
              ]),
              _group(l10n.metricsSecActivity, [
                _row('DAU', '${i('dau')}'),
                _row('WAU', '${i('wau')}'),
                _row('MAU', '${i('mau')}'),
                // CURR / stickiness: qué fracción de los activos del mes vuelve hoy.
                _row(l10n.metricsStickiness,
                    i('mau') > 0 ? '${(i('dau') / i('mau') * 100).toStringAsFixed(1)}%' : '—'),
                _row(l10n.metricsAvgStreak, num2('avg_streak')),
                _row(l10n.metricsLessonsPerActiveDay, num2('lessons_per_active_day')),
              ]),
              _group(l10n.metricsSecRetention, [
                _row('D1', pct('retention_d1')),
                _row('D7', pct('retention_d7')),
                _row('D30', pct('retention_d30')),
              ]),
              _group(l10n.metricsSecLearning, [
                _row(l10n.metricsPassCheckpoint, pct('pct_pass_checkpoint')),
                _row(l10n.metricsPassLevelExam, pct('pct_pass_level_exam')),
                _row(l10n.metricsCertified, pct('pct_certified')),
              ]),
              _group(l10n.metricsSecBusiness, [
                _row(l10n.metricsPremiumConversion, pct('conversion_premium')),
              ]),
              _OnboardingFunnel(),
              _Engagement(),
              _FeedbackMessages(),
              // Monitoreo de errores (Sentry) — SOLO admin (esta pantalla lo es).
              const _SentryTestCard(),
              const SizedBox(height: 8),
              Text(l10n.metricsGeneratedAt('${m['generated_at'] ?? ''}'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            ],
          ),
          );
        },
      ),
    );
  }

  Widget _group(String title, List<Widget> rows) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
            child: Column(children: rows),
          ),
        ]),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
        ]),
      );
}

/// Embudo de onboarding (GA4 · B7): usuarios por paso + tasa de finalización.
class _OnboardingFunnel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Los rótulos de los 9 pasos viajan en UNA clave separada por '|' (evita 9
    // claves sueltas); el orden es el de los pasos del onboarding.
    final labels = l10n.metricsOnbSteps.split('|');
    final async = ref.watch(onboardingFunnelProvider);
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (f) {
        final steps = (f['steps'] as List?) ?? const [];
        final started = (f['started'] as num?)?.toInt() ?? 0;
        final completed = (f['completed'] as num?)?.toInt() ?? 0;
        final rate = ((f['completion_rate'] as num?)?.toDouble() ?? 0) * 100;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.metricsOnbFunnel,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
              child: Column(children: [
                for (final s in steps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                          '${(s as Map)['step']}. ${labels[((s['step'] as num?)?.toInt() ?? 0).clamp(0, labels.length - 1)]}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      Text('${(s['users'] as num?)?.toInt() ?? 0}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ]),
                  ),
                const Divider(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(l10n.metricsCompletedOf(completed, started),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                  Text('${rate.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.success)),
                ]),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

/// Engagement (GA7): uso por sección (7d), feedback e interés en Conversar.
class _Engagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(engagementProvider);
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (e) {
        final usage = (e['section_usage_7d'] as Map?) ?? const {};
        final fb = (e['feedback_by_kind'] as Map?) ?? const {};
        final interest = (e['conversar_interest'] as Map?) ?? const {};
        final lf = (e['lesson_funnel'] as Map?) ?? const {};
        int lfi(String k) => (lf[k] as num?)?.toInt() ?? 0;
        final lfRate = ((lf['completion_rate'] as num?)?.toDouble() ?? 0) * 100;
        Widget rows(Map m, String empty) => m.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(empty,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)))
            : Column(children: [
                for (final k in m.keys)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('$k', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      Text('${m[k]}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ]),
                  ),
              ]);
        Widget lfRow(String label, int value, {Color color = AppColors.primary}) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
              ]),
            );
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.metricsSectionUsage,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 8),
            _card(rows(usage, l10n.metricsNoViews)),
            const SizedBox(height: 16),
            // Embudo DENTRO de la lección (30 días): dónde abandonan.
            Text(l10n.metricsLessonFunnel,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 8),
            _card(Column(children: [
              lfRow(l10n.metricsLessonsStarted, lfi('started')),
              lfRow(l10n.metricsLessonsCompleted, lfi('completed')),
              lfRow(l10n.metricsLessonsQuit, lfi('quit'), color: AppColors.coral),
              lfRow(l10n.metricsNoHeartsRow, lfi('no_hearts'), color: AppColors.coral),
              const Divider(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(l10n.metricsCompletionRate,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                Text('${lfRate.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.success)),
              ]),
            ])),
            const SizedBox(height: 16),
            Text(l10n.metricsFeedbackInterest,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 8),
            _card(Column(children: [
              rows(fb, l10n.metricsNoFeedback),
              const Divider(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: Text(l10n.metricsLiveInterest,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ),
                  Text('${interest['would_use_yes'] ?? 0}/${interest['responses'] ?? 0}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(l10n.metricsConvAttempts,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  Text('${e['conversation_attempts'] ?? 0}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ]),
              ),
            ])),
          ]),
        );
      },
    );
  }

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
        child: child,
      );
}

/// Mensajes de feedback REALES de los usuarios (texto). Antes solo se veía el conteo
/// por tipo; esto muestra lo que escribieron (admin only, get_feedback). Sin PII.
class _FeedbackMessages extends ConsumerWidget {
  static const _kindEmoji = {'idea': '💡', 'bug': '🐞', 'other': '💬'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(feedbackProvider);
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (list) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(l10n.metricsUserMessages,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${list.length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ),
            ]),
            const SizedBox(height: 8),
            if (list.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
                child: Text(l10n.metricsNoMessages,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              )
            else
              for (final f in list) _feedbackCard(f),
          ]),
        );
      },
    );
  }

  Widget _feedbackCard(Map<String, dynamic> f) {
    final kind = (f['kind'] as String?) ?? 'other';
    final screen = (f['screen'] as String?) ?? '';
    final date = (f['created_at'] as String?)?.split('T').first ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_kindEmoji[kind] ?? '💬', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text('$kind · $screen',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          ),
          Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        ]),
        const SizedBox(height: 6),
        Text((f['message'] as String?) ?? '',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
      ]),
    );
  }
}

/// Tarjeta de MONITOREO (Sentry) en Métricas (admin-only). Muestra si Sentry
/// está activo (hay DSN) y deja al admin disparar un evento de PRUEBA
/// (excepción CAPTURADA, no un crash) para confirmar que llega al dashboard.
/// NO existe ningún botón de error visible para el público (esta pantalla es
/// admin-gated desde Ajustes → "Ver métricas").
class _SentryTestCard extends StatefulWidget {
  const _SentryTestCard();
  @override
  State<_SentryTestCard> createState() => _SentryTestCardState();
}

class _SentryTestCardState extends State<_SentryTestCard> {
  bool _busy = false;

  Future<void> _send() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final id = await sentryTestEvent();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(id == null ? l10n.metricsSentryNotSent : l10n.metricsSentrySent(id)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final on = sentryEnabled;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.metricsSentryTitle,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)
              ]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(on ? Icons.check_circle_rounded : Icons.cloud_off_rounded,
                  size: 18, color: on ? AppColors.success : AppColors.textMuted),
              const SizedBox(width: 8),
              Text(on ? l10n.metricsSentryOn : l10n.metricsSentryOff,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
            ]),
            const SizedBox(height: 10),
            Text(
              on ? l10n.metricsSentryHintOn : l10n.metricsSentryHintOff,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: on && !_busy ? _send : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.bug_report_rounded, size: 18),
                label: Text(l10n.metricsSentrySend,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
