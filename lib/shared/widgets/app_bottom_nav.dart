import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Avaleht',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Lisa kulu',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_basket_outlined),
              selectedIcon: Icon(Icons.shopping_basket),
              label: 'Toit',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Seaded',
            ),
          ],
        ),
      );
  }
}
