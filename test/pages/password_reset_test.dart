import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/pages/password_reset.dart';
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

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }

    getIt.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() => GetIt.instance.reset());

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      initialLocation: '/password-reset',
      routes: [
        GoRoute(
          path: '/password-reset',
          builder: (context, state) => const PasswordResetPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Page')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders reset password UI', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Forgot your password?'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('validates empty email', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
  });

  testWidgets('sends reset email and shows success message', (tester) async {
    when(
      () => mockAuthService.resetPassword(any()),
    ).thenAnswer((_) async => AuthenticationResponses.success);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.resetPassword('test@example.com')).called(1);
    expect(
      find.text('Password reset email sent! Check your email.'),
      findsOneWidget,
    );
  });

  testWidgets('shows failure message when reset fails', (tester) async {
    when(
      () => mockAuthService.resetPassword(any()),
    ).thenAnswer((_) async => AuthenticationResponses.failure);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.resetPassword('test@example.com')).called(1);
    expect(find.text('Failed to send reset email.'), findsOneWidget);
  });

  testWidgets('shows error message when reset throws', (tester) async {
    when(
      () => mockAuthService.resetPassword(any()),
    ).thenThrow(Exception('network'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.resetPassword('test@example.com')).called(1);
    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('back to login navigates to login page', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login Page'), findsOneWidget);
  });

  testWidgets('back arrow navigates to login page', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Login Page'), findsOneWidget);
  });
}
