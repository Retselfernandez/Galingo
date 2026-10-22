import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/galingo_colors.dart';

/// Casca de navegación con barra inferior (móbil).
///
/// Cada pestana conserva o seu estado (scroll, posición) grazas a
/// [StatefulNavigationShell]. En escritorio (> 1024 px) a barra ocúltase:
/// o HomeScreen amosa o sidebar lateral no seu lugar.
class HomeShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const HomeShell({super.key, required this.shell});

  static const _items = <({IconData icon, IconData active, String label})>[
    (icon: Icons.map_outlined, active: Icons.map_rounded, label: 'Camiño'),
    (
      icon: Icons.menu_book_outlined,
      active: Icons.menu_book_rounded,
      label: 'Leccións'
    ),
    (
      icon: Icons.insights_outlined,
      active: Icons.insights_rounded,
      label: 'Progreso'
    ),
    (
      icon: Icons.settings_outlined,
      active: Icons.settings_rounded,
      label: 'Axustes'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final showBar = MediaQuery.sizeOf(context).width < 1024;

    return Scaffold(
      body: shell,
      bottomNavigationBar: !showBar
          ? null
          : NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: (index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
              height: 68,
              backgroundColor: context.cardBg,
              surfaceTintColor: Colors.transparent,
              indicatorColor: context.accentSoft,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                    icon: Icon(item.icon, color: context.textSecondary),
                    selectedIcon:
                        Icon(item.active, color: context.accent),
                    label: item.label,
                  ),
              ],
            ),
    );
  }
}
