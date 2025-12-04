import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/pages/not_found_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();

    // Default stubs to prevent null errors
    when(
      () => mockAuthService.isLoggedIn(),
    ).thenAnswer((_) async => AuthenticationResponses.failure);
    when(() => mockAuthService.isEmailVerified()).thenReturn(false);
    when(
      () => mockAuthService.login(any(), any()),
    ).thenAnswer((_) async => AuthenticationResponses.failure);
    when(
      () => mockAuthService.signUp(any(), any()),
    ).thenAnswer((_) async => AuthenticationResponses.failure);
    when(
      () => mockAuthService.resendVerification(),
    ).thenAnswer((_) async => AuthenticationResponses.failure);
    when(
      () => mockAuthService.logout(),
    ).thenAnswer((_) async => Future.value());
    when(() => mockAuthService.getCurrentUserId).thenReturn(null);
    when(
      () => mockAuthService.onAuthChange,
    ).thenAnswer((_) => const Stream<bool>.empty());

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }

    getIt.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() => GetIt.instance.reset());

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const NotFoundScreen()),
        GoRoute(
          path: '/homePage',
          builder: (context, state) => const Scaffold(body: Text('Home Page')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Page')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  void mockAuthResponse(AuthenticationResponses response) {
    when(() => mockAuthService.isLoggedIn()).thenAnswer((_) async => response);
  }

  group('NotFoundScreen Widget Tests', () {
    testWidgets('should display 404 error icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.size, 80);
      expect(icon.color, Colors.redAccent);
    });

    testWidgets('should display 404 - Page Not Found text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('404 - Page Not Found'), findsOneWidget);

      final text = tester.widget<Text>(find.text('404 - Page Not Found'));
      expect(text.style?.fontSize, 24);
      expect(text.style?.color, Colors.blue);
    });

    testWidgets('should display Go to Home button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Go to Home'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should navigate to home page when user is logged in', (
      WidgetTester tester,
    ) async {
      mockAuthResponse(AuthenticationResponses.success);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Go to Home'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
      verify(() => mockAuthService.isLoggedIn()).called(1);
    });

    testWidgets('should navigate to login page when user is not logged in', (
      WidgetTester tester,
    ) async {
      mockAuthResponse(AuthenticationResponses.failure);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Go to Home'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
      verify(() => mockAuthService.isLoggedIn()).called(1);
    });

    testWidgets('Go to Home button should be tappable', (
      WidgetTester tester,
    ) async {
      mockAuthResponse(AuthenticationResponses.success);

      await tester.pumpWidget(createWidgetUnderTest());

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should handle auth check when button is pressed', (
      WidgetTester tester,
    ) async {
      mockAuthResponse(AuthenticationResponses.success);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Go to Home'));
      await tester.pump();

      verify(() => mockAuthService.isLoggedIn()).called(1);
    });
  });
}
