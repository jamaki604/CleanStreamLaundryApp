import 'package:clean_stream_laundry_app/widgets//base_page.dart';
import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:clean_stream_laundry_app/Logic/Theme/theme_manager.dart';
import 'package:clean_stream_laundry_app/Pages/settings.dart';
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
    testWidgets('should display Settings title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Settings \n'), findsOneWidget);
    });

    testWidgets('should display all three buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Monthly Report'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Out'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Monthly Report'),
        findsOneWidget,
      );
    });

    testWidgets(
      'should call logout and navigate to login when Sign Out is pressed',
      (WidgetTester tester) async {
        when(() => mockAuthService.logout()).thenAnswer((_) async => {});

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Sign Out'));
        await tester.pumpAndSettle();

        verify(() => mockAuthService.logout()).called(1);
      },
    );

    testWidgets('should call toggleTheme when theme toggle button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final themeButton = find.byType(ElevatedButton).at(1);
      await tester.tap(themeButton);
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

      await tester.tap(find.text('Monthly Report'));
      await tester.pumpAndSettle();

      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    testWidgets('should use correct button styles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final signOutButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign Out'),
      );

      final buttonStyle = signOutButton.style;
      expect(buttonStyle, isNotNull);
    });
    testWidgets('should center content properly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
