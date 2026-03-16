import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';
import 'package:clean_stream_laundry_app/pages/start_machine_page.dart';
import 'package:clean_stream_laundry_app/services/kisi/door_unlocker.dart';
import 'package:clean_stream_laundry_app/widgets/qr_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockDoorUnlocker extends Mock implements DoorUnlocker {}
class MockLoyaltyViewModel extends Mock implements LoyaltyViewModel {}

void main() {
  late MockLoyaltyViewModel mockViewModel;
  late MockDoorUnlocker mockUnlocker;

  setUp(() {
    mockUnlocker = MockDoorUnlocker();
    mockViewModel = MockLoyaltyViewModel();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoyaltyViewModel>()) {
      getIt.unregister<LoyaltyViewModel>();
    }
    getIt.registerSingleton<LoyaltyViewModel>(mockViewModel);
  });

  Widget createStartPageTestApp(DoorUnlocker unlocker) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => StartPage(doorUnlocker: unlocker),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  Widget createRouterTestApp() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => StartPage(),
        ),
        GoRoute(
          path: '/scanner',
          builder: (_, __) => const Scaffold(body: Text('Scanner Page')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  Future<void> scrollToUnlockButton(WidgetTester tester) async {
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
  }

  testWidgets('Tapping QR button navigates to /scanner', (tester) async {
    when(() => mockViewModel.userBalance).thenReturn(50.0);

    await tester.pumpWidget(createRouterTestApp());
    await tester.pumpAndSettle();

    final qrButton = find.widgetWithText(QRButton, "Scan QR code");
    expect(qrButton, findsOneWidget);

    await tester.tap(qrButton);
    await tester.pumpAndSettle();

    expect(find.text("Scanner Page"), findsOneWidget);
  });

  testWidgets('Unlock button shows searching dialog', (tester) async {
    when(() => mockViewModel.userBalance).thenReturn(50.0);

    when(() => mockUnlocker.unlockNearestDoor())
        .thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return true;
    });

    await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
    await tester.pumpAndSettle();

    await scrollToUnlockButton(tester);

    await tester.tap(find.text("Unlock Door"));
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.textContaining("Finding Nearby Doors"), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Successful unlock closes searching dialog and shows success dialog',
          (tester) async {
        when(() => mockViewModel.userBalance).thenReturn(50.0);
        when(() => mockUnlocker.unlockNearestDoor()).thenAnswer((_) async => true);

        await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
        await tester.pumpAndSettle();

        await scrollToUnlockButton(tester);

        await tester.tap(find.text("Unlock Door"));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(seconds: 2));

        expect(find.text("Door Unlocked!"), findsOneWidget);
      });

  testWidgets('Failed unlock shows failure dialog', (tester) async {
    when(() => mockViewModel.userBalance).thenReturn(50.0);
    when(() => mockUnlocker.unlockNearestDoor()).thenAnswer((_) async => false);

    await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
    await tester.pumpAndSettle();

    await scrollToUnlockButton(tester);

    await tester.tap(find.text("Unlock Door"));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text("No Nearby Doors Found"), findsOneWidget);
  });

  testWidgets('shows low balance dialog when balance is below 20', (tester) async {
    when(() => mockViewModel.userBalance).thenReturn(19.99);

    await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
    await tester.pumpAndSettle();

    await scrollToUnlockButton(tester);

    await tester.tap(find.text('Unlock Door'));
    await tester.pumpAndSettle();

    expect(find.text('You need at least \$20 to unlock a door'), findsOneWidget);
    verifyNever(() => mockUnlocker.unlockNearestDoor());
  });

  testWidgets('allows unlocking when balance is exactly 20', (tester) async {
    when(() => mockViewModel.userBalance).thenReturn(20.0);
    when(() => mockUnlocker.unlockNearestDoor()).thenAnswer((_) async => true);

    await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
    await tester.pumpAndSettle();

    await scrollToUnlockButton(tester);

    await tester.tap(find.text("Unlock Door"));
    await tester.pumpAndSettle();

    verify(() => mockUnlocker.unlockNearestDoor()).called(1);
  });

  testWidgets('allows unlocking when balance is above 20', (tester) async {
    when(() => mockViewModel.userBalance).thenReturn(25.0);
    when(() => mockUnlocker.unlockNearestDoor()).thenAnswer((_) async => true);

    await tester.pumpWidget(createStartPageTestApp(mockUnlocker));
    await tester.pumpAndSettle();

    await scrollToUnlockButton(tester);

    await tester.tap(find.text("Unlock Door"));
    await tester.pumpAndSettle();

    verify(() => mockUnlocker.unlockNearestDoor()).called(1);
  });
}