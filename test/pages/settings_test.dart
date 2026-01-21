import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'package:clean_stream_laundry_app/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'mocks.dart';
import 'package:clean_stream_laundry_app/widgets/settings_card.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockTransactionService mockTransactionService;
  late MockThemeManager mockThemeManager;
  late GoRouter router;

  setUp(() {
    mockAuthService = MockAuthService();
    mockTransactionService = MockTransactionService();
    mockThemeManager = MockThemeManager();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }
    if (getIt.isRegistered<TransactionService>()) {
      getIt.unregister<TransactionService>();
    }
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);

    router = GoRouter(
      routes: [GoRoute(path: '/', builder: (context, state) => Settings())],
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<ThemeManager>.value(
      value: mockThemeManager,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('Settings Widget Tests', () {
    testWidgets('should display Settings logo', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == 'assets/Logo.png',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display all five SettingsCard widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(SettingsCard), findsNWidgets(5));
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Monthly Report'), findsOneWidget);
      expect(find.text('Request Refund'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets(
      'should call logout and navigate to login when Sign Out is tapped',
      (WidgetTester tester) async {
        when(() => mockAuthService.logout()).thenAnswer((_) async => {});

        await tester.pumpWidget(createWidgetUnderTest());

        // Scroll to make Sign Out visible
        await tester.ensureVisible(
          find.widgetWithText(SettingsCard, 'Sign Out'),
        );
        await tester.pumpAndSettle();

        // Find and tap the Sign Out card
        await tester.tap(find.widgetWithText(SettingsCard, 'Sign Out'));
        await tester.pumpAndSettle();

        verify(() => mockAuthService.logout()).called(1);
      },
    );

    testWidgets('should call toggleTheme when theme card is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the theme toggle card by its icon
      final themeCard = find.ancestor(
        of: find.byIcon(Icons.lightbulb),
        matching: find.byType(SettingsCard),
      );

      await tester.tap(themeCard);
      await tester.pumpAndSettle();

      verify(() => mockThemeManager.toggleTheme()).called(1);
    });

    testWidgets('should fetch transactions and navigate to monthly report', (
      WidgetTester tester,
    ) async {
      final mockTransactions = <Map<String, dynamic>>[
        {'id': '1', 'amount': 100},
        {'id': '2', 'amount': 200},
      ];
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => mockTransactions);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(SettingsCard, 'Monthly Report'));
      await tester.pumpAndSettle();

      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    testWidgets(
      'should navigate to refund page when Request Refund is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Scroll to make Request Refund visible
        await tester.ensureVisible(
          find.widgetWithText(SettingsCard, 'Request Refund'),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(SettingsCard, 'Request Refund'));
        await tester.pumpAndSettle();

        // Verify navigation occurred (router location check)
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          '/refundPage',
        );
      },
    );

    testWidgets(
      'should navigate to edit profile page when edit profile is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Scroll to make Request Refund visible
        await tester.ensureVisible(
          find.widgetWithText(SettingsCard, 'Edit Profile'),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(SettingsCard, 'Edit Profile'));
        await tester.pumpAndSettle();

        // Verify navigation occurred (router location check)
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          '/editProfile',
        );
      },
    );

    testWidgets('should display correct icons for each card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
      expect(find.byIcon(Icons.money), findsOneWidget);
      expect(find.byIcon(Icons.request_page), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should center content properly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
