import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'package:clean_stream_laundry_app/middleware/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


// Pages
import 'package:clean_stream_laundry_app/pages/login_page.dart';
import 'package:clean_stream_laundry_app/pages/sign_up_screen.dart';
import 'package:clean_stream_laundry_app/pages/settings.dart';
import 'package:clean_stream_laundry_app/pages/home_page.dart';
import 'package:clean_stream_laundry_app/pages/loading_page.dart';
import 'package:clean_stream_laundry_app/pages/loyalty_card_page.dart';
import 'package:clean_stream_laundry_app/pages/monthly_transaction_history.dart';
import 'package:clean_stream_laundry_app/pages/not_found_page.dart';
import 'package:clean_stream_laundry_app/pages/payment_page.dart';
import 'package:clean_stream_laundry_app/pages/refund_page.dart';
import 'package:clean_stream_laundry_app/pages/scanner_widget.dart';
import 'package:clean_stream_laundry_app/pages/email_verification_page.dart';
import 'package:clean_stream_laundry_app/pages/start_machine_page.dart';

// Mocks
class MockAuthService extends Mock implements AuthService {}
class MockProfileService extends Mock implements ProfileService {}
class MockTransactionService extends Mock implements TransactionService {}
class MockMachineService extends Mock implements MachineService {}
class MockMachineCommunicationService extends Mock implements MachineCommunicationService {}
class MockLocationService extends Mock implements LocationService {}
class MockEdgeFunctionService extends Mock implements EdgeFunctionService {}
class MockThemeManager extends Mock implements ThemeManager {}

Widget buildTestApp(GoRouter router) {
  return ChangeNotifierProvider<ThemeManager>(
    create: (_) => MockThemeManager(),
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en')],
    ),
  );
}

void main() {
  late GoRouter router;
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();

    final mockLocationService = MockLocationService();
    final mockMachineService = MockMachineService();
    final mockAuthService = MockAuthService();

    // Register services
    getIt.registerLazySingleton<AuthService>(() => mockAuthService);
    getIt.registerLazySingleton<ProfileService>(() => MockProfileService());
    getIt.registerLazySingleton<TransactionService>(() => MockTransactionService());
    getIt.registerLazySingleton<MachineCommunicationService>(() => MockMachineCommunicationService());
    getIt.registerLazySingleton<MachineService>(() => mockMachineService);
    getIt.registerLazySingleton<ThemeManager>(() => MockThemeManager());
    getIt.registerLazySingleton<LocationService>(() => mockLocationService);
    getIt.registerLazySingleton<EdgeFunctionService>(() => MockEdgeFunctionService());

    // Mock location service
    when(() => mockLocationService.getLocations()).thenAnswer((_) async => [
      {"Address": "Test Location 1", "id": 1},
      {"Address": "Test Location 2", "id": 2},
    ]);

    // Mock machine service
    when(() => mockMachineService.getMachineById(any())).thenAnswer((_) async => {
      'id': '123',
      'name': 'Mock Machine',
      'status': 'available',
    });

    when(() => mockMachineService.getWasherCountByLocation(any())).thenAnswer((_) async => 5);
    when(() => mockMachineService.getIdleWasherCountByLocation(any())).thenAnswer((_) async => 2);
    when(() => mockMachineService.getDryerCountByLocation(any())).thenAnswer((_) async => 3);
    when(() => mockMachineService.getIdleDryerCountByLocation(any())).thenAnswer((_) async => 1);

    // Mock auth stream
    when(() => mockAuthService.onAuthChange).thenAnswer((_) => Stream<bool>.fromIterable([true, false]));

    final auth = getIt<AuthService>();
    router = RouterService().createRouter(auth);
  });

  testWidgets('Navigate to /login', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/login');
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Navigate to /signup', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/signup');
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('Navigate to /settings', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.byType(Settings), findsOneWidget);
  });

  testWidgets('Navigate to /homePage', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/homePage');
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Select Location'), findsOneWidget);
  });

  testWidgets('Navigate to /loading', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/loading');
    await tester.pumpAndSettle();
    expect(find.byType(LoadingPage), findsOneWidget);
  });

  testWidgets('Navigate to /loyalty', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/loyalty');
    await tester.pumpAndSettle();
    expect(find.byType(LoyaltyPage), findsOneWidget);
  });

  testWidgets('Navigate to /scanner', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/scanner');
    await tester.pumpAndSettle();
    expect(find.byType(ScannerWidget), findsOneWidget);
  });

  testWidgets('Navigate to /paymentPage with machineId', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/paymentPage?machineId=123');
    await tester.pumpAndSettle();
    expect(find.byType(PaymentPage), findsOneWidget);
  });

  testWidgets('Navigate to /email-verification', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/email-verification');
    await tester.pumpAndSettle();
    expect(find.byType(EmailVerificationPage), findsOneWidget);
  });

  testWidgets('Navigate to /startPage', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/startPage');
    await tester.pumpAndSettle();
    expect(find.byType(StartPage), findsOneWidget);
  });

  testWidgets('Navigate to /refundPage', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/refundPage');
    await tester.pumpAndSettle();
    expect(find.byType(RefundPage), findsOneWidget);
  });

  testWidgets('Navigate to non-existent route -> NotFoundScreen', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(router));
    router.go('/doesNotExist');
    await tester.pumpAndSettle();
    expect(find.byType(NotFoundScreen), findsOneWidget);
  });
}
