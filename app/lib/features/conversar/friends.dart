import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_engine.dart';
import '../../core/speech/voice_recorder.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';

/// CONVERSAR · OLA 1 — social ASÍNCRONO ABIERTO (18+). Amigos por código + chat
/// de texto + notas de voz + corrección + racha + retos en pareja (co-op).
/// Visible solo si `get_social_status.access == true` (adulto verificado; el
/// abogado aprobó los términos UGC → ya no hay allowlist). Los menores quedan
/// fuera (jz_social_access). Reportar/bloquear en cada chat; filtro de contacto
/// + rate limit + RLS server-side.

/// Estado social del usuario (acceso + código propio).
final socialStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(progressRepositoryProvider).getSocialStatus();
});

/// Lista de amigos + solicitudes.
final friendsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(progressRepositoryProvider).listFriends();
});

/// Retos en pareja (co-op) del usuario.
final coopsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(progressRepositoryProvider).listCoops();
});

Color _hex(String s) {
  final v = s.replaceAll('#', '');
  return Color(int.parse('FF$v', radix: 16));
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de entrada a "Amigos" en Conversar (solo si hay acceso social).
// ─────────────────────────────────────────────────────────────────────────────
class FriendsEntryCard extends ConsumerWidget {
  const FriendsEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(socialStatusProvider);
    final hasAccess = status.maybeWhen(data: (s) => s['access'] == true, orElse: () => false);
    if (!hasAccess) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _GradientCard(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FriendsScreen())),
        icon: Icons.forum_rounded,
        title: l10n.convFriendsTitle,
        subtitle: l10n.convFriendsSubtitle,
      ),
    );
  }
}

/// Tarjeta rica con gradiente violeta e icon-tile (lenguaje del mockup).
class _GradientCard extends StatelessWidget {
  const _GradientCard(
      {required this.onTap, required this.icon, required this.title, required this.subtitle});
  final VoidCallback onTap;
  final IconData icon;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7A6BF0), Color(0xFF6C5CE7), Color(0xFF5B4ECF)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x336C5CE7), blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla HUB de amigos: tu código + agregar + solicitudes + lista + co-op.
// ─────────────────────────────────────────────────────────────────────────────
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(progressRepositoryProvider).sendFriendRequest(c);
      _code.clear();
      ref.invalidate(friendsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.convRequestSent)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.convCodeError)));
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
            onRefresh: () async {
              ref.invalidate(friendsProvider);
              ref.invalidate(coopsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _CodeCard(code: myCode),
                const SizedBox(height: 16),
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
                // Co-op entry
                _GradientCard(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CoopScreen())),
                  icon: Icons.flag_rounded,
                  title: l10n.convCoopEntry,
                  subtitle: l10n.convCoopEntrySub,
                ),
                const SizedBox(height: 18),
                friends.when(
                  loading: () => const Padding(
                      padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
                  error: (_, _) => _ErrorRetry(onRetry: () => ref.invalidate(friendsProvider)),
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
                          _EmptyFriends(l10n: l10n)
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

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code});
  final String? code;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
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
                Text(code ?? '·······',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        letterSpacing: 2)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
            onPressed: code == null
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: code!));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(l10n.convCodeCopied)));
                  },
          ),
        ],
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends({required this.l10n});
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          const ParrotMascot(size: 84, mood: MascotMood.encourage),
          const SizedBox(height: 10),
          Text(l10n.convNoFriends,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l10n.commonRetry),
        ),
      ),
    );
  }
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
          CircleAvatar(
              backgroundColor: _hex(color),
              radius: 18,
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
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
  const _FriendRow(
      {required this.name, required this.color, required this.streak, required this.onTap});
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
          leading: CircleAvatar(
              backgroundColor: _hex(color),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
          trailing: streak > 0
              ? _StreakPulse(streak: streak)
              : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// Racha con el amigo — 🔥 con pulso suave (reduce-motion-aware).
class _StreakPulse extends StatefulWidget {
  const _StreakPulse({required this.streak});
  final int streak;
  @override
  State<_StreakPulse> createState() => _StreakPulseState();
}

class _StreakPulseState extends State<_StreakPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final fire = Row(mainAxisSize: MainAxisSize.min, children: [
      const Text('🔥', style: TextStyle(fontSize: 16)),
      Text('${widget.streak}',
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.streak)),
    ]);
    if (reduce) return fire;
    return ScaleTransition(
      scale: Tween(begin: 0.94, end: 1.08).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: fire,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat 1:1 (Realtime) — texto + notas de voz + corrección + reportar/bloquear.
// ─────────────────────────────────────────────────────────────────────────────
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen(
      {super.key, required this.connectionId, required this.friendId, required this.friendName});
  final String connectionId, friendId, friendName;
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msg = TextEditingController();
  final VoiceRecorder _rec = VoiceRecorder();
  bool _sending = false;
  bool _recording = false;
  bool _uploadingVoice = false;

  @override
  void initState() {
    super.initState();
    _msg.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // el composer alterna entre 🎤 y ➤ según haya texto
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _msg.removeListener(_onTextChanged);
    _msg.dispose();
    if (_recording) _rec.cancel();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _msg.text.trim();
    if (t.isEmpty || _sending) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(progressRepositoryProvider).sendChatMessage(widget.connectionId, t);
      _msg.clear();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.convSendError)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleVoice() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_recording) {
      final err = await _rec.start();
      if (err != null) {
        messenger.showSnackBar(SnackBar(
            content: Text(err == 'unsupported'
                ? l10n.convVoiceMicUnsupported
                : l10n.convVoiceMicDenied)));
        return;
      }
      if (mounted) setState(() => _recording = true);
    } else {
      setState(() {
        _recording = false;
        _uploadingVoice = true;
      });
      try {
        final r = await _rec.stop();
        if (r != null && r.bytes.isNotEmpty) {
          await ref
              .read(progressRepositoryProvider)
              .sendVoiceNote(widget.connectionId, r.bytes, r.ext);
        }
      } catch (_) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.convVoiceSendError)));
      } finally {
        if (mounted) setState(() => _uploadingVoice = false);
      }
    }
  }

  void _cancelVoice() {
    _rec.cancel();
    if (mounted) setState(() => _recording = false);
  }

  Future<void> _blockOrReport(String action) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(progressRepositoryProvider);
    try {
      if (action == 'block') {
        await repo.blockUser(widget.friendId);
        ref.invalidate(friendsProvider);
        navigator.pop();
      } else {
        await repo.reportUser(widget.friendId, 'reported from chat');
        messenger.showSnackBar(SnackBar(content: Text(l10n.convReported)));
      }
    } catch (_) {}
  }

  Future<void> _correct(Map<String, dynamic> m) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(progressRepositoryProvider);
    final ctrl = TextEditingController(text: (m['body'] ?? '').toString());
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l10n.convCorrect, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
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
      await repo.addCorrection(m['id'].toString(), result, null);
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
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const ParrotMascot(size: 90),
                          const SizedBox(height: 8),
                          Text(l10n.convChatEmpty,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        ]),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: msgs.length,
                      itemBuilder: (context, i) {
                        final m = msgs[msgs.length - 1 - i];
                        final mine = m['sender_id'].toString() == repo.currentUserId;
                        final isVoice = (m['kind'] ?? '').toString() == 'voice';
                        return _Bubble(
                          mine: mine,
                          onCorrect: (mine || isVoice) ? null : () => _correct(m),
                          child: isVoice
                              ? _VoiceBubble(
                                  path: (m['audio_url'] ?? '').toString(),
                                  mine: mine,
                                  repo: repo)
                              : _TextBubbleBody(text: (m['body'] ?? '').toString(), mine: mine),
                        );
                      },
                    );
                  },
                ),
              ),
              _Composer(
                controller: _msg,
                sending: _sending,
                recording: _recording,
                uploadingVoice: _uploadingVoice,
                onSend: _send,
                onVoice: _toggleVoice,
                onCancelVoice: _cancelVoice,
                hint: l10n.convChatHint,
                recordingLabel: l10n.convVoiceRecording,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.mine, required this.child, this.onCorrect});
  final bool mine;
  final Widget child;
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
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: mine ? null : Border.all(color: const Color(0xFFE5E7F1), width: 2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TextBubbleBody extends StatelessWidget {
  const _TextBubbleBody({required this.text, required this.mine});
  final String text;
  final bool mine;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: mine ? Colors.white : AppColors.text));
  }
}

/// Reproduce una nota de voz (bucket privado → URL firmada al tocar).
class _VoiceBubble extends StatefulWidget {
  const _VoiceBubble({required this.path, required this.mine, required this.repo});
  final String path;
  final bool mine;
  final dynamic repo;
  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  bool _loading = false;
  bool _playing = false;

  Future<void> _play() async {
    if (_loading || _playing || widget.path.isEmpty) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final url = await widget.repo.signedVoiceUrl(widget.path) as String;
      if (!mounted) return;
      setState(() {
        _loading = false;
        _playing = true;
      });
      await AudioEngine.instance.playUrl(url, onComplete: () {
        if (mounted) setState(() => _playing = false);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _playing = false;
        });
        messenger.showSnackBar(SnackBar(content: Text(l10n.convVoicePlayError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fg = widget.mine ? Colors.white : AppColors.primary;
    return InkWell(
      onTap: _play,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
            : Icon(_playing ? Icons.graphic_eq_rounded : Icons.play_circle_fill_rounded,
                color: fg, size: 28),
        const SizedBox(width: 8),
        Text(l10n.convVoiceNote,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: widget.mine ? Colors.white : AppColors.text)),
      ]),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.recording,
    required this.uploadingVoice,
    required this.onSend,
    required this.onVoice,
    required this.onCancelVoice,
    required this.hint,
    required this.recordingLabel,
  });
  final TextEditingController controller;
  final bool sending, recording, uploadingVoice;
  final VoidCallback onSend, onVoice, onCancelVoice;
  final String hint, recordingLabel;

  @override
  Widget build(BuildContext context) {
    if (recording) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Row(children: [
          IconButton(onPressed: onCancelVoice, icon: const Icon(Icons.close_rounded)),
          const SizedBox(width: 4),
          const _RecordingDot(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(recordingLabel,
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text)),
          ),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.success,
            onPressed: onVoice,
            child: const Icon(Icons.send_rounded),
          ),
        ]),
      );
    }
    final hasText = controller.text.trim().isNotEmpty;
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
          if (hasText)
            FloatingActionButton(
              mini: true,
              onPressed: sending ? null : onSend,
              child: const Icon(Icons.send_rounded),
            )
          else
            FloatingActionButton(
              mini: true,
              onPressed: uploadingVoice ? null : onVoice,
              child: uploadingVoice
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.mic_rounded),
            ),
        ],
      ),
    );
  }
}

class _RecordingDot extends StatefulWidget {
  const _RecordingDot();
  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final dot = Container(
        width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFE74C3C), shape: BoxShape.circle));
    if (reduce) return dot;
    return FadeTransition(opacity: Tween(begin: 0.35, end: 1.0).animate(_c), child: dot);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CO-OP — retos en pareja.
// ─────────────────────────────────────────────────────────────────────────────
class CoopScreen extends ConsumerWidget {
  const CoopScreen({super.key});

  Future<void> _respond(WidgetRef ref, String coopId, bool accept) async {
    await ref.read(progressRepositoryProvider).respondCoop(coopId, accept);
    ref.invalidate(coopsProvider);
  }

  Future<void> _createFlow(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final friendsData = await ref.read(progressRepositoryProvider).listFriends();
    final friends = (friendsData['friends'] as List?) ?? const [];
    if (!context.mounted) return;
    if (friends.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.convCoopNoFriends)));
      return;
    }
    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.convCoopWith,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          for (final f in friends)
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: _hex((f['avatar_color'] ?? '#6C5CE7').toString()),
                  child: Text((f['name'] ?? '?').toString().isNotEmpty
                      ? (f['name']).toString()[0].toUpperCase()
                      : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
              title: Text((f['name'] ?? '').toString(),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              onTap: () => Navigator.of(ctx).pop(Map<String, dynamic>.from(f as Map)),
            ),
        ]),
      ),
    );
    if (picked == null || !context.mounted) return;
    final goal = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.convCoopPickGoal,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          for (final xp in const [100, 300, 500])
            ListTile(
              leading: const Icon(Icons.bolt_rounded, color: AppColors.streak),
              title: Text('$xp XP', style: const TextStyle(fontWeight: FontWeight.w800)),
              onTap: () => Navigator.of(ctx).pop(xp),
            ),
        ]),
      ),
    );
    if (goal == null) return;
    try {
      await ref
          .read(progressRepositoryProvider)
          .createCoop(picked['user_id'].toString(), goal);
      ref.invalidate(coopsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.convCoopInvitePending)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.convCoopError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final coops = ref.watch(coopsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.convCoopTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createFlow(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.convCoopStart),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(coopsProvider),
            child: coops.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _ErrorRetry(onRetry: () => ref.invalidate(coopsProvider)),
              data: (list) {
                if (list.isEmpty) {
                  return ListView(children: [
                    const SizedBox(height: 60),
                    const Center(child: ParrotMascot(size: 100, mood: MascotMood.encourage)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(l10n.convCoopEmpty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ),
                  ]);
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  children: [
                    Text(l10n.convCoopSubtitle,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 12),
                    for (final c in list)
                      _CoopCard(
                        coop: c,
                        onAccept: () => _respond(ref, c['coop_id'].toString(), true),
                        onReject: () => _respond(ref, c['coop_id'].toString(), false),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CoopCard extends StatelessWidget {
  const _CoopCard({required this.coop, required this.onAccept, required this.onReject});
  final Map<String, dynamic> coop;
  final VoidCallback onAccept, onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = (coop['partner_name'] ?? '').toString();
    final color = (coop['partner_color'] ?? '#6C5CE7').toString();
    final status = (coop['status'] ?? '').toString();
    final target = (coop['target'] as num?)?.toInt() ?? 0;
    final progress = (coop['progress'] as num?)?.toInt() ?? 0;
    final iCreated = coop['i_created'] == true;
    final reward = (coop['reward_gold'] as num?)?.toInt() ?? 50;
    final pct = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

    final bool invited = status == 'invited';
    final bool completed = status == 'completed';
    final bool expired = status == 'expired';

    Color badgeColor;
    String badgeText;
    if (completed) {
      badgeColor = AppColors.success;
      badgeText = l10n.convCoopCompleted;
    } else if (expired) {
      badgeColor = AppColors.textMuted;
      badgeText = l10n.convCoopExpired;
    } else if (invited) {
      badgeColor = AppColors.primary;
      badgeText = iCreated ? l10n.convCoopInvitePending : l10n.convCoopInviteReceived;
    } else {
      badgeColor = AppColors.streak;
      badgeText = l10n.convCoopActive;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: completed ? AppColors.success : const Color(0xFFE5E7F1),
            width: completed ? 2.5 : 2),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
                backgroundColor: _hex(color),
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(badgeText,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: badgeColor)),
            ),
          ]),
          if (completed) ...[
            const SizedBox(height: 12),
            Row(children: [
              const Text('🎉', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text('+$reward 🪙',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.gold)),
            ]),
          ] else if (invited && !iCreated) ...[
            const SizedBox(height: 8),
            Text(l10n.convCoopProgress(0, target),
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(onPressed: onReject, child: Text(l10n.convCoopReject)),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(onPressed: onAccept, child: Text(l10n.convCoopAccept)),
              ),
            ]),
          ] else ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 12,
                backgroundColor: const Color(0xFFEDEEF6),
                valueColor: AlwaysStoppedAnimation(
                    expired ? AppColors.textMuted : AppColors.streak),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l10n.convCoopProgress(progress, target),
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
              Text(l10n.convCoopReward(reward),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ]),
          ],
        ],
      ),
    );
  }
}
