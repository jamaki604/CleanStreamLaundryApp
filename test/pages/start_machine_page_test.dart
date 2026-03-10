import 'package:clean_stream_laundry_app/pages/start_machine_page.dart';
import 'package:clean_stream_laundry_app/services/kisi/door_unlocker.dart';
import 'package:clean_stream_laundry_app/widgets/large_button.dart';
import 'package:clean_stream_laundry_app/widgets/qr_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockDoorUnlocker extends Mock implements DoorUnlocker {}

void main() {
  late MockDoorUnlocker mockUnlocker;

  setUp(() {
    mockUnlocker = MockDoorUnlocker();
  });

  Widget createStartPageTestApp(DoorUnlocker unlocker) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => StartPage(doorUnlocker: unlocker),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  Widget createRouterTestApp() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => StartPage(),
        ),
        GoRoute(
          path: '/scanner',
          builder: (_, _) => const Scaffold(body: Text('Scanner Page')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('Tapping QR button navigates to /scanner', (tester) async {
    await tester.pumpWidget(createRouterTestApp());
    await tester.pumpAndSettle();

    final qrButton = find.widgetWithText(LargeButton, "Scan QR code");
    expect(qrButton, findsOneWidget);

    await tester.tap(qrButton);
    await tester.pumpAndSettle();

    expect(find.text("Scanner Page"), findsOneWidget);
  });

  testWidgets('Unlock button shows searching dialog', (tester) async {
    when(() => mockUnlocker.unlockNearestDoor())
        .thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return true;
    });

    await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
    await tester.pump();

    final unlockButton = find.widgetWithText(LargeButton, "Unlock Door");
    await tester.ensureVisible(unlockButton);
    await tester.pump();

    await tester.tap(unlockButton);
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.textContaining("Finding Nearby Doors"), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
  });


  testWidgets('Successful unlock closes searching dialog and shows success dialog',
        (tester) async {
        when(() => mockUnlocker.unlockNearestDoor())
            .thenAnswer((_) async => true);

        await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
        await tester.pump();

        final unlockButton = find.widgetWithText(LargeButton, "Unlock Door");
        await tester.ensureVisible(unlockButton);
        await tester.pump();

        await tester.tap(unlockButton);
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pump(const Duration(seconds: 3));

        expect(find.text("Door Unlocked!"), findsOneWidget);
      });

  testWidgets('Failed unlock shows failure dialog', (tester) async {
    when(() => mockUnlocker.unlockNearestDoor())
        .thenAnswer((_) async => false);

    await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
    await tester.pump();

    final unlockButton = find.widgetWithText(LargeButton, "Unlock Door");
    await tester.ensureVisible(unlockButton);
    await tester.pump();

    await tester.tap(unlockButton);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pump(const Duration(seconds: 2));

    expect(find.text("No Nearby Doors Found"), findsOneWidget);
  });
}