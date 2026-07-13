import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/music_controller.dart';
import '../../core/audio/music_service.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/feedback/feedback_sheet.dart';
import '../../core/speech/speech_lang.dart';
import '../../data/providers.dart';
import '../conversar/conversar_screen.dart';
import '../notifications/matix_auto.dart';
import '../leagues/leagues_screen.dart';
import '../learn/learn_map_screen.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/bottom_nav.dart';

/// Scaffold raíz: contenido por pestaña (IndexedStack para preservar estado) +
/// barra inferior + botón de FEEDBACK presente en toda la app (GA7). Registra
/// screen_view por sección para la analítica de uso.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> with WidgetsBindingObserver {
  int _index = 0;

  static const _sections = ['Aprender', 'Practicar', 'Conversar', 'Ligas', 'Perfil'];

  /// Presencia: heartbeat ligero (un UPDATE por PK) para que los amigos vean
  /// "en línea / activo hace X" honesto. Late al abrir, al volver del background
  /// y cada 90s en primer plano (barato en red/batería); se PAUSA en background.
  Timer? _presenceTimer;

  void _beat() => unawaited(ref.read(progressRepositoryProvider).heartbeat());

  void _startPresence() {
    _beat();
    _presenceTimer?.cancel();
    _presenceTimer = Timer.periodic(const Duration(seconds: 90), (_) => _beat());
  }

  void _stopPresence() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logView(0);
    // Música ambiente SOLO en el mapa (tab 0). Arranca si el usuario la activó.
    MusicService.instance.setOnMap(_index == 0);
    _startPresence();
    // T4 · Matix automático: una evaluación diaria (meta sin cumplir tarde en
    // el día / racha en riesgo / atraso vs plan) + fan-out del Web Push
    // pendiente (lazy-cron: un cliente activo empuja los de los offline).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(matixAutoProvider).runDailyChecks());
      unawaited(ref.read(progressRepositoryProvider).pushFanout());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MusicService.instance.setOnMap(false); // detén la música al salir del shell
    _stopPresence();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausa al backgroundear; reanuda al volver (respeta al usuario / otra app).
    final resumed = state == AppLifecycleState.resumed;
    MusicService.instance.setResumed(resumed);
    if (resumed) {
      _startPresence(); // late al volver + reanuda el periódico
    } else {
      _stopPresence(); // no gastar batería/red en background
    }
  }

  void _logView(int i) {
    ref.read(progressRepositoryProvider).logEvent('screen_view', props: {'section': _sections[i]});
  }

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _logView(i);
    MusicService.instance.setOnMap(i == 0); // pausa al salir del mapa
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(soundEnabledProvider); // carga la preferencia de sonido al montar
    ref.watch(musicEnabledProvider); // carga la preferencia de música ambiente
    // Cambio de pestaña pedido desde otra pantalla (p.ej. "Ir a mi lección" en
    // Practicar → mapa). Se consume al instante.
    ref.listen(homeTabRequestProvider, (_, next) {
      if (next == null) return;
      _select(next);
      ref.read(homeTabRequestProvider.notifier).clear();
    });
    // Idioma de HABLA del curso activo (TTS de tile + reconocedor de speaking):
    // pronuncia/reconoce en el idioma que se aprende (en/pt/fr/it), no en inglés fijo.
    // Se reevalúa al cambiar de curso (coursesProvider se invalida en set_active_course).
    ref.watch(activeCourseTargetProvider).whenData(SpeechLang.setFromCourseTarget);
    const screens = <Widget>[
      LearnMapScreen(),
      PracticeScreen(),
      ConversarScreen(),
      LeaguesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _index, children: screens),
          // Botón de feedback (toda la app). Sobre el contenido, junto al borde.
          Positioned(
            right: 16,
            bottom: 92,
            child: SafeArea(child: FeedbackFab(section: _sections[_index])),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: _index, onTap: _select),
    );
  }
}
