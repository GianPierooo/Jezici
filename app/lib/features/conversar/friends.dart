import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_engine.dart';
import '../../core/speech/voice_recorder.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_sheen.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';

/// CONVERSAR · social ASÍNCRONO ABIERTO (18+) — capa VISUAL fiel al lenguaje de
/// Conversar.dc y del resto de Jezici: tarjetas blancas con labio duro
/// `0 5px 0 #ECEDF6` + sombra suave, avatares cuadrado-redondeados con
/// gradiente, chips, CTA 3D, Jezi y motion reduce-motion-aware. La LÓGICA
/// (amigos/chat/notas de voz/co-op/racha/moderación/RLS) no se toca.

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

// ─────────────────────────────────────────────────────────────────────────────
// Lenguaje visual compartido
// ─────────────────────────────────────────────────────────────────────────────
Color _hex(String s) {
  final v = s.replaceAll('#', '');
  return Color(int.parse('FF$v', radix: 16));
}

Color _lighten(Color c, [double amt = 0.22]) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness + amt).clamp(0.0, 1.0)).toColor();
}

/// Avatar cuadrado-redondeado con gradiente (54×54 radio 18 en el mockup).
class _Squircle extends StatelessWidget {
  const _Squircle({required this.color, required this.letter, this.size = 50});
  final String color, letter;
  final double size;
  @override
  Widget build(BuildContext context) {
    final c = _hex(color);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_lighten(c), c]),
        borderRadius: BorderRadius.circular(size * 0.33),
      ),
      child: Text(letter.isNotEmpty ? letter[0].toUpperCase() : '?',
          style: TextStyle(
              color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.w900)),
    );
  }
}

/// Tarjeta blanca con LABIO DURO + sombra suave (la firma del mockup) y motion
/// de presión (se hunde 3px al tocar; reduce-motion la deja fija).
class _LipCard extends StatefulWidget {
  const _LipCard({required this.child, this.onTap, this.padding = const EdgeInsets.all(15)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  @override
  State<_LipCard> createState() => _LipCardState();
}

class _LipCardState extends State<_LipCard> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final pressed = _down && !reduce && widget.onTap != null;
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _down = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, pressed ? 3 : 0, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFECEDF6), offset: Offset(0, pressed ? 2 : 5), blurRadius: 0),
            const BoxShadow(color: Color(0x143C3778), offset: Offset(0, 12), blurRadius: 22),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Chip-botón redondo con labio (aceptar/rechazar solicitudes — acciones obvias).
class _RoundAction extends StatelessWidget {
  const _RoundAction(
      {super.key, required this.icon, required this.color, required this.depth, this.onTap});
  final IconData icon;
  final Color color, depth;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: depth, offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entradas del HUB de Conversar (solo si hay acceso social)
// ─────────────────────────────────────────────────────────────────────────────
class FriendsEntryCard extends ConsumerWidget {
  const FriendsEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(socialStatusProvider);
    final hasAccess = status.maybeWhen(data: (s) => s['access'] == true, orElse: () => false);
    if (!hasAccess) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final friends = ref.watch(friendsProvider).maybeWhen(
        data: (d) => (d['friends'] as List?) ?? const [], orElse: () => const []);
    final pending = ref.watch(friendsProvider).maybeWhen(
        data: (d) => ((d['incoming'] as List?) ?? const []).length, orElse: () => 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: _LipCard(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const FriendsScreen())),
        child: Row(
          children: [
            // Pila de avatares REALES (hasta 3) o icon-tile si aún no hay amigos.
            if (friends.isEmpty)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.forum_rounded, color: AppColors.primary, size: 26),
              )
            else
              SizedBox(
                width: 50.0 + (friends.length.clamp(1, 3) - 1) * 18.0,
                height: 50,
                child: Stack(children: [
                  for (var i = friends.length.clamp(1, 3) - 1; i >= 0; i--)
                    Positioned(
                      left: i * 18.0,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.5),
                            border: Border.all(color: Colors.white, width: 2.5)),
                        child: _Squircle(
                            color: (friends[i]['avatar_color'] ?? '#6C5CE7').toString(),
                            letter: (friends[i]['name'] ?? '?').toString(),
                            size: 45),
                      ),
                    ),
                ]),
              ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(l10n.convFriendsTitle,
                        style: const TextStyle(
                            fontSize: 16.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                  ),
                  if (pending > 0) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.hearts, borderRadius: BorderRadius.circular(9)),
                      child: Text('$pending',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(l10n.convFriendsSubtitle,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Entrada al CO-OP en el hub — la tarjeta "RETO EN PAREJA" del mockup 1:1
/// (gradiente violeta claro + dos avatares solapados con corazón).
class CoopEntryCard extends ConsumerWidget {
  const CoopEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(socialStatusProvider);
    final hasAccess = status.maybeWhen(data: (s) => s['access'] == true, orElse: () => false);
    if (!hasAccess) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GestureDetector(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CoopScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEDEBFF), Color(0xFFF3F0FF)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Color(0xFFDAD5F7), offset: Offset(0, 5), blurRadius: 0),
              BoxShadow(color: Color(0x1F6C5CE7), offset: Offset(0, 12), blurRadius: 22),
            ],
          ),
          child: Row(children: [
            _PairArt(youLabel: l10n.convCoopYou),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.convCoopEntry.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: AppColors.primary)),
                const SizedBox(height: 3),
                Text(l10n.convCoopEntrySub,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: AppColors.text)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ]),
        ),
      ),
    );
  }
}

/// Los dos avatares solapados con corazón del mockup (co-op).
class _PairArt extends StatelessWidget {
  const _PairArt({required this.youLabel, this.partnerColor, this.partnerLetter});
  final String youLabel;
  final String? partnerColor, partnerLetter;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 52,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          left: 0,
          top: 8,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8C7DF2), AppColors.primary]),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x4D6C5CE7), blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: FittedBox(
                child: Text(youLabel,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 8,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: partnerColor != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_lighten(_hex(partnerColor!)), _hex(partnerColor!)])
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF8C8C), Color(0xFFFF5C5C)]),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x4DFF5C5C), blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: partnerLetter != null
                ? Text(partnerLetter![0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900))
                : const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
        ),
        Positioned(
          left: 25,
          top: -4,
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 13),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AMIGOS — hub de amistades: código destacado, agregar, solicitudes, lista.
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

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).convCodeCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(socialStatusProvider);
    final myCode = status.maybeWhen(data: (s) => s['friend_code'] as String?, orElse: () => null);
    final friends = ref.watch(friendsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.convFriendsTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(friendsProvider);
              ref.invalidate(coopsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
              children: [
                _CodeHero(code: myCode, onCopy: myCode == null ? null : () => _copyCode(myCode)),
                const SizedBox(height: 14),
                // Agregar por código — un solo gesto obvio.
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
                          ],
                        ),
                        child: TextField(
                          controller: _code,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 7,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _addByCode(),
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 3),
                          decoration: InputDecoration(
                            hintText: l10n.convEnterCode,
                            hintStyle: const TextStyle(
                                fontSize: 13.5,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted),
                            counterText: '',
                            prefixIcon: const Icon(Icons.person_add_alt_1_rounded,
                                color: AppColors.primary, size: 21),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PrimaryButton(
                      label: l10n.convAddFriend,
                      onPressed: (_code.text.trim().isNotEmpty && !_sending) ? _addByCode : null,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(children: [
                  const Icon(Icons.shield_rounded, size: 14, color: Color(0xFFA7ABC3)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l10n.convContactFilterNote,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted)),
                  ),
                ]),
                const SizedBox(height: 18),
                friends.when(
                  loading: () => const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary))),
                  error: (_, _) => _ErrorRetry(onRetry: () => ref.invalidate(friendsProvider)),
                  data: (data) {
                    final incoming = (data['incoming'] as List?) ?? const [];
                    final list = (data['friends'] as List?) ?? const [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (incoming.isNotEmpty) ...[
                          Row(children: [
                            Text(l10n.convRequests.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    color: AppColors.textMuted)),
                            const SizedBox(width: 7),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                              decoration: BoxDecoration(
                                  color: AppColors.hearts,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Text('${incoming.length}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white)),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          for (final r in incoming)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _LipCard(
                                padding: const EdgeInsets.all(12),
                                child: Row(children: [
                                  _Squircle(
                                      color: (r['avatar_color'] ?? '#6C5CE7').toString(),
                                      letter: (r['name'] ?? '?').toString(),
                                      size: 46),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text((r['name'] ?? '').toString(),
                                        style: const TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.w900)),
                                  ),
                                  _RoundAction(
                                      icon: Icons.close_rounded,
                                      color: const Color(0xFFB3B8CC),
                                      depth: const Color(0xFF9AA0B8),
                                      onTap: () =>
                                          _respond(r['connection_id'].toString(), false)),
                                  const SizedBox(width: 8),
                                  _RoundAction(
                                      icon: Icons.check_rounded,
                                      color: AppColors.success,
                                      depth: AppColors.successDark,
                                      onTap: () =>
                                          _respond(r['connection_id'].toString(), true)),
                                ]),
                              ),
                            ),
                          const SizedBox(height: 12),
                        ],
                        if (list.isEmpty)
                          _EmptyFriends(
                              onCopyCode: myCode == null ? null : () => _copyCode(myCode))
                        else ...[
                          Text(l10n.convFriendsTitle.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: AppColors.textMuted)),
                          const SizedBox(height: 10),
                          for (final f in list)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _FriendRow(
                                name: (f['name'] ?? '').toString(),
                                color: (f['avatar_color'] ?? '#6C5CE7').toString(),
                                streak: (f['streak'] as num?)?.toInt() ?? 0,
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    connectionId: f['connection_id'].toString(),
                                    friendId: f['user_id'].toString(),
                                    friendName: (f['name'] ?? '').toString(),
                                    friendColor:
                                        (f['avatar_color'] ?? '#6C5CE7').toString(),
                                    streak: (f['streak'] as num?)?.toInt() ?? 0,
                                  ),
                                )),
                              ),
                            ),
                        ],
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

/// Tarjeta HERO del código de amigo — lo primero y lo más fácil de la pantalla.
class _CodeHero extends StatefulWidget {
  const _CodeHero({required this.code, required this.onCopy});
  final String? code;
  final VoidCallback? onCopy;
  @override
  State<_CodeHero> createState() => _CodeHeroState();
}

class _CodeHeroState extends State<_CodeHero> {
  bool _copied = false;
  Timer? _revert;

  @override
  void dispose() {
    _revert?.cancel();
    super.dispose();
  }

  void _tapCopy() {
    if (widget.onCopy == null) return;
    widget.onCopy!();
    setState(() => _copied = true);
    _revert?.cancel();
    _revert = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0xFF4B3FC9), offset: Offset(0, 5), blurRadius: 0),
          BoxShadow(color: Color(0x336C5CE7), offset: Offset(0, 14), blurRadius: 24),
        ],
      ),
      child: Row(children: [
        const ParrotMascot(size: 52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.convYourCode.toUpperCase(),
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.75))),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Text(widget.code ?? '·······',
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3)),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        // Copiar con feedback claro: el botón se vuelve verde con ✓ un instante.
        GestureDetector(
          onTap: _tapCopy,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _copied ? AppColors.success : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: _copied ? AppColors.successDark : const Color(0xFFD8D3F5),
                    offset: const Offset(0, 4),
                    blurRadius: 0),
              ],
            ),
            child: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded,
                color: _copied ? Colors.white : AppColors.primary, size: 22),
          ),
        ),
      ]),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends({required this.onCopyCode});
  final VoidCallback? onCopyCode;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(children: [
        const ParrotMascot(size: 92, mood: MascotMood.encourage),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(l10n.convNoFriends,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, height: 1.4, color: AppColors.textMuted)),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
            label: l10n.convCopyMyCode, icon: Icons.copy_rounded, onPressed: onCopyCode),
      ]),
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
      padding: const EdgeInsets.only(top: 18),
      child: Column(children: [
        const ParrotMascot(size: 84, mood: MascotMood.encourage),
        const SizedBox(height: 12),
        PrimaryButton(label: l10n.commonRetry, icon: Icons.refresh_rounded, onPressed: onRetry),
      ]),
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
    final l10n = AppLocalizations.of(context);
    return _LipCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        _Squircle(color: color, letter: name, size: 50),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 2),
            Text(l10n.convTapToChat,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ]),
        ),
        const SizedBox(width: 8),
        if (streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF0E0), borderRadius: BorderRadius.circular(12)),
            child: _StreakPulse(streak: streak),
          )
        else
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.primary),
          ),
      ]),
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
      const Text('🔥', style: TextStyle(fontSize: 15)),
      const SizedBox(width: 3),
      Text('${widget.streak}',
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.streak)),
    ]);
    if (reduce) return fire;
    return ScaleTransition(
      scale:
          Tween(begin: 0.94, end: 1.08).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: fire,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT 1:1 (Realtime) — burbujas modernas + notas de voz + corrección inline.
// ─────────────────────────────────────────────────────────────────────────────
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.connectionId,
    required this.friendId,
    required this.friendName,
    this.friendColor = '#6C5CE7',
    this.streak = 0,
  });
  final String connectionId, friendId, friendName, friendColor;
  final int streak;
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msg = TextEditingController();
  final VoiceRecorder _rec = VoiceRecorder();
  bool _sending = false;
  bool _recording = false;
  bool _uploadingVoice = false;
  int _recSeconds = 0;
  Timer? _recTimer;

  /// Correcciones por message_id (vienen de list_messages; el stream Realtime
  /// solo trae la tabla messages). Se refresca al abrir, al corregir y cuando
  /// llegan mensajes nuevos.
  Map<String, Map<String, dynamic>> _corrections = {};
  int _lastMsgCount = -1;

  @override
  void initState() {
    super.initState();
    _msg.addListener(_onTextChanged);
    _loadCorrections();
  }

  void _onTextChanged() {
    if (mounted) setState(() {}); // alterna 🎤 ↔ ➤ según haya texto
  }

  Future<void> _loadCorrections() async {
    try {
      final msgs =
          await ref.read(progressRepositoryProvider).listChatMessages(widget.connectionId);
      final map = <String, Map<String, dynamic>>{};
      for (final m in msgs) {
        final c = m['correction'];
        if (c is Map && c['corrected'] != null) {
          map[m['id'].toString()] = Map<String, dynamic>.from(c);
        }
      }
      if (mounted) setState(() => _corrections = map);
    } catch (_) {}
  }

  @override
  void dispose() {
    _recTimer?.cancel();
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
      if (mounted) {
        setState(() {
          _recording = true;
          _recSeconds = 0;
        });
        _recTimer?.cancel();
        _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _recSeconds++);
        });
      }
    } else {
      _recTimer?.cancel();
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
    _recTimer?.cancel();
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 14, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE1E3EE), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Row(children: [
            const Icon(Icons.edit_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(l10n.convCorrect,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F7FB),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
              label: l10n.convSendCorrection,
              color: AppColors.success,
              depthColor: AppColors.successDark,
              expand: true,
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim())),
        ]),
      ),
    );
    if (result != null && result.isNotEmpty) {
      await repo.addCorrection(m['id'].toString(), result, null);
      await _loadCorrections();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(progressRepositoryProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        shape: const Border(bottom: BorderSide(color: Color(0xFFE9EAF2))),
        title: Row(children: [
          _Squircle(color: widget.friendColor, letter: widget.friendName, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.friendName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
              if (widget.streak > 0)
                Text('🔥 ${widget.streak}',
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.streak)),
            ]),
          ),
        ]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
            onSelected: _blockOrReport,
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'report',
                  child: Row(children: [
                    const Icon(Icons.flag_rounded, size: 19, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Text(l10n.convReport),
                  ])),
              PopupMenuItem(
                  value: 'block',
                  child: Row(children: [
                    const Icon(Icons.block_rounded, size: 19, color: AppColors.hearts),
                    const SizedBox(width: 10),
                    Text(l10n.convBlock),
                  ])),
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
                    // El stream no trae correcciones: refresca el mapa cuando
                    // cambia el nº de mensajes (llegó algo nuevo).
                    if (msgs.length != _lastMsgCount) {
                      _lastMsgCount = msgs.length;
                      if (msgs.isNotEmpty) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _loadCorrections());
                      }
                    }
                    if (msgs.isEmpty) {
                      return Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const ParrotMascot(size: 92, mood: MascotMood.encourage),
                          const SizedBox(height: 10),
                          Text(l10n.convChatEmpty,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted)),
                        ]),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      itemCount: msgs.length,
                      itemBuilder: (context, i) {
                        final m = msgs[msgs.length - 1 - i];
                        final mine = m['sender_id'].toString() == repo.currentUserId;
                        final isVoice = (m['kind'] ?? '').toString() == 'voice';
                        final correction = _corrections[m['id'].toString()];
                        return _Bubble(
                          mine: mine,
                          time: _fmtTime((m['created_at'] ?? '').toString()),
                          correction: correction,
                          onCorrect: (mine || isVoice) ? null : () => _correct(m),
                          child: isVoice
                              ? _VoiceBubble(
                                  path: (m['audio_url'] ?? '').toString(),
                                  mine: mine,
                                  repo: repo)
                              : Text((m['body'] ?? '').toString(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                      color: mine ? Colors.white : AppColors.text)),
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
                recSeconds: _recSeconds,
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

String _fmtTime(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '';
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Burbuja moderna: la mía violeta con "cola" (esquina inferior derecha recta),
/// la del amigo blanca con labio; hora abajo; corrección inline si existe.
/// Entra con un fade+deslizamiento sutil (reduce-motion la pinta fija).
class _Bubble extends StatelessWidget {
  const _Bubble(
      {required this.mine,
      required this.time,
      required this.child,
      this.correction,
      this.onCorrect});
  final bool mine;
  final String time;
  final Widget child;
  final Map<String, dynamic>? correction;
  final VoidCallback? onCorrect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 6),
      bottomRight: Radius.circular(mine ? 6 : 18),
    );
    final bubble = Column(
      crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
          decoration: BoxDecoration(
            gradient: mine
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7A6BF0), AppColors.primary])
                : null,
            color: mine ? null : Colors.white,
            borderRadius: radius,
            boxShadow: mine
                ? const [BoxShadow(color: Color(0x2E6C5CE7), offset: Offset(0, 5), blurRadius: 12)]
                : const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 3), blurRadius: 0)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              if (correction != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: mine ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFEAF7EC),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.edit_rounded,
                          size: 13, color: mine ? Colors.white : AppColors.successDark),
                      const SizedBox(width: 5),
                      Text(l10n.convCorrectionLabel,
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: mine ? Colors.white : AppColors.successDark)),
                    ]),
                    const SizedBox(height: 3),
                    Text((correction!['corrected'] ?? '').toString(),
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: mine ? Colors.white : const Color(0xFF1E7A44))),
                    if ((correction!['note'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text((correction!['note']).toString(),
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: mine
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : AppColors.textMuted)),
                      ),
                  ]),
                ),
              ],
              if (time.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(time,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: mine
                              ? Colors.white.withValues(alpha: 0.7)
                              : const Color(0xFFB3B8CC))),
                ),
            ],
          ),
        ),
      ],
    );
    final aligned = Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(onLongPress: onCorrect, child: bubble),
    );
    if (reduce) return aligned;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOut,
      builder: (context, v, w) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 8), child: w),
      ),
      child: aligned,
    );
  }
}

/// Nota de voz: botón de play + forma de onda decorativa (barras deterministas
/// por path) que "respira" mientras suena. URL firmada al tocar (bucket privado).
class _VoiceBubble extends StatefulWidget {
  const _VoiceBubble({required this.path, required this.mine, required this.repo});
  final String path;
  final bool mine;
  final dynamic repo;
  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> with SingleTickerProviderStateMixin {
  bool _loading = false;
  bool _playing = false;
  late final AnimationController _wave =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_loading || _playing || widget.path.isEmpty) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    try {
      final url = await widget.repo.signedVoiceUrl(widget.path) as String;
      if (!mounted) return;
      setState(() {
        _loading = false;
        _playing = true;
      });
      if (!reduce) _wave.repeat(reverse: true);
      await AudioEngine.instance.playUrl(url, onComplete: () {
        if (mounted) {
          _wave.stop();
          setState(() => _playing = false);
        }
      });
    } catch (_) {
      if (mounted) {
        _wave.stop();
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
    final fg = widget.mine ? Colors.white : AppColors.primary;
    // Alturas deterministas por path (decorativas, estables entre builds).
    final seed = widget.path.hashCode;
    final heights = List<double>.generate(13, (i) => 6.0 + ((seed >> (i * 2)) & 7) * 2.2);
    return InkWell(
      onTap: _play,
      borderRadius: BorderRadius.circular(12),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.mine ? Colors.white.withValues(alpha: 0.22) : AppColors.navActiveBg,
            shape: BoxShape.circle,
          ),
          child: _loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: fg))
              : Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: fg, size: 23),
        ),
        const SizedBox(width: 9),
        AnimatedBuilder(
          animation: _wave,
          builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < heights.length; i++)
              Container(
                width: 3,
                height: _playing
                    ? heights[i] * (0.65 + 0.35 * ((_wave.value + i / heights.length) % 1))
                    : heights[i],
                margin: const EdgeInsets.symmetric(horizontal: 1.4),
                decoration: BoxDecoration(
                  color: widget.mine
                      ? Colors.white.withValues(alpha: _playing ? 0.95 : 0.75)
                      : AppColors.primary.withValues(alpha: _playing ? 0.9 : 0.55),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

/// Composer: campo pill + botón circular 3D que alterna 🎤 ↔ ➤ (AnimatedSwitcher).
/// Grabando: barra con punto rojo pulsante + segundos + cancelar + enviar verde.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.recording,
    required this.uploadingVoice,
    required this.recSeconds,
    required this.onSend,
    required this.onVoice,
    required this.onCancelVoice,
    required this.hint,
    required this.recordingLabel,
  });
  final TextEditingController controller;
  final bool sending, recording, uploadingVoice;
  final int recSeconds;
  final VoidCallback onSend, onVoice, onCancelVoice;
  final String hint, recordingLabel;

  @override
  Widget build(BuildContext context) {
    if (recording) {
      final mm = (recSeconds ~/ 60).toString();
      final ss = (recSeconds % 60).toString().padLeft(2, '0');
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Row(children: [
          IconButton(
              onPressed: onCancelVoice,
              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted)),
          const _RecordingDot(),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$recordingLabel · $mm:$ss',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.text)),
          ),
          _RoundAction(
              icon: Icons.send_rounded,
              color: AppColors.success,
              depth: AppColors.successDark,
              onTap: onVoice),
        ]),
      );
    }
    final hasText = controller.text.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
                ],
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w),
            child: hasText
                ? _RoundAction(
                    key: const ValueKey('send'),
                    icon: Icons.send_rounded,
                    color: AppColors.primary,
                    depth: AppColors.primaryDark,
                    onTap: sending ? null : onSend)
                : uploadingVoice
                    ? Container(
                        key: const ValueKey('up'),
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                        child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white)),
                      )
                    : _RoundAction(
                        key: const ValueKey('mic'),
                        icon: Icons.mic_rounded,
                        color: AppColors.primary,
                        depth: AppColors.primaryDark,
                        onTap: onVoice),
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
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
        ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final dot = Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(color: Color(0xFFE74C3C), shape: BoxShape.circle));
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 14),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE1E3EE), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.convCoopWith,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          for (final f in friends)
            ListTile(
              leading: _Squircle(
                  color: (f['avatar_color'] ?? '#6C5CE7').toString(),
                  letter: (f['name'] ?? '?').toString(),
                  size: 42),
              title: Text((f['name'] ?? '').toString(),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              onTap: () => Navigator.of(ctx).pop(Map<String, dynamic>.from(f as Map)),
            ),
          const SizedBox(height: 10),
        ]),
      ),
    );
    if (picked == null || !context.mounted) return;
    final goal = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 14),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE1E3EE), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.convCoopPickGoal,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          for (final xp in const [100, 300, 500])
            ListTile(
              leading: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E0), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.bolt_rounded, color: AppColors.streak),
              ),
              title: Text('$xp XP', style: const TextStyle(fontWeight: FontWeight.w900)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              onTap: () => Navigator.of(ctx).pop(xp),
            ),
          const SizedBox(height: 10),
        ]),
      ),
    );
    if (goal == null) return;
    try {
      await ref.read(progressRepositoryProvider).createCoop(picked['user_id'].toString(), goal);
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.convCoopTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createFlow(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.convCoopStart,
            style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(coopsProvider),
            child: coops.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, _) => Center(
                  child: _ErrorRetry(onRetry: () => ref.invalidate(coopsProvider))),
              data: (list) {
                if (list.isEmpty) {
                  return ListView(children: [
                    const SizedBox(height: 56),
                    const Center(child: ParrotMascot(size: 100, mood: MascotMood.encourage)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(l10n.convCoopEmpty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              color: AppColors.textMuted)),
                    ),
                  ]);
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
                  children: [
                    Text(l10n.convCoopSubtitle,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted)),
                    const SizedBox(height: 14),
                    for (final c in list)
                      _CoopCard(
                        coop: c,
                        youLabel: l10n.convCoopYou,
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
  const _CoopCard(
      {required this.coop,
      required this.youLabel,
      required this.onAccept,
      required this.onReject});
  final Map<String, dynamic> coop;
  final String youLabel;
  final VoidCallback onAccept, onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
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

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: completed ? const Color(0xFFCBEEDB) : const Color(0xFFECEDF6),
              offset: const Offset(0, 5),
              blurRadius: 0),
          const BoxShadow(color: Color(0x143C3778), offset: Offset(0, 12), blurRadius: 22),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _PairArt(youLabel: youLabel, partnerColor: color, partnerLetter: name.isNotEmpty ? name : '?'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(9)),
                  child: Text(badgeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w900, color: badgeColor)),
                ),
              ]),
            ),
          ]),
          if (completed) ...[
            const SizedBox(height: 13),
            JzSheen(
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.goldCtaTop, AppColors.goldCtaBottom]),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text('🎉  +$reward 🪙',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF5B3A00))),
              ),
            ),
          ] else if (invited && !iCreated) ...[
            const SizedBox(height: 8),
            Text(l10n.convCoopProgress(0, target),
                style:
                    const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Row(children: [
              _RoundAction(
                  icon: Icons.close_rounded,
                  color: const Color(0xFFB3B8CC),
                  depth: const Color(0xFF9AA0B8),
                  onTap: onReject),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                    label: l10n.convCoopAccept,
                    color: AppColors.success,
                    depthColor: AppColors.successDark,
                    expand: true,
                    onPressed: onAccept),
              ),
            ]),
          ] else ...[
            const SizedBox(height: 13),
            // Barra de progreso VIVA (anima hasta el valor real al construir).
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct),
                duration: reduce ? Duration.zero : const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFEDEEF6),
                  valueColor: AlwaysStoppedAnimation(
                      expired ? const Color(0xFFB3B8CC) : AppColors.streak),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l10n.convCoopProgress(progress, target),
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
              Flexible(
                child: Text(l10n.convCoopReward(reward),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted)),
              ),
            ]),
          ],
        ],
      ),
    );
    return card;
  }
}
