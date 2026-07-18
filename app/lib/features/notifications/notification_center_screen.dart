import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'matix_service.dart';
import 'matix_test_buttons.dart';
import 'push_install_cards.dart';

/// Centro de notificaciones in-app (Estructura_App §10): el historial de copys
/// que Matix eligió para el usuario. Demuestra que el tono se ajusta al estilo
/// del test de personalidad. Incluye disparadores de prueba del motor.
class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(notificationsProvider);
    // El banco de pruebas del motor (MatixTestButtons) es herramienta interna →
    // solo visible para admin (como "Ver métricas"). El público no lo ve.
    final isAdmin =
        ref.watch(isAdminProvider).maybeWhen(data: (a) => a, orElse: () => false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text(l10n.notifTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        actions: [
          IconButton(
            tooltip: l10n.notifRefresh,
            onPressed: () => ref.invalidate(notificationsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: 560,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        children: [
          // T4 · Activar PUSH (permiso EXPLÍCITO, nunca automático) + instalar
          // la app (Android/desktop: prompt nativo; iOS: instrucciones).
          const PushOptInCard(),
          const InstallAppCard(),
          // Probar el motor (Fase 1) — SOLO admin.
          if (isAdmin) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.notifTestJezi,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 3),
                  Text(
                    l10n.notifTestJeziHint,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  const MatixTestButtons(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(l10n.notifReceived,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 10),
          items.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, _) => Text(l10n.notifLoadError('$e'),
                style: const TextStyle(color: AppColors.textMuted)),
            data: (list) => list.isEmpty
                ? const _EmptyState()
                : Column(children: [for (final n in list) _NotifTile(item: n)]),
          ),
        ],
      ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const ParrotArt(size: 40),
          const SizedBox(height: 8),
          Text(l10n.notifEmpty,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(l10n.notifEmptyHint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item});
  final NotificationItem item;

  String _ago(BuildContext context, DateTime? t) {
    if (t == null) return '';
    final l10n = AppLocalizations.of(context);
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l10n.notifAgoNow;
    if (d.inMinutes < 60) return l10n.notifAgoMinutes('${d.inMinutes}');
    if (d.inHours < 24) return l10n.notifAgoHours('${d.inHours}');
    return l10n.notifAgoDays('${d.inDays}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.navActiveBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const ParrotArt(size: 24),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(triggerLabel(item.trigger),
                          style: const TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ),
                    Text(_ago(context, item.sentAt),
                        style: const TextStyle(
                            fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(item.body,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
