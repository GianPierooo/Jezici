import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';

/// CONVERSAR · OLA 1 — social ASÍNCRONO CERRADO (amigos por código + chat texto +
/// corrección + racha). Solo visible si `get_social_status.access == true`
/// (18+ y en la allowlist beta). El público NO ve nada de esto.

/// Estado social del usuario (acceso + código propio).
final socialStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(progressRepositoryProvider).getSocialStatus();
});

/// Lista de amigos + solicitudes.
final friendsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(progressRepositoryProvider).listFriends();
});

/// Tarjeta de entrada a "Amigos" en Conversar (solo si hay acceso social).
class FriendsEntryCard extends ConsumerWidget {
  const FriendsEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(socialStatusProvider);
    final hasAccess = status.maybeWhen(
        data: (s) => s['access'] == true, orElse: () => false);
    if (!hasAccess) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FriendsScreen())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7F1), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.navActiveBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.group_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.convFriendsTitle,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text(l10n.convFriendsSubtitle,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla de amigos: tu código + agregar por código + solicitudes + lista.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});
  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _code = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _addByCode() async {
    final c = _code.text.trim().toUpperCase();
    if (c.isEmpty || _sending) return;
    setState(() => _sending = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(progressRepositoryProvider).sendFriendRequest(c);
      _code.clear();
      ref.invalidate(friendsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.convRequestSent)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.convCodeError)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _respond(String connectionId, bool accept) async {
    await ref.read(progressRepositoryProvider).respondFriendRequest(connectionId, accept);
    ref.invalidate(friendsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(socialStatusProvider);
    final myCode = status.maybeWhen(data: (s) => s['friend_code'] as String?, orElse: () => null);
    final friends = ref.watch(friendsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.convFriendsTitle)),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(friendsProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Tu código
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E7F1), width: 2),
                  ),
                  child: Row(
                    children: [
                      const ParrotMascot(size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.convYourCode,
                                style: const TextStyle(
                                    fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(myCode ?? '·······',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: 2)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
                        onPressed: myCode == null
                            ? null
                            : () {
                                Clipboard.setData(ClipboardData(text: myCode));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(l10n.convCodeCopied)));
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Agregar por código
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 7,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2),
                        decoration: InputDecoration(
                          hintText: l10n.convEnterCode,
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 130,
                      child: PrimaryButton(
                        label: l10n.convAddFriend,
                        onPressed: (_code.text.trim().isNotEmpty && !_sending) ? _addByCode : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l10n.convContactFilterNote,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                const SizedBox(height: 18),
                friends.when(
                  loading: () => const Padding(
                      padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
                  error: (_, _) => Text(l10n.commonRetry),
                  data: (data) {
                    final incoming = (data['incoming'] as List?) ?? const [];
                    final list = (data['friends'] as List?) ?? const [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (incoming.isNotEmpty) ...[
                          Text(l10n.convRequests,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          for (final r in incoming)
                            _RequestRow(
                              name: (r['name'] ?? '').toString(),
                              color: (r['avatar_color'] ?? '#6C5CE7').toString(),
                              onAccept: () => _respond(r['connection_id'].toString(), true),
                              onReject: () => _respond(r['connection_id'].toString(), false),
                            ),
                          const SizedBox(height: 18),
                        ],
                        if (list.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Center(
                              child: Text(l10n.convNoFriends,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                            ),
                          )
                        else
                          for (final f in list)
                            _FriendRow(
                              name: (f['name'] ?? '').toString(),
                              color: (f['avatar_color'] ?? '#6C5CE7').toString(),
                              streak: (f['streak'] as num?)?.toInt() ?? 0,
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  connectionId: f['connection_id'].toString(),
                                  friendId: f['user_id'].toString(),
                                  friendName: (f['name'] ?? '').toString(),
                                ),
                              )),
                            ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _hex(String s) {
  final v = s.replaceAll('#', '');
  return Color(int.parse('FF$v', radix: 16));
}

class _RequestRow extends StatelessWidget {
  const _RequestRow(
      {required this.name, required this.color, required this.onAccept, required this.onReject});
  final String name, color;
  final VoidCallback onAccept, onReject;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: _hex(color), radius: 18, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800))),
          TextButton(onPressed: onReject, child: Text(l10n.convReject)),
          const SizedBox(width: 4),
          FilledButton(onPressed: onAccept, child: Text(l10n.convAccept)),
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.name, required this.color, required this.streak, required this.onTap});
  final String name, color;
  final int streak;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE5E7F1), width: 2)),
          leading: CircleAvatar(backgroundColor: _hex(color), child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
          trailing: streak > 0
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  Text('$streak', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.streak)),
                ])
              : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// Chat 1:1 con un amigo (Realtime). Reportar/bloquear en el app bar; corregir
/// con long-press en un mensaje del amigo.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen(
      {super.key, required this.connectionId, required this.friendId, required this.friendName});
  final String connectionId, friendId, friendName;
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msg = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _msg.text.trim();
    if (t.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(progressRepositoryProvider).sendChatMessage(widget.connectionId, t);
      _msg.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).convSendError)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _blockOrReport(String action) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(progressRepositoryProvider);
    try {
      if (action == 'block') {
        await repo.blockUser(widget.friendId);
        if (mounted) Navigator.of(context).pop();
      } else {
        await repo.reportUser(widget.friendId, 'reported from chat');
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.convReported)));
        }
      }
    } catch (_) {}
  }

  Future<void> _correct(Map<String, dynamic> m) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: (m['body'] ?? '').toString());
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l10n.convCorrect,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 12),
          PrimaryButton(
              label: l10n.convSendCorrection,
              expand: true,
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim())),
        ]),
      ),
    );
    if (result != null && result.isNotEmpty) {
      await ref.read(progressRepositoryProvider).addCorrection(m['id'].toString(), result, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(progressRepositoryProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.friendName),
        actions: [
          PopupMenuButton<String>(
            onSelected: _blockOrReport,
            itemBuilder: (_) => [
              PopupMenuItem(value: 'report', child: Text(l10n.convReport)),
              PopupMenuItem(value: 'block', child: Text(l10n.convBlock)),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 640,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: repo.chatMessagesStream(widget.connectionId),
                  builder: (context, snap) {
                    final msgs = snap.data ?? const [];
                    if (msgs.isEmpty) {
                      return Center(
                        child: Text(l10n.convChatEmpty,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: msgs.length,
                      itemBuilder: (context, i) {
                        final m = msgs[msgs.length - 1 - i];
                        final mine = m['sender_id'].toString() == repo.currentUserId;
                        return _Bubble(
                          text: (m['body'] ?? '').toString(),
                          mine: mine,
                          onCorrect: mine ? null : () => _correct(m),
                        );
                      },
                    );
                  },
                ),
              ),
              _Composer(controller: _msg, sending: _sending, onSend: _send, hint: l10n.convChatHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine, this.onCorrect});
  final String text;
  final bool mine;
  final VoidCallback? onCorrect;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onCorrect,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: mine ? null : Border.all(color: const Color(0xFFE5E7F1), width: 2),
          ),
          child: Text(text,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: mine ? Colors.white : AppColors.text)),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer(
      {required this.controller, required this.sending, required this.onSend, required this.hint});
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final String hint;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: sending ? null : onSend,
            child: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
