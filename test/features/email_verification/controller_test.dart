import 'package:clean_stream_laundry_app/features/email_verification/controller.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockAuthService = MockAuthService();
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  EmailVerificationController buildController() =>
      EmailVerificationController();

  // ---------------------------------------------------------------------------
  // resendVerification
  // ---------------------------------------------------------------------------

  group('resendVerification', () {
    test('calls auth service resendVerification', () async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();

      await controller.resendVerification();

      verify(() => mockAuthService.resendVerification()).called(1);
    });

    test('passes email when provided', () async {
      const email = 'verify@example.com';
      when(
        () => mockAuthService.resendVerification(email: email),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();

      await controller.resendVerification(email: email);

      verify(() => mockAuthService.resendVerification(email: email)).called(1);
    });

    test('sets resent to true on success', () async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();

      await controller.resendVerification();

      expect(controller.resent, isTrue);
      expect(controller.lastResponse, AuthenticationResponses.success);
    });

    test('sets lastResponse on failure and keeps resent false', () async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.failure);

      final controller = buildController();

      await controller.resendVerification();

      expect(controller.resent, isFalse);
      expect(controller.lastResponse, AuthenticationResponses.failure);
    });

    test('does not call service again when already resent', () async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();

      await controller.resendVerification();
      await controller.resendVerification();

      verify(() => mockAuthService.resendVerification()).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // verifyEmailCode
  // ---------------------------------------------------------------------------

  group('verifyEmailCode', () {
    test('returns invalid when code is not 6 digits', () async {
      final controller = buildController();
      controller.codeController.text = '123';

      final result = await controller.verifyEmailCode('user@example.com');

      expect(result, EmailVerifyResult.invalid);
      expect(controller.error, 'Please enter the 6-digit code');
      verifyNever(
        () => mockAuthService.verifyEmailCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      );
    });

    test('returns success when auth service verifies code', () async {
      when(
        () => mockAuthService.verifyEmailCode(
          email: 'user@example.com',
          code: '123456',
        ),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();
      controller.codeController.text = '123456';

      final result = await controller.verifyEmailCode('user@example.com');

      expect(result, EmailVerifyResult.success);
      expect(controller.error, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('returns invalid when auth service rejects code', () async {
      when(
        () => mockAuthService.verifyEmailCode(
          email: 'user@example.com',
          code: '123456',
        ),
      ).thenAnswer((_) async => AuthenticationResponses.failure);

      final controller = buildController();
      controller.codeController.text = '123456';

      final result = await controller.verifyEmailCode('user@example.com');

      expect(result, EmailVerifyResult.invalid);
      expect(controller.error, 'Invalid or expired code');
      expect(controller.isLoading, isFalse);
    });

    test('returns error when auth service throws', () async {
      when(
        () => mockAuthService.verifyEmailCode(
          email: 'user@example.com',
          code: '123456',
        ),
      ).thenThrow(Exception('network'));

      final controller = buildController();
      controller.codeController.text = '123456';

      final result = await controller.verifyEmailCode('user@example.com');

      expect(result, EmailVerifyResult.error);
      expect(controller.error, 'Something went wrong. Try again');
      expect(controller.isLoading, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // resendVerificationEmail
  // ---------------------------------------------------------------------------

  group('resendVerificationEmail', () {
    test('returns success when resend succeeds', () async {
      when(
        () => mockAuthService.resendVerification(email: 'user@example.com'),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();

      final result = await controller.resendVerificationEmail(
        'user@example.com',
      );

      expect(result, EmailResendResult.success);
    });

    test('returns failed when resend returns non-success', () async {
      when(
        () => mockAuthService.resendVerification(email: 'user@example.com'),
      ).thenAnswer((_) async => AuthenticationResponses.failure);

      final controller = buildController();

      final result = await controller.resendVerificationEmail(
        'user@example.com',
      );

      expect(result, EmailResendResult.failed);
    });

    test('returns error when resend throws', () async {
      when(
        () => mockAuthService.resendVerification(email: 'user@example.com'),
      ).thenThrow(Exception('network'));

      final controller = buildController();

      final result = await controller.resendVerificationEmail(
        'user@example.com',
      );

      expect(result, EmailResendResult.error);
    });
  });

  // ---------------------------------------------------------------------------
  // helpers
  // ---------------------------------------------------------------------------

  group('helpers', () {
    test('currentEmail reads from auth service', () {
      when(
        () => mockAuthService.getCurrentUserEmail(),
      ).thenReturn('user@example.com');

      final controller = buildController();

      expect(controller.currentEmail, 'user@example.com');
    });

    test('clearError clears existing error', () {
      final controller = buildController();
      controller.error = 'test error';

      controller.clearError();

      expect(controller.error, isNull);
    });

    test('dispose does not throw', () {
      final controller = buildController();

      expect(() => controller.dispose(), returnsNormally);
    });
  });
}
