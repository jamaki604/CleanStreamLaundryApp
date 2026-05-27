import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/features/widgets/navigation_bar.dart';

void main() {
  Widget wrapWithRouter(
    String initialLocation, {
    double bottomViewPadding = 0,
  }) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/homePage',
          builder: (context, state) => Scaffold(
            body: const Text('Home Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        GoRoute(
          path: '/startPage',
          builder: (context, state) => Scaffold(
            body: const Text('Start Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        GoRoute(
          path: '/scanner',
          builder: (context, state) => Scaffold(
            body: const Text('Scanner Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        GoRoute(
          path: '/paymentPage',
          builder: (context, state) => Scaffold(
            body: const Text('Payment Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        GoRoute(
          path: '/loyalty',
          builder: (context, state) => Scaffold(
            body: const Text('Loyalty Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => Scaffold(
            body: const Text('Settings Page'),
            bottomNavigationBar: const NavBar(),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(bottom: 0),
            viewPadding: mediaQuery.viewPadding.copyWith(
              bottom: bottomViewPadding,
            ),
          ),
          child: child!,
        );
      },
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

    testWidgets('does not overflow with iPhone bottom safe area', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        wrapWithRouter('/homePage', bottomViewPadding: 34),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(NavBar)).height, 96);
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

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 2);
    });

    testWidgets('Scanner route highlights Start tab', (tester) async {
      await tester.pumpWidget(wrapWithRouter('/scanner'));
      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 1);
    });

    testWidgets('Payment route highlights Start tab', (tester) async {
      await tester.pumpWidget(wrapWithRouter('/paymentPage?machineId=abc'));
      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 1);
    });
  });
}
