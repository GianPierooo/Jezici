import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';

/// Panel mínimo de métricas (Especificacion §13). Lee get_metrics() —
/// herramienta interna; los números son agregados, no datos personales.
class MetricsScreen extends ConsumerWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(metricsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: const Text('Métricas', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: () => ref.invalidate(metricsProvider), icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('No se pudieron cargar.\n$e', textAlign: TextAlign.center)),
        data: (m) {
          int i(String k) => (m[k] as num?)?.toInt() ?? 0;
          String pct(String k) => '${(((m[k] as num?)?.toDouble() ?? 0) * 100).toStringAsFixed(1)}%';
          String num2(String k) => ((m[k] as num?)?.toDouble() ?? 0).toStringAsFixed(2);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _group('Usuarios', [
                _row('Total', '${i('total_users')}'),
                _row('Nuevos (7 días)', '${i('new_users_7d')}'),
              ]),
              _group('Actividad', [
                _row('DAU', '${i('dau')}'),
                _row('WAU', '${i('wau')}'),
                _row('MAU', '${i('mau')}'),
                // CURR / stickiness: qué fracción de los activos del mes vuelve hoy.
                _row('Stickiness (DAU/MAU)',
                    i('mau') > 0 ? '${(i('dau') / i('mau') * 100).toStringAsFixed(1)}%' : '—'),
                _row('Racha media', num2('avg_streak')),
                _row('Lecciones / día activo', num2('lessons_per_active_day')),
              ]),
              _group('Retención', [
                _row('D1', pct('retention_d1')),
                _row('D7', pct('retention_d7')),
                _row('D30', pct('retention_d30')),
              ]),
              _group('Aprendizaje', [
                _row('% aprueba checkpoint', pct('pct_pass_checkpoint')),
                _row('% aprueba examen de nivel', pct('pct_pass_level_exam')),
                _row('% certifica', pct('pct_certified')),
              ]),
              _group('Negocio', [
                _row('Conversión premium', pct('conversion_premium')),
              ]),
              _OnboardingFunnel(),
              _Engagement(),
              _FeedbackMessages(),
              const SizedBox(height: 8),
              Text('Generado: ${m['generated_at'] ?? ''}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            ],
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
          Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
        ]),
      );
}

/// Embudo de onboarding (GA4 · B7): usuarios por paso + tasa de finalización.
class _OnboardingFunnel extends ConsumerWidget {
  static const _labels = [
    'Bienvenida', 'Idioma', 'Motivo', 'Meta', 'Compromiso',
    'Personalidad', 'Arranque', 'Ubicación', 'Tu plan',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const Text('Embudo de onboarding',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
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
                      Text('${(s as Map)['step']}. ${_labels[((s['step'] as num?)?.toInt() ?? 0).clamp(0, 8)]}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      Text('${(s['users'] as num?)?.toInt() ?? 0}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ]),
                  ),
                const Divider(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Completaron $completed / $started',
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Uso por sección (7 días)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 8),
            _card(rows(usage, 'Aún sin vistas registradas.')),
            const SizedBox(height: 16),
            // Embudo DENTRO de la lección (30 días): dónde abandonan.
            const Text('Embudo de lección (30 días)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 8),
            _card(Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Lecciones iniciadas',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  Text('${lfi('started')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Completadas',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  Text('${lfi('completed')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Abandonadas (salida)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  Text('${lfi('quit')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.coral)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Se quedaron sin vidas',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  Text('${lfi('no_hearts')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.coral)),
                ]),
              ),
              const Divider(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tasa de finalización',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                Text('${lfRate.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.success)),
              ]),
            ])),
            const SizedBox(height: 16),
            const Text('Feedback e interés',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 8),
            _card(Column(children: [
              rows(fb, 'Aún sin feedback.'),
              const Divider(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Interés conversación en vivo (sí/total)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  Text('${interest['would_use_yes'] ?? 0}/${interest['responses'] ?? 0}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Prácticas de conversación',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
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
    final async = ref.watch(feedbackProvider);
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (list) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Mensajes de usuarios',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
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
                child: const Text('Aún sin mensajes.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
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
