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

/// Traduce el error REAL del servidor a un mensaje claro. Antes TODO fallo se
/// mostraba como "revisa el código" (el bug #1: "ya son amigos", "es tu propio
/// código", "18+", rate limit… todos quedaban ocultos). `fallback` = mensaje por
/// defecto según el origen (por código vs por perfil/búsqueda).
String friendErrorMessage(Object e, AppLocalizations l10n, String fallback) {
  final s = e.toString().toLowerCase();
  if (s.contains('already friends')) return l10n.convErrAlready;
  if (s.contains('cannot add yourself')) return l10n.convErrSelf;
  if (s.contains('rate_limited')) return l10n.convErrRate;
  if (s.contains('social unavailable') || s.contains('account restricted')) {
    return l10n.convErrUnavailable;
  }
  if (s.contains('unavailable')) return l10n.convErrBlocked;
  return fallback;
}

/// Mensaje de éxito: si el envío auto-aceptó (solicitud mutua) → "ya son amigos".
String sentFriendMessage(Object? result, AppLocalizations l10n) {
  final status = (result is Map) ? result['status'] : null;
  return status == 'accepted' ? l10n.convNowFriends : l10n.convRequestSent;
}

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

/// Sugerencias de amigos (mismo curso/nivel cercano). T3.
final suggestionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(progressRepositoryProvider).suggestFriends();
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
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _searching = false;
  List<Map<String, dynamic>> _results = const [];

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    final q = v.trim();
    setState(() => _query = q);
    _debounce?.cancel();
    if (q.length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 320), _runSearch);
  }

  Future<void> _runSearch() async {
    final q = _query;
    if (q.length < 2) return;
    try {
      final r = await ref.read(progressRepositoryProvider).searchUsers(q);
      if (mounted && _query == q) setState(() => _results = r);
    } catch (_) {
      if (mounted && _query == q) setState(() => _results = const []);
    } finally {
      if (mounted && _query == q) setState(() => _searching = false);
    }
  }

  Future<void> _openProfile(String userId) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PublicProfileScreen(userId: userId),
    ));
    ref.invalidate(friendsProvider);
    ref.invalidate(suggestionsProvider);
    if (_query.length >= 2) _runSearch();
  }

  Future<void> _addByUserId(String userId) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final r = await ref.read(progressRepositoryProvider).requestFriend(userId);
      messenger.showSnackBar(SnackBar(content: Text(sentFriendMessage(r, l10n))));
      ref.invalidate(friendsProvider);
      ref.invalidate(suggestionsProvider);
      if (_query.length >= 2) _runSearch();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendErrorMessage(e, l10n, l10n.convAddError))));
    }
  }

  Future<void> _toggleDiscoverable(bool on) async {
    try {
      await ref.read(progressRepositoryProvider).setDiscoverable(on);
    } catch (_) {}
    ref.invalidate(socialStatusProvider);
  }

  Future<void> _respond(String connectionId, bool accept) async {
    await ref.read(progressRepositoryProvider).respondFriendRequest(connectionId, accept);
    ref.invalidate(friendsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(socialStatusProvider);
    final myHandle = status.maybeWhen(data: (s) => s['handle'] as String?, orElse: () => null);
    final needsHandle =
        status.maybeWhen(data: (s) => s['needs_handle'] == true, orElse: () => false);
    final discoverable =
        status.maybeWhen(data: (s) => s['discoverable'] != false, orElse: () => true);
    // GATE: para usar lo social hay que elegir @usuario (no se puede saltar).
    if (needsHandle) {
      return HandleGateScreen(onDone: () => ref.invalidate(socialStatusProvider));
    }
    final friends = ref.watch(friendsProvider);
    final searching = _query.length >= 2;
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
                // Tu @usuario (identidad social) — pequeño y claro.
                if (myHandle != null) ...[
                  _HandleChip(handle: myHandle),
                  const SizedBox(height: 12),
                ],
                // BUSCADOR por @usuario / nombre — la ÚNICA vía de agregar amigos.
                _SearchField(
                  controller: _search,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _search.clear();
                    _onSearchChanged('');
                  },
                ),
                const SizedBox(height: 14),
                if (searching)
                  _SearchResults(
                    query: _query,
                    searching: _searching,
                    results: _results,
                    onOpen: _openProfile,
                    onAdd: _addByUserId,
                  )
                else ...[
                  // Sugerencias (mismo idioma) — descubrimiento inocuo.
                  _SuggestionsStrip(onOpen: _openProfile, onAdd: _addByUserId),
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
                          const _EmptyFriends()
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
                  const SizedBox(height: 20),
                  _DiscoverableTile(value: discoverable, onChanged: _toggleDiscoverable),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends();
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

  /// Stream Realtime creado UNA sola vez (no en cada build). Antes vivía en
  /// `stream:` dentro de build() → cada rebuild (incl. cada tecla) re-suscribía
  /// el canal Realtime = el LAG del chat. Se fija aquí y no vuelve a crearse.
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = ref.read(progressRepositoryProvider).chatMessagesStream(widget.connectionId);
    _loadCorrections();
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
                  stream: _stream,
                  builder: (context, snap) {
                    // Orden CRONOLÓGICO explícito (el stream Realtime puede venir
                    // descendente → antes los nuevos salían ARRIBA). created_at ISO
                    // ordena lexicográfico = cronológico. Con reverse:true, el más
                    // reciente queda ABAJO y la vista se ancla al último mensaje.
                    final msgs = [...(snap.data ?? const <Map<String, dynamic>>[])]
                      ..sort((a, b) => (a['created_at'] ?? '')
                          .toString()
                          .compareTo((b['created_at'] ?? '').toString()));
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
          // Solo el botón 🎤↔➤ se reconstruye al teclear (ValueListenableBuilder
          // sobre el controller) → escribir NO reconstruye la lista de mensajes.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return AnimatedSwitcher(
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
            );
            },
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

// ═════════════════════════════════════════════════════════════════════════════
// T3 · social fácil: @handle gate + buscar + sugerencias + perfil público
// (capa VISUAL; la lógica y la RLS viven en el servidor, mig 149).
// ═════════════════════════════════════════════════════════════════════════════

/// Chip "@usuario" — identidad social del usuario.
class _HandleChip extends StatelessWidget {
  const _HandleChip({required this.handle});
  final String handle;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.navActiveBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.alternate_email_rounded, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(children: [
              TextSpan(
                  text: '${l10n.convHandleChip}  ',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              TextSpan(
                  text: '@$handle',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Buscador de amigos por nombre o @handle.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged, required this.onClear});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: l10n.convSearchHint,
          hintStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 19, color: AppColors.textMuted),
                  onPressed: onClear),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

/// Resultados de búsqueda (o estados vacío/cargando).
class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.searching,
    required this.results,
    required this.onOpen,
    required this.onAdd,
  });
  final String query;
  final bool searching;
  final List<Map<String, dynamic>> results;
  final void Function(String userId) onOpen;
  final void Function(String userId) onAdd;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (searching) {
      return const Padding(
        padding: EdgeInsets.all(28),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: Column(children: [
          const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFFC7CBDD)),
          const SizedBox(height: 10),
          Text(l10n.convSearchNoResults(query),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ]),
      );
    }
    return Column(children: [
      for (final r in results)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SearchResultRow(data: r, onOpen: onOpen, onAdd: onAdd),
        ),
    ]);
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.data, required this.onOpen, required this.onAdd});
  final Map<String, dynamic> data;
  final void Function(String userId) onOpen;
  final void Function(String userId) onAdd;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = data['user_id'].toString();
    final name = (data['name'] ?? '').toString();
    final handle = data['handle'] as String?;
    final rel = (data['relationship'] ?? 'none').toString();
    return _LipCard(
      onTap: () => onOpen(id),
      padding: const EdgeInsets.all(11),
      child: Row(children: [
        _Squircle(color: (data['avatar_color'] ?? '#6C5CE7').toString(), letter: name, size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            if (handle != null) ...[
              const SizedBox(height: 1),
              Text('@$handle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        _relTrailing(context, l10n, rel, () => onAdd(id)),
      ]),
    );
  }
}

/// El control de la derecha según la relación (agregar / pendiente / amigos).
Widget _relTrailing(
    BuildContext context, AppLocalizations l10n, String rel, VoidCallback onAdd) {
  switch (rel) {
    case 'none':
      return _RoundAction(
          icon: Icons.person_add_alt_1_rounded,
          color: AppColors.primary,
          depth: const Color(0xFF4B3FC9),
          onTap: onAdd);
    case 'pending_out':
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFF0F0F6), borderRadius: BorderRadius.circular(10)),
        child: Text(l10n.convPendingSent,
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
      );
    case 'pending_in':
      return _RoundAction(
          icon: Icons.how_to_reg_rounded,
          color: AppColors.success,
          depth: AppColors.successDark,
          onTap: onAdd);
    case 'friends':
      return const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 22);
    default:
      return const Icon(Icons.chevron_right_rounded, color: Color(0xFFC7CBDD), size: 22);
  }
}

/// Carrusel de sugerencias de amigos (mismo idioma/nivel cercano).
class _SuggestionsStrip extends ConsumerWidget {
  const _SuggestionsStrip({required this.onOpen, required this.onAdd});
  final void Function(String userId) onOpen;
  final void Function(String userId) onAdd;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sug = ref.watch(suggestionsProvider);
    return sug.maybeWhen(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFFFF8A3D)),
            const SizedBox(width: 6),
            Text(l10n.convSuggestionsTitle.toUpperCase(),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            height: 178,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) =>
                  _SuggestionCard(data: list[i], onOpen: onOpen, onAdd: onAdd),
            ),
          ),
          const SizedBox(height: 18),
        ]);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.data, required this.onOpen, required this.onAdd});
  final Map<String, dynamic> data;
  final void Function(String userId) onOpen;
  final void Function(String userId) onAdd;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = data['user_id'].toString();
    final name = (data['name'] ?? '').toString();
    final handle = data['handle'] as String?;
    final level = (data['level'] ?? '').toString();
    return SizedBox(
      width: 138,
      child: _LipCard(
        onTap: () => onOpen(id),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          _Squircle(color: (data['avatar_color'] ?? '#6C5CE7').toString(), letter: name, size: 52),
          const SizedBox(height: 8),
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
          if (handle != null)
            Text('@$handle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 6),
          if (level.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(8)),
              child: Text(level,
                  style: const TextStyle(
                      fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(label: l10n.convAddFriend, onPressed: () => onAdd(id)),
          ),
        ]),
      ),
    );
  }
}

/// Toggle de privacidad: aparecer o no en búsqueda/sugerencias.
class _DiscoverableTile extends StatelessWidget {
  const _DiscoverableTile({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _LipCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(11)),
          child: Icon(value ? Icons.travel_explore_rounded : Icons.visibility_off_rounded,
              size: 19, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.convDiscoverable,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 1),
            Text(l10n.convDiscoverableSub,
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ]),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.success,
        ),
      ]),
    );
  }
}

/// GATE de @usuario — pantalla dedicada, no se puede saltar para usar lo social.
class HandleGateScreen extends ConsumerStatefulWidget {
  const HandleGateScreen({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  ConsumerState<HandleGateScreen> createState() => _HandleGateScreenState();
}

class _HandleGateScreenState extends ConsumerState<HandleGateScreen> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  String? _error;
  int _pendingIncoming = 0;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  /// ¿Ya me llegaron solicitudes aunque aún no tenga @usuario? list_friends solo
  /// exige adulto (no handle) → podemos avisar en el gate en vez de dejar una
  /// pantalla muerta. Best-effort: si falla, no pasa nada.
  Future<void> _loadPending() async {
    try {
      final f = await ref.read(progressRepositoryProvider).listFriends();
      final n = (f['incoming'] as List?)?.length ?? 0;
      if (mounted && n != _pendingIncoming) setState(() => _pendingIncoming = n);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _valid {
    final v = _ctrl.text.trim().toLowerCase().replaceAll('@', '');
    return RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(v) && RegExp(r'[a-z]').hasMatch(v);
  }

  Future<void> _submit() async {
    if (!_valid || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(progressRepositoryProvider).claimHandle(_ctrl.text.trim());
      widget.onDone();
    } catch (e) {
      final s = e.toString();
      setState(() {
        _error = s.contains('handle_taken')
            ? l10n.handleGateTaken
            : s.contains('handle_reserved')
                ? l10n.handleGateReserved
                : s.contains('handle_change_rate')
                    ? l10n.handleGateRateLimit
                    : s.contains('invalid_handle')
                        ? l10n.handleGateInvalid
                        : l10n.handleGateError;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          maxWidth: 480,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            children: [
              const SizedBox(height: 8),
              const Center(child: ParrotMascot(size: 92, mood: MascotMood.encourage)),
              const SizedBox(height: 18),
              Text(l10n.handleGateTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              Text(l10n.handleGateSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              // Si YA recibió solicitudes (aunque aún no tenga @usuario), avísale
              // claramente que están esperando — no una pantalla muerta. list_friends
              // funciona sin handle (solo exige adulto).
              if (_pendingIncoming > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.hearts.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.hearts.withValues(alpha: 0.30), width: 1.5),
                  ),
                  child: Row(children: [
                    const Icon(Icons.mark_email_unread_rounded, color: AppColors.hearts, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l10n.handleGatePendingHint,
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.3)),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
                  ],
                ),
                child: TextField(
                  controller: _ctrl,
                  autocorrect: false,
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _submit(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_@]')),
                    LengthLimitingTextInputFormatter(21),
                  ],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  decoration: InputDecoration(
                    hintText: l10n.handleGateHint,
                    hintStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.alternate_email_rounded,
                        color: AppColors.primary, size: 21),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(_error ?? l10n.handleGateRules,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _error != null ? AppColors.hearts : AppColors.textMuted)),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: l10n.handleGateSave,
                  onPressed: (_valid && !_busy) ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// PERFIL PÚBLICO — superficie acotada (nunca email/edad/datos privados).
class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({super.key, required this.userId});
  final String userId;
  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _future = ref.read(progressRepositoryProvider).getPublicProfile(widget.userId);
  }

  void _reload() {
    setState(() {
      _future = ref.read(progressRepositoryProvider).getPublicProfile(widget.userId);
    });
  }

  Future<void> _add() async {
    if (_acting) return;
    setState(() => _acting = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final r = await ref.read(progressRepositoryProvider).requestFriend(widget.userId);
      messenger.showSnackBar(SnackBar(content: Text(sentFriendMessage(r, l10n))));
      ref.invalidate(friendsProvider);
      ref.invalidate(suggestionsProvider);
      _reload();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendErrorMessage(e, l10n, l10n.convAddError))));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _block() async {
    final l10n = AppLocalizations.of(context);
    final nav = Navigator.of(context);
    await ref.read(progressRepositoryProvider).blockUser(widget.userId);
    ref.invalidate(friendsProvider);
    ref.invalidate(suggestionsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.convBlock)));
      nav.pop();
    }
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context);
    await ref
        .read(progressRepositoryProvider)
        .reportUser(widget.userId, 'profile', context: 'other');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.convReported)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.profilePublicTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.text),
            onSelected: (v) => v == 'block' ? _block() : _report(),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'report', child: Text(l10n.convReport)),
              PopupMenuItem(value: 'block', child: Text(l10n.convBlock)),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (snap.hasError || snap.data == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(l10n.profileNotFound,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted)),
                  ),
                );
              }
              return _ProfileBody(
                data: snap.data!,
                acting: _acting,
                onAdd: _add,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.data, required this.acting, required this.onAdd});
  final Map<String, dynamic> data;
  final bool acting;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = (data['name'] ?? '').toString();
    final handle = data['handle'] as String?;
    final rel = (data['relationship'] ?? 'none').toString();
    final country = (data['country'] as String?)?.trim();
    final memberSince = (data['member_since'] ?? '').toString();
    final streak = (data['streak'] as num?)?.toInt() ?? 0;
    final levels = (data['levels'] as List?) ?? const [];
    final badges = (data['badges'] as List?) ?? const [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white, width: 3)),
              child: _Squircle(
                  color: (data['avatar_color'] ?? '#6C5CE7').toString(), letter: name, size: 78),
            ),
            const SizedBox(height: 12),
            Text(name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white)),
            if (handle != null)
              Text('@$handle',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.85))),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              children: [
                if (country != null && country.isNotEmpty)
                  _bannerMeta(Icons.public_rounded, country),
                if (memberSince.isNotEmpty)
                  _bannerMeta(Icons.event_rounded, l10n.profileMemberSince(memberSince)),
                if (streak > 0)
                  _bannerMeta(
                      Icons.local_fire_department_rounded, l10n.profileStreakDays(streak)),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _profileCta(context, l10n, rel, acting, onAdd),
        if (levels.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionHeader(l10n.profileLanguages),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final lv in levels)
                _LangChip(
                    lang: (lv['lang_name'] ?? lv['lang'] ?? '').toString(),
                    level: (lv['level'] ?? '').toString()),
            ],
          ),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionHeader(l10n.profileBadges),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final b in badges) _BadgeChip(name: (b['name'] ?? '').toString()),
            ],
          ),
        ],
      ],
    );
  }
}

Widget _bannerMeta(IconData icon, String text) =>
    Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
      const SizedBox(width: 4),
      Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.9))),
    ]);

Widget _sectionHeader(String t) => Text(t.toUpperCase(),
    style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textMuted));

Widget _profileCta(BuildContext context, AppLocalizations l10n, String rel, bool acting,
    VoidCallback onAdd) {
  switch (rel) {
    case 'none':
      return SizedBox(
        width: double.infinity,
        child: PrimaryButton(label: l10n.profileAddFriend, onPressed: acting ? null : onAdd),
      );
    case 'pending_in':
      return SizedBox(
        width: double.infinity,
        child: PrimaryButton(label: l10n.profileAcceptRequest, onPressed: acting ? null : onAdd),
      );
    case 'pending_out':
      return _statusPill(l10n.profileRequestSent, Icons.schedule_rounded);
    case 'friends':
      return _statusPill(l10n.profileFriends, Icons.verified_rounded, color: AppColors.success);
    default:
      return const SizedBox.shrink();
  }
}

Widget _statusPill(String text, IconData icon, {Color color = AppColors.primary}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(15)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 7),
        Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ]),
    );

class _LangChip extends StatelessWidget {
  const _LangChip({required this.lang, required this.level});
  final String lang, level;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 3), blurRadius: 0),
          ]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(lang,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
              color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(7)),
          child: Text(level,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
        ),
      ]),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF4E0), borderRadius: BorderRadius.circular(13)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.emoji_events_rounded, size: 15, color: Color(0xFFEBA400)),
        const SizedBox(width: 6),
        Text(name,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF8A6400))),
      ]),
    );
  }
}
