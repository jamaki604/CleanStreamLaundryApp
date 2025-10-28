import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget {

  const NavBar({super.key,});

  int _getIndex(String location) {
    if (location.startsWith('/scanner')) return 0;
    if (location.startsWith('/loyalty')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri.toString();
    final currentIndex = _getIndex(location);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go("/scanner");
            break;
          case 1:
            context.go("/loyalty");
            break;
          case 2:
            context.go("/settings");
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Loyalty'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
    );
  }
}