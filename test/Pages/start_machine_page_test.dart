import 'package:clean_stream_laundry_app/Pages/start_machine_page.dart';
import 'package:clean_stream_laundry_app/Components/large_button.dart';
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

  testWidgets('StartPage renders both LargeButtons', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Check button text
    expect(find.text("Tap to Pay"), findsOneWidget);
    expect(find.text("Scan QR code"), findsOneWidget);

    // Check descriptions
    expect(find.text("Tap phone to machine to pay"), findsOneWidget);
    expect(find.text("Scan QR code on the machine"), findsOneWidget);

    // Check icons
    expect(find.byIcon(Icons.tap_and_play), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
  });

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

  testWidgets('Tap to Pay button exists and is tappable', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    final tapButton = find.widgetWithText(LargeButton, "Tap to Pay");

    expect(tapButton, findsOneWidget);

    await tester.tap(tapButton);
    await tester.pumpAndSettle();

    // No navigation expected: stay on StartPage
    expect(find.text("Tap to Pay"), findsOneWidget);
  });
}
