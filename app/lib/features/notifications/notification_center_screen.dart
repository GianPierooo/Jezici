import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import 'matix_service.dart';
import 'matix_test_buttons.dart';

/// Centro de notificaciones in-app (Estructura_App §10): el historial de copys
/// que Matix eligió para el usuario. Demuestra que el tono se ajusta al estilo
/// del test de personalidad. Incluye disparadores de prueba del motor.
class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: const Text('Notificaciones',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(notificationsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        children: [
          // Probar el motor (Fase 1).
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
              children: const [
                Text('Probar a Matix',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                SizedBox(height: 3),
                Text(
                  'Simula un evento: Matix elige el copy de tu estilo de coach y te lo manda.',
                  style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                ),
                SizedBox(height: 12),
                MatixTestButtons(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recibidas',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 10),
          items.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, _) => Text('No se pudieron cargar.\n$e',
                style: const TextStyle(color: AppColors.textMuted)),
            data: (list) => list.isEmpty
                ? const _EmptyState()
                : Column(children: [for (final n in list) _NotifTile(item: n)]),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text('🦜', style: TextStyle(fontSize: 40)),
          SizedBox(height: 8),
          Text('Sin notificaciones todavía',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
          SizedBox(height: 4),
          Text('Usa "Probar a Matix" para ver cómo suena tu coach.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item});
  final NotificationItem item;

  String _ago(DateTime? t) {
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'ahora';
    if (d.inMinutes < 60) return 'hace ${d.inMinutes} min';
    if (d.inHours < 24) return 'hace ${d.inHours} h';
    return 'hace ${d.inDays} d';
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
            child: const Text('🦜', style: TextStyle(fontSize: 19)),
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
                    Text(_ago(item.sentAt),
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
