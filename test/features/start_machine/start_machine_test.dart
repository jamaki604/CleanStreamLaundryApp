import 'package:clean_stream_laundry_app/features/start_machine/start_machine.dart';
import 'package:clean_stream_laundry_app/features/start_machine/widgets/qr_button.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockDoorUnlocker mockUnlocker;
  late MockProfileService mockProfileService;
  late MockAuthService mockAuthService;

  setUp(() async {
    mockUnlocker = MockDoorUnlocker();
    mockProfileService = MockProfileService();
    mockAuthService = MockAuthService();

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);

    when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
    when(() => mockProfileService.getUserBalanceById('user123'))
        .thenAnswer((_) async => {'balance': 50.0});
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => StartPage(doorUnlocker: mockUnlocker),
          ),
          GoRoute(
            path: '/scanner',
            builder: (_, __) =>
            const Scaffold(body: Text('Scanner Page')),
          ),
          GoRoute(
            path: '/startPage',
            builder: (_, __) => StartPage(doorUnlocker: mockUnlocker),
          ),
        ],
      ),
    );
  }

  Future<void> scrollToUnlockButton(WidgetTester tester) async {
    final scrollViewFinder = find.descendant(
      of: find.byType(StartPage),
      matching: find.byType(SingleChildScrollView),
    );
    expect(scrollViewFinder, findsOneWidget);
    await tester.drag(scrollViewFinder, const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('Static UI', () {
    testWidgets('displays Payment Options section header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Payment Options'), findsOneWidget);
    });

    testWidgets('displays Tap To Pay card', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tap To Pay'), findsOneWidget);
      expect(find.byIcon(Icons.tap_and_play), findsOneWidget);
    });

    testWidgets('displays Scan QR code button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(QRButton, 'Scan QR code'), findsOneWidget);
    });

    testWidgets('displays After Hours section header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('After Hours'), findsOneWidget);
    });

    testWidgets('displays Unlock Door button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Unlock Door'), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('tapping Scan QR code navigates to /scanner', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(QRButton, 'Scan QR code'));
      await tester.pumpAndSettle();

      expect(find.text('Scanner Page'), findsOneWidget);
    });
  });

  group('Door unlocking', () {
    testWidgets('shows searching dialog when Unlock Door is tapped',
            (tester) async {
          when(() => mockUnlocker.unlockNearestDoor()).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return true;
          });

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();
          await scrollToUnlockButton(tester);

          await tester.tap(find.text('Unlock Door'));
          await tester.pump(const Duration(milliseconds: 20));

          expect(find.byType(Dialog), findsOneWidget);
          expect(find.textContaining('Finding Nearby Doors'), findsOneWidget);
          await tester.pumpAndSettle();
        });

    testWidgets('shows success dialog after successful unlock', (tester) async {
      when(() => mockUnlocker.unlockNearestDoor())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      await scrollToUnlockButton(tester);

      await tester.tap(find.text('Unlock Door'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Door Unlocked!'), findsOneWidget);
    });

    testWidgets('shows failure dialog when unlock fails', (tester) async {
      when(() => mockUnlocker.unlockNearestDoor())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      await scrollToUnlockButton(tester);

      await tester.tap(find.text('Unlock Door'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('No Nearby Doors Found'), findsOneWidget);
    });

    testWidgets('allows unlocking when balance is exactly 20', (tester) async {
      when(() => mockProfileService.getUserBalanceById(any()))
          .thenAnswer((_) async => {'balance': 20.0});
      when(() => mockUnlocker.unlockNearestDoor())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      await scrollToUnlockButton(tester);

      await tester.tap(find.text('Unlock Door'));
      await tester.pumpAndSettle();

      verify(() => mockUnlocker.unlockNearestDoor()).called(1);
    });

    testWidgets('allows unlocking when balance is above 20', (tester) async {
      when(() => mockUnlocker.unlockNearestDoor())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      await scrollToUnlockButton(tester);

      await tester.tap(find.text('Unlock Door'));
      await tester.pumpAndSettle();

      verify(() => mockUnlocker.unlockNearestDoor()).called(1);
    });
  });

  group('Low balance', () {
    testWidgets('shows low balance dialog when balance is below 20',
            (tester) async {
          when(() => mockProfileService.getUserBalanceById(any()))
              .thenAnswer((_) async => {'balance': 15.0});

          await tester.pumpWidget(createWidget());
          await tester.pump();
          await tester.pumpAndSettle();
          await scrollToUnlockButton(tester);

          await tester.tap(find.text('Unlock Door'));
          await tester.pumpAndSettle();

          expect(find.text('Low Balance'), findsOneWidget);
          expect(find.textContaining('at least 20.00'), findsOneWidget);
          verifyNever(() => mockUnlocker.unlockNearestDoor());
        });

    testWidgets('shows low balance dialog when balance is null', (tester) async {
      when(() => mockProfileService.getUserBalanceById(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      await scrollToUnlockButton(tester);

      await tester.tap(find.text('Unlock Door'));
      await tester.pumpAndSettle();

      expect(find.text('Low Balance'), findsOneWidget);
      verifyNever(() => mockUnlocker.unlockNearestDoor());
    });
  });
}