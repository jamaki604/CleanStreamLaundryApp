import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget {

  const NavBar({super.key,});

  int _getIndex(String location) {
    if (location.startsWith('/homePage')) return 0;
    if (location.startsWith('/start')) return 1;
    if (location.startsWith('/loyalty')) return 2;
    if (location.startsWith('/settings')) return 3;
    if (location.startsWith('/monthlyTransactionHistory')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri.toString();
    final currentIndex = _getIndex(location);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go("/homePage");
            break;
          case 1:
            context.go("/startPage");
            break;
          case 2:
            context.go("/loyalty");
            break;
          case 3:
            context.go("/settings");
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.local_laundry_service_sharp), label: 'Start'),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
    );
  }
}