import 'package:clean_stream_laundry_app/features/settings/settings.dart';
import 'package:clean_stream_laundry_app/features/settings/widgets/settings_card.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/core/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockTransactionService mockTransactionService;
  late MockProfileService mockProfileService;
  late MockThemeManager mockThemeManager;
  late GoRouter router;

  setUp(() async {
    mockAuthService = MockAuthService();
    mockTransactionService = MockTransactionService();
    mockThemeManager = MockThemeManager();
    mockProfileService = MockProfileService();

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<TransactionService>(
      mockTransactionService,
    );

    when(
      () => mockProfileService.getNotificationLeadTime(),
    ).thenAnswer((_) async => 5);
    when(
      () => mockProfileService.getCurrentUserRole(),
    ).thenAnswer((_) async => null);
    when(
      () => mockProfileService.setNotificationLeadTime(any()),
    ).thenAnswer((_) async {});

    router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Settings()),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Login Page')),
        ),
        GoRoute(
          path: '/editProfile',
          builder: (_, _) => const Scaffold(body: Text('Edit Profile Page')),
        ),
        GoRoute(
          path: '/monthlyTransactionHistory',
          builder: (_, _) => const Scaffold(body: Text('Monthly Report Page')),
        ),
        GoRoute(
          path: '/refundPage',
          builder: (_, _) => const Scaffold(body: Text('Refund Page')),
        ),
        GoRoute(
          path: '/maintenancePage',
          builder: (_, _) => const Scaffold(body: Text('Maintenance Page')),
        ),
      ],
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidget() {
    return ChangeNotifierProvider<ThemeManager>.value(
      value: mockThemeManager,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('Settings page tests', () {
    testWidgets('displays page title without duplicate logo', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Settings'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName == 'assets/Logo.png',
        ),
        findsNothing,
      );
    });

    testWidgets('displays grouped settings sections and rows', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(SettingsCard), findsNWidgets(10));
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Legal'), findsOneWidget);
      expect(find.text('Session'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Monthly Report'), findsOneWidget);
      expect(find.text('Request Refund'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Notify Before Finish'), findsOneWidget);
      expect(find.text('Facility Maintenance'), findsOneWidget);
    });

    testWidgets('displays correct icons for each card', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.request_page_outlined), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.handyman_outlined), findsOneWidget);
    });

    testWidgets('centers content inside SingleChildScrollView', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('does not overflow on narrow settings screens', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Facility Maintenance'));
      await tester.ensureVisible(find.text('Notify Before Finish'));

      expect(tester.takeException(), isNull);
    });

    testWidgets('calls toggleTheme when theme card is tapped', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(
        find.ancestor(
          of: find.byIcon(Icons.lightbulb_outline),
          matching: find.byType(SettingsCard),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => mockThemeManager.toggleTheme()).called(1);
    });

    testWidgets('loads notification lead time from ProfileService', (
      tester,
    ) async {
      when(
        () => mockProfileService.getNotificationLeadTime(),
      ).thenAnswer((_) async => 7);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('shows default notification lead time when loading fails', (
      tester,
    ) async {
      when(
        () => mockProfileService.getNotificationLeadTime(),
      ).thenThrow(Exception('missing profile'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('increments notification lead time when + is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      verify(() => mockProfileService.setNotificationLeadTime(6)).called(1);
    });

    testWidgets('decrements notification lead time when - is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      verify(() => mockProfileService.setNotificationLeadTime(4)).called(1);
    });

    testWidgets('does not decrement below 0', (tester) async {
      when(
        () => mockProfileService.getNotificationLeadTime(),
      ).thenAnswer((_) async => 0);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      verifyNever(() => mockProfileService.setNotificationLeadTime(any()));
    });

    testWidgets('notification lead time does not exceed max limit', (
      tester,
    ) async {
      when(
        () => mockProfileService.getNotificationLeadTime(),
      ).thenAnswer((_) async => Settings.maxNotificationLeadTime - 2);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final plusButton = find.byIcon(Icons.add);
      await tester.ensureVisible(plusButton);

      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      expect(find.text('${Settings.maxNotificationLeadTime}'), findsOneWidget);
      verify(
        () => mockProfileService.setNotificationLeadTime(
          Settings.maxNotificationLeadTime,
        ),
      ).called(1);
    });

    testWidgets('shows confirmation dialog when Sign Out is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(SettingsCard, 'Sign Out'));
      await tester.tap(find.widgetWithText(SettingsCard, 'Sign Out'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
    });

    testWidgets('calls logout and navigates to /login on Sign Out confirm', (
      tester,
    ) async {
      when(() => mockAuthService.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(SettingsCard, 'Sign Out'));
      await tester.tap(find.widgetWithText(SettingsCard, 'Sign Out'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.logout()).called(1);
    });

    testWidgets('does not log out when Cancel is tapped', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(SettingsCard, 'Sign Out'));
      await tester.tap(find.widgetWithText(SettingsCard, 'Sign Out'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockAuthService.logout());
    });

    testWidgets('navigates to /editProfile when Edit Profile is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(SettingsCard, 'Edit Profile'),
      );
      await tester.tap(find.widgetWithText(SettingsCard, 'Edit Profile'));
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        '/editProfile',
      );
    });

    testWidgets('fetches transactions and navigates to monthly report', (
      tester,
    ) async {
      when(() => mockTransactionService.getTransactionsForUser()).thenAnswer(
        (_) async => [
          {'id': '1', 'amount': 100},
          {'id': '2', 'amount': 200},
        ],
      );

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(SettingsCard, 'Monthly Report'),
      );
      await tester.tap(find.text('Monthly Report'));
      await tester.pumpAndSettle();

      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    testWidgets('navigates to /refundPage when Request Refund is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(SettingsCard, 'Request Refund'),
      );
      await tester.tap(find.widgetWithText(SettingsCard, 'Request Refund'));
      await tester.pumpAndSettle();

      expect(find.text('Refund Page'), findsOneWidget);
    });

    testWidgets('navigates to /maintenancePage when maintenance is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(SettingsCard, 'Facility Maintenance'),
      );
      await tester.tap(
        find.widgetWithText(SettingsCard, 'Facility Maintenance'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Maintenance Page'), findsOneWidget);
    });
  });
}
