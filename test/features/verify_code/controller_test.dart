import 'dart:async';

import 'package:clean_stream_laundry_app/features/verify_code/controller.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  CodeVerificationController buildController() =>
      CodeVerificationController(authService: mockAuthService);

  // ---------------------------------------------------------------------------
  // clearError
  // ---------------------------------------------------------------------------

  group('clearError', () {
    test('clears error and notifies when error is set', () {
      final c = buildController();
      c.error = 'Some error';
      var notified = false;
      c.addListener(() => notified = true);

      c.clearError();

      expect(c.error, isNull);
      expect(notified, isTrue);
    });

    test('does nothing when error is already null', () {
      final c = buildController();
      var notified = false;
      c.addListener(() => notified = true);

      c.clearError();

      expect(notified, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // verifyCode
  // ---------------------------------------------------------------------------

  group('verifyCode', () {
    test('returns invalid and sets error when code is shorter than 6 digits',
            () async {
          final c = buildController();
          c.codeController.text = '1234';

          final result = await c.verifyCode('test@example.com');

          expect(result, VerifyResult.invalid);
          expect(c.error, 'Please enter the 6-digit code');
          verifyNever(() => mockAuthService.verifyCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ));
        });

    test('returns invalid and sets error when code is longer than 6 digits',
            () async {
          final c = buildController();
          c.codeController.text = '1234567';

          final result = await c.verifyCode('test@example.com');

          expect(result, VerifyResult.invalid);
          expect(c.error, 'Please enter the 6-digit code');
        });

    test('returns success on AuthenticationResponses.success', () async {
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) async => AuthenticationResponses.success);

      final c = buildController();
      c.codeController.text = '123456';

      final result = await c.verifyCode('test@example.com');

      expect(result, VerifyResult.success);
      expect(c.error, isNull);
    });

    test('calls verifyCode with correct email and code', () async {
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) async => AuthenticationResponses.success);

      final c = buildController();
      c.codeController.text = '654321';

      await c.verifyCode('user@example.com');

      verify(() => mockAuthService.verifyCode(
        email: 'user@example.com',
        code: '654321',
      )).called(1);
    });

    test('returns invalid and sets error on failure response', () async {
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) async => AuthenticationResponses.failure);

      final c = buildController();
      c.codeController.text = '123456';

      final result = await c.verifyCode('test@example.com');

      expect(result, VerifyResult.invalid);
      expect(c.error, 'Invalid or expired code');
    });

    test('returns error and sets error on exception', () async {
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenThrow(Exception('network'));

      final c = buildController();
      c.codeController.text = '123456';

      final result = await c.verifyCode('test@example.com');

      expect(result, VerifyResult.error);
      expect(c.error, 'Something went wrong. Try again');
    });

    test('sets and clears isLoading around service call', () async {
      final completer = Completer<AuthenticationResponses>();
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) => completer.future);

      final c = buildController();
      c.codeController.text = '123456';

      final future = c.verifyCode('test@example.com');
      expect(c.isLoading, isTrue);

      completer.complete(AuthenticationResponses.success);
      await future;
      expect(c.isLoading, isFalse);
    });

    test('clears isLoading even when service throws', () async {
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenThrow(Exception());

      final c = buildController();
      c.codeController.text = '123456';

      await c.verifyCode('test@example.com');
      expect(c.isLoading, isFalse);
    });

    test('notifies listeners on loading state transitions', () async {
      when(() => mockAuthService.verifyCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      )).thenAnswer((_) async => AuthenticationResponses.success);

      final c = buildController();
      c.codeController.text = '123456';

      var notifyCount = 0;
      c.addListener(() => notifyCount++);

      await c.verifyCode('test@example.com');

      // At minimum: isLoading=true, then isLoading=false
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });

  // ---------------------------------------------------------------------------
  // sendResetEmail
  // ---------------------------------------------------------------------------

  group('sendResetEmail', () {
    test('returns success on AuthenticationResponses.success', () async {
      when(() => mockAuthService.resetPassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.success);

      final c = buildController();
      final result = await c.sendResetEmail('test@example.com');

      expect(result, ResendResult.success);
    });

    test('returns failed on non-success response', () async {
      when(() => mockAuthService.resetPassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.failure);

      final c = buildController();
      final result = await c.sendResetEmail('test@example.com');

      expect(result, ResendResult.failed);
    });

    test('returns error on thrown exception', () async {
      when(() => mockAuthService.resetPassword(any()))
          .thenThrow(Exception('network'));

      final c = buildController();
      final result = await c.sendResetEmail('test@example.com');

      expect(result, ResendResult.error);
    });

    test('calls resetPassword with correct email', () async {
      when(() => mockAuthService.resetPassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.success);

      final c = buildController();
      await c.sendResetEmail('user@example.com');

      verify(() => mockAuthService.resetPassword('user@example.com'))
          .called(1);
    });
  });
}