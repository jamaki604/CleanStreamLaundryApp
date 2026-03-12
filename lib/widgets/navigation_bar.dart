import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget {
  static const List<_NavDestination> _destinations = [
    _NavDestination(
      route: '/homePage',
      label: 'Home',
      icon: Icons.home,
      routePrefixes: ['/homePage'],
    ),
    _NavDestination(
      route: '/startPage',
      label: 'Start',
      icon: Icons.local_laundry_service_sharp,
      routePrefixes: ['/start', '/startPage'],
    ),
    _NavDestination(
      route: '/loyalty',
      label: 'Wallet',
      icon: Icons.wallet,
      routePrefixes: ['/loyalty'],
    ),
    _NavDestination(
      route: '/settings',
      label: 'Settings',
      icon: Icons.settings,
      routePrefixes: ['/settings', '/monthlyTransactionHistory', '/refundPage'],
    ),
  ];

  const NavBar({super.key});

  int _getIndex(String location) {
    for (var i = 0; i < _destinations.length; i++) {
      final destination = _destinations[i];
      if (destination.routePrefixes.any(location.startsWith)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri.toString();
    final currentIndex = _getIndex(location);
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        final route = _destinations[index].route;
        if (!location.startsWith(route)) {
          context.go(route);
        }
      },
      items: _destinations
          .map(
            (destination) => BottomNavigationBarItem(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavDestination {
  final String route;
  final String label;
  final IconData icon;
  final List<String> routePrefixes;

  const _NavDestination({
    required this.route,
    required this.label,
    required this.icon,
    required this.routePrefixes,
  });
}
