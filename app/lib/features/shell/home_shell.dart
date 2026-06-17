import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/sound_controller.dart';
import '../../core/feedback/feedback_sheet.dart';
import '../../data/providers.dart';
import '../conversar/conversar_screen.dart';
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

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _sections = ['Aprender', 'Practicar', 'Conversar', 'Ligas', 'Perfil'];

  @override
  void initState() {
    super.initState();
    _logView(0);
  }

  void _logView(int i) {
    ref.read(progressRepositoryProvider).logEvent('screen_view', props: {'section': _sections[i]});
  }

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _logView(i);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(soundEnabledProvider); // carga la preferencia de sonido al montar
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
