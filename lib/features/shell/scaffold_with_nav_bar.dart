import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';

/// The persistent chrome for the four main sections: a bottom bar with Inicio /
/// Citas — a notch — Mapa / Perfil, and the central FAB to log a date. Detail
/// and modal screens are pushed above this and cover the bar.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the active tab again pops it back to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final current = navigationShell.currentIndex;

    Widget tab(int index, IconData icon, IconData activeIcon, String label) {
      final selected = index == current;
      return Expanded(
        child: InkWell(
          onTap: () => _goBranch(index),
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? activeIcon : icon,
                    size: 24,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: RachaType.micro,
                    fontWeight: FontWeight.w600,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).push('/dates/new'),
        tooltip: l10n.homeLogDate,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: EdgeInsets.zero,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          children: [
            tab(0, Icons.home_outlined, Icons.home, l10n.navHome),
            tab(1, Icons.favorite_outline, Icons.favorite, l10n.navDates),
            const SizedBox(width: 64),
            tab(2, Icons.map_outlined, Icons.map, l10n.navMap),
            tab(3, Icons.person_outline, Icons.person, l10n.navProfile),
          ],
        ),
      ),
    );
  }
}
