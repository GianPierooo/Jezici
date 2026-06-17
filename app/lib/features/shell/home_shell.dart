import 'package:flutter/material.dart';

import '../learn/learn_map_screen.dart';
import '../profile/profile_screen.dart';
import '../shared/placeholder_screen.dart';
import 'widgets/bottom_nav.dart';

/// Scaffold raíz: contenido por pestaña (IndexedStack para preservar estado) +
/// la barra inferior de 5 íconos. Solo "Aprender" y los placeholders en el paso C.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const screens = <Widget>[
      LearnMapScreen(),
      PlaceholderScreen(title: 'Practicar', icon: Icons.fitness_center_rounded),
      PlaceholderScreen(title: 'Conversar', icon: Icons.forum_rounded),
      PlaceholderScreen(title: 'Ligas', icon: Icons.emoji_events_rounded),
      ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
