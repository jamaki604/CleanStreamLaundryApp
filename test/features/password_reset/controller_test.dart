import 'dart:async';
import 'package:clean_stream_laundry_app/features/password_reset/controller.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  PasswordResetController buildController() =>
      PasswordResetController(authService: mockAuthService);

  group('validateEmail', () {
    test('returns error for null value', () {
      final controller = buildController();
      expect(controller.validateEmail(null), 'Please enter your email');
    });

    test('returns error for empty string', () {
      final controller = buildController();
      expect(controller.validateEmail(''), 'Please enter your email');
    });

    test('returns error for invalid email — missing @', () {
      final controller = buildController();
      expect(
        controller.validateEmail('notanemail'),
        'Please enter a valid email address',
      );
    });

    test('returns error for invalid email — missing domain', () {
      final controller = buildController();
      expect(
        controller.validateEmail('user@'),
        'Please enter a valid email address',
      );
    });

    test('returns error for invalid email — missing TLD', () {
      final controller = buildController();
      expect(
        controller.validateEmail('user@domain'),
        'Please enter a valid email address',
      );
    });

    test('returns null for valid email', () {
      final controller = buildController();
      expect(controller.validateEmail('user@example.com'), isNull);
    });

    test('returns null for valid email with subdomain', () {
      final controller = buildController();
      expect(controller.validateEmail('user@mail.example.com'), isNull);
    });
  });

  group('sendResetEmail', () {
    testWidgets('returns null without calling service when validation fails',
            (tester) async {
          final controller = buildController();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Form(
                  key: controller.formKey,
                  child: TextFormField(
                    controller: controller.emailController,
                    validator: controller.validateEmail,
                  ),
                ),
              ),
            ),
          );

          controller.emailController.text = '';
          final result = await controller.sendResetEmail();

          expect(result, isNull);
          verifyNever(() => mockAuthService.resetPassword(any()));
        });

    testWidgets('calls resetPassword with trimmed email on valid input',
            (tester) async {
          when(() => mockAuthService.resetPassword(any()))
              .thenAnswer((_) async => AuthenticationResponses.success);

          final controller = buildController();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Form(
                  key: controller.formKey,
                  child: TextFormField(
                    controller: controller.emailController,
                    validator: controller.validateEmail,
                  ),
                ),
              ),
            ),
          );

          controller.emailController.text = '  test@example.com  ';
          await controller.sendResetEmail();

          verify(() => mockAuthService.resetPassword('test@example.com'))
              .called(1);
        });

    testWidgets('returns success response from service', (tester) async {
      when(() => mockAuthService.resetPassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: controller.formKey,
              child: TextFormField(
                controller: controller.emailController,
                validator: controller.validateEmail,
              ),
            ),
          ),
        ),
      );

      controller.emailController.text = 'test@example.com';
      final result = await controller.sendResetEmail();

      expect(result, AuthenticationResponses.success);
    });

    testWidgets('returns failure response from service', (tester) async {
      when(() => mockAuthService.resetPassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.failure);

      final controller = buildController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: controller.formKey,
              child: TextFormField(
                controller: controller.emailController,
                validator: controller.validateEmail,
              ),
            ),
          ),
        ),
      );

      controller.emailController.text = 'test@example.com';
      final result = await controller.sendResetEmail();

      expect(result, AuthenticationResponses.failure);
    });

    testWidgets('sets and clears isLoading around the service call',
            (tester) async {
          final completer = Completer<AuthenticationResponses>();
          when(() => mockAuthService.resetPassword(any()))
              .thenAnswer((_) => completer.future);

          final controller = buildController();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Form(
                  key: controller.formKey,
                  child: TextFormField(
                    controller: controller.emailController,
                    validator: controller.validateEmail,
                  ),
                ),
              ),
            ),
          );

          controller.emailController.text = 'test@example.com';
          final future = controller.sendResetEmail();

          expect(controller.isLoading, isTrue);

          completer.complete(AuthenticationResponses.success);
          await future;

          expect(controller.isLoading, isFalse);
        });

    testWidgets('clears isLoading even when service throws', (tester) async {
      when(() => mockAuthService.resetPassword(any()))
          .thenThrow(Exception('network'));

      final controller = buildController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: controller.formKey,
              child: TextFormField(
                controller: controller.emailController,
                validator: controller.validateEmail,
              ),
            ),
          ),
        ),
      );

      controller.emailController.text = 'test@example.com';

      await expectLater(controller.sendResetEmail(), throwsException);

      expect(controller.isLoading, isFalse);
    });

    testWidgets('notifies listeners when isLoading changes', (tester) async {
      when(() => mockAuthService.resetPassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: controller.formKey,
              child: TextFormField(
                controller: controller.emailController,
                validator: controller.validateEmail,
              ),
            ),
          ),
        ),
      );

      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.emailController.text = 'test@example.com';
      await controller.sendResetEmail();

      // One notify for isLoading = true, one for isLoading = false
      expect(notifyCount, 2);
    });
  });
}