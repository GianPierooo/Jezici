import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../app_info.dart';
import '../theme/app_colors.dart';

/// Feedback in-app (GA7): accesible desde CUALQUIER pantalla. Guarda en la tabla
/// feedback con contexto (pantalla, versión, plataforma). Maximiza el aprendizaje.
Future<void> showFeedbackSheet(BuildContext context, WidgetRef ref, {required String screen}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => _FeedbackForm(screen: screen),
  );
}

class _FeedbackForm extends ConsumerStatefulWidget {
  const _FeedbackForm({required this.screen});
  final String screen;
  @override
  ConsumerState<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends ConsumerState<_FeedbackForm> {
  final _ctrl = TextEditingController();
  String _kind = 'idea';
  bool _sending = false;

  static const _kinds = [('idea', '💡 Idea'), ('bug', '🐞 Bug'), ('other', '💬 Otro')];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(progressRepositoryProvider).submitFeedback(
            screen: widget.screen,
            kind: _kind,
            message: msg,
            appVersion: kAppVersion,
            platform: platformName(),
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('¡Gracias! Tu feedback nos ayuda muchísimo. 🙌')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo enviar. Inténtalo de nuevo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 2),
          Text('Sobre: ${widget.screen}',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              for (final (k, label) in _kinds)
                GestureDetector(
                  onTap: () => setState(() => _kind = k),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: _kind == k ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _kind == k ? AppColors.primary : const Color(0xFFE5E7F1), width: 2),
                    ),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w900,
                            color: _kind == k ? Colors.white : AppColors.text)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            maxLines: 4,
            maxLength: 2000,
            enabled: !_sending,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '¿Qué viste? ¿Qué mejorarías?',
              filled: true,
              fillColor: const Color(0xFFF7F8FC),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _sending ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(_sending ? 'ENVIANDO…' : 'ENVIAR FEEDBACK',
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón flotante de feedback (se monta sobre el shell → presente en toda la app).
class FeedbackFab extends ConsumerWidget {
  const FeedbackFab({super.key, required this.section});
  final String section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => showFeedbackSheet(context, ref, screen: section),
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF28326E).withValues(alpha: 0.20),
                offset: const Offset(0, 4),
                blurRadius: 12),
          ],
        ),
        child: const Icon(Icons.feedback_outlined, color: AppColors.primary, size: 22),
      ),
    );
  }
}
