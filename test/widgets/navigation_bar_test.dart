import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/widgets/navigation_bar.dart';

void main() {
  Widget wrapWithRouter(String initialLocation) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/homePage',
          builder: (_, __) => Scaffold(
            body: const Text('Home Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        GoRoute(
          path: '/startPage',
          builder: (_, __) => Scaffold(
            body: const Text('Start Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        GoRoute(
          path: '/loyalty',
          builder: (_, __) => Scaffold(
            body: const Text('Loyalty Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => Scaffold(
            body: const Text('Settings Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('NavBar Widget Tests', () {
    testWidgets('All nav items are visible', (tester) async {
      await tester.pumpWidget(wrapWithRouter('/homePage'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.local_laundry_service_sharp), findsOneWidget);
      expect(find.byIcon(Icons.wallet), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Tapping Home navigates to /homePage', (tester) async {
      await tester.pumpWidget(wrapWithRouter('/startPage'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('Tapping Start navigates to /startPage', (tester) async {
      await tester.pumpWidget(wrapWithRouter('/homePage'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Start Page'), findsOneWidget);
    });

    testWidgets('Tapping Wallet navigates to /loyalty', (tester) async {
      await tester.pumpWidget(wrapWithRouter('/homePage'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Wallet'));
      await tester.pumpAndSettle();

      expect(find.text('Loyalty Page'), findsOneWidget);
    });

    testWidgets('Tapping Settings navigates to /settings', (tester) async {
      await tester.pumpWidget(wrapWithRouter('/homePage'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('CurrentIndex updates based on initial route', (tester) async {
      await tester.pumpWidget(wrapWithRouter('/loyalty'));
      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, 2);
    });
  });
}