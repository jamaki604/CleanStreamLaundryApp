import 'dart:async';

import 'package:clean_stream_laundry_app/features/verify_code/verify_code.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() async {
    mockAuthService = MockAuthService();
    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/verify-code',
        routes: [
          GoRoute(
            path: '/verify-code',
            builder: (_, __) =>
            const CodeVerificationPage(email: 'testEmail'),
          ),
          GoRoute(
            path: '/reset-protected',
            builder: (_, __) =>
            const Scaffold(body: Text('Reset Password')),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI elements
  // ---------------------------------------------------------------------------

  group('UI elements render correctly', () {
    testWidgets('displays Verify Code appbar title', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Verify Code'), findsOneWidget);
    });

    testWidgets('displays Enter Verification Code subheading', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Enter Verification Code'), findsOneWidget);
    });

    testWidgets('displays instruction text', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('We sent a 6-digit code to'), findsOneWidget);
    });

    testWidgets('displays email address', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('testEmail'), findsOneWidget);
    });

    testWidgets('displays TextField', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays Verify button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('displays Resend code button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Resend code'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Logic
  // ---------------------------------------------------------------------------

  group('Logic tests', () {
    testWidgets('shows error when code is too short', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '1234');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter the 6-digit code'), findsWidgets);
    });

    testWidgets('navigates to /reset-protected on valid code', (tester) async {
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsWidgets);
    });

    testWidgets('shows error when code verification fails', (tester) async {
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) async => AuthenticationResponses.failure);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Invalid or expired code'), findsWidgets);
    });

    testWidgets('shows error when exception is thrown during verification',
            (tester) async {
          when(() => mockAuthService.verifyCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          )).thenThrow(Exception());

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), '123456');
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();

          expect(find.text('Something went wrong. Try again'), findsWidgets);
        });

    testWidgets('shows success snackbar when resend succeeds', (tester) async {
      when(() => mockAuthService.resetPassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Password reset email sent! Check your email.'),
        findsWidgets,
      );
    });

    testWidgets('shows failure snackbar when resend fails', (tester) async {
      when(() => mockAuthService.resetPassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.failure);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.text('Failed to send reset email.'), findsWidgets);
    });

    testWidgets('clears error when user starts typing after error',
            (tester) async {
          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          // Trigger error
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          expect(find.text('Please enter the 6-digit code'), findsWidgets);

          // Start typing — error should clear
          await tester.enterText(find.byType(TextField), '1');
          await tester.pump();

          expect(find.text('Please enter the 6-digit code'), findsNothing);
        });

    testWidgets('shows loading indicator while verifying', (tester) async {
      final completer = Completer<AuthenticationResponses>();
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Verify'), findsNothing);

      completer.complete(AuthenticationResponses.success);
      await tester.pumpAndSettle();
    });

    testWidgets('disables Verify button while loading', (tester) async {
      final completer = Completer<AuthenticationResponses>();
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      final button =
      tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      completer.complete(AuthenticationResponses.success);
      await tester.pumpAndSettle();
    });
  });
}