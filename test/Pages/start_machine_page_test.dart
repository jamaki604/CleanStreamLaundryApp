import 'package:clean_stream_laundry_app/Pages/start_machine_page.dart';
import 'package:clean_stream_laundry_app/Widgets/large_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late GoRouter router;
  late MockNavigatorObserver navigatorObserver;

  setUp(() {
    navigatorObserver = MockNavigatorObserver();

    router = GoRouter(
      observers: [navigatorObserver],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const StartPage(),
        ),
        GoRoute(
          path: '/scanner',
          builder: (_, __) => const Scaffold(body: Text('Scanner Page')),
        ),
      ],
    );
  });

  Widget createTestApp() {
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('Tapping QR button navigates to /scanner', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    final qrButton = find.widgetWithText(LargeButton, "Scan QR code");

    expect(qrButton, findsOneWidget);

    await tester.tap(qrButton);
    await tester.pumpAndSettle();

    // Verify we navigated to the scanner page
    expect(find.text("Scanner Page"), findsOneWidget);
  });
}
