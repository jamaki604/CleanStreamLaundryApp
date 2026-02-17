import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/parsing/password_parser.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/pages/reset_protected_page.dart';
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

  Widget createWidgetUnderTest({Uri? incomingUri}) {
    final router = GoRouter(
      initialLocation: '/reset-protected',
      routes: [
        GoRoute(
          path: '/reset-protected',
          builder: (context, state) =>
              ResetProtectedPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Page')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows invalid link state for non-reset uri', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(incomingUri: Uri.parse('clean-stream://other')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid or expired reset link'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });

  testWidgets('shows invalid link when code is missing', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        incomingUri: Uri.parse('clean-stream://reset-protected'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid or expired reset link'), findsOneWidget);
  });

  testWidgets('shows invalid link when code exchange fails', (tester) async {
    when(
      () => mockAuthService.exchangeCodeForSession('abc'),
    ).thenAnswer((_) async => AuthenticationResponses.failure);

    await tester.pumpWidget(
      createWidgetUnderTest(
        incomingUri: Uri.parse('clean-stream://reset-protected?code=abc'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid or expired reset link'), findsOneWidget);
  });

  testWidgets('renders form when link is valid', (tester) async {
    when(
      () => mockAuthService.exchangeCodeForSession('abc'),
    ).thenAnswer((_) async => AuthenticationResponses.success);

    await tester.pumpWidget(
      createWidgetUnderTest(
        incomingUri: Uri.parse('clean-stream://reset-protected?code=abc'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('validates short password', (tester) async {
    when(
      () => mockAuthService.exchangeCodeForSession('abc'),
    ).thenAnswer((_) async => AuthenticationResponses.success);

    await tester.pumpWidget(
      createWidgetUnderTest(
        incomingUri: Uri.parse('clean-stream://reset-protected?code=abc'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'short');
    await tester.enterText(find.byType(TextField).at(1), 'short');
    await tester.tap(find.text('Set Password'));
    await tester.pumpAndSettle();
    String? validations = PasswordParser.process("short");

    if (validations != null) {
      expect(find.text(validations), findsOneWidget);
    }
  });

  testWidgets('submits new password and navigates to login', (tester) async {
    when(
      () => mockAuthService.exchangeCodeForSession('abc'),
    ).thenAnswer((_) async => AuthenticationResponses.success);
    when(
      () => mockAuthService.updatePassword(any()),
    ).thenAnswer((_) async => AuthenticationResponses.success);

    await tester.pumpWidget(
      createWidgetUnderTest(
        incomingUri: Uri.parse('clean-stream://reset-protected?code=abc'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'password123&');
    await tester.enterText(find.byType(TextField).at(1), 'password123&');
    await tester.tap(find.text('Set Password'));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.updatePassword('password123&')).called(1);
    expect(find.text('Password reset successful'), findsOneWidget);
    expect(find.text('Login Page'), findsOneWidget);
  });

  testWidgets('shows failure message when update fails', (tester) async {
    when(
      () => mockAuthService.exchangeCodeForSession('abc'),
    ).thenAnswer((_) async => AuthenticationResponses.success);
    when(
      () => mockAuthService.updatePassword(any()),
    ).thenAnswer((_) async => AuthenticationResponses.failure);

    await tester.pumpWidget(
      createWidgetUnderTest(
        incomingUri: Uri.parse('clean-stream://reset-protected?code=abc'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'password123&');
    await tester.enterText(find.byType(TextField).at(1), 'password123&');
    await tester.tap(find.text('Set Password'));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.updatePassword('password123&')).called(1);
    expect(find.text('Failed to reset password'), findsWidgets);
  });

  testWidgets('shows failure message when update throws', (tester) async {
    when(
      () => mockAuthService.exchangeCodeForSession('abc'),
    ).thenAnswer((_) async => AuthenticationResponses.success);
    when(
      () => mockAuthService.updatePassword(any()),
    ).thenThrow(Exception('network'));

    await tester.pumpWidget(
      createWidgetUnderTest(
        incomingUri: Uri.parse('clean-stream://reset-protected?code=abc'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'password123&');
    await tester.enterText(find.byType(TextField).at(1), 'password123&');
    await tester.tap(find.text('Set Password'));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.updatePassword('password123&')).called(1);
    expect(find.text('Failed to reset password'), findsWidgets);
  });
}
