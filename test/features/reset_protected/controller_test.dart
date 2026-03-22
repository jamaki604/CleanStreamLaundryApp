import 'package:clean_stream_laundry_app/features/reset_protected/controller.dart';
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

  ResetProtectedController buildController() =>
      ResetProtectedController(authService: mockAuthService);

  group('Visibility toggles', () {
    test('togglePasswordVisibility flips obscurePassword', () {
      final controller = buildController();

      expect(controller.obscurePassword, isTrue);
      controller.togglePasswordVisibility();
      expect(controller.obscurePassword, isFalse);
      controller.togglePasswordVisibility();
      expect(controller.obscurePassword, isTrue);
    });

    test('toggleConfirmVisibility flips obscureConfirm', () {
      final controller = buildController();

      expect(controller.obscureConfirm, isTrue);
      controller.toggleConfirmVisibility();
      expect(controller.obscureConfirm, isFalse);
    });

    test('togglePasswordVisibility notifies listeners', () {
      final controller = buildController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.togglePasswordVisibility();
      expect(notified, isTrue);
    });
  });

  group('Color state', () {
    test('changeColorsToRed sets labels and colors to red', () {
      final controller = buildController();

      controller.changeColorsToRed("Passwords don't match");

      expect(controller.passwordLabel, "Passwords don't match");
      expect(controller.confirmLabel, "Passwords don't match");
      expect(controller.iconColor, Colors.red);
      expect(controller.labelColor, Colors.red);
    });

    test('resetColors restores default labels and colors', () {
      final controller = buildController();
      controller.changeColorsToRed('Some error');

      controller.resetColors();

      expect(controller.passwordLabel, 'New Password');
      expect(controller.confirmLabel, 'Confirm Password');
      expect(controller.iconColor, Colors.blue);
      expect(controller.labelColor, Colors.blue);
    });

    test('changeColorsToRed notifies listeners', () {
      final controller = buildController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.changeColorsToRed('Error');
      expect(notified, isTrue);
    });
  });

  group('onPasswordChanged', () {
    test('resets colors when iconColor is red', () {
      final controller = buildController();
      controller.changeColorsToRed('Error');

      controller.onPasswordChanged();

      expect(controller.iconColor, Colors.blue);
    });

    test('does nothing when iconColor is not red', () {
      final controller = buildController();

      controller.onPasswordChanged();

      expect(controller.passwordLabel, 'New Password');
    });
  });

  group('onConfirmChanged', () {
    test('sets red colors when passwords do not match', () {
      final controller = buildController();
      controller.passwordController.text = 'Password1!';
      controller.confirmController.text = 'Different1!';

      controller.onConfirmChanged();

      expect(controller.iconColor, Colors.red);
      expect(controller.passwordLabel, "Passwords don't match");
    });

    test('resets colors when passwords match', () {
      final controller = buildController();
      controller.passwordController.text = 'Password1!';
      controller.confirmController.text = 'Password1!';

      controller.onConfirmChanged();

      expect(controller.iconColor, Colors.blue);
      expect(controller.passwordLabel, 'New Password');
    });
  });


  group('submit', () {
    test('returns error message when password field is empty', () async {
      final controller = buildController();
      controller.passwordController.text = '';
      controller.confirmController.text = 'Password1!';

      final result = await controller.submit();

      expect(result, 'Please fill in all fields');
      verifyNever(() => mockAuthService.updatePassword(any()));
    });

    test('returns error message when confirm field is empty', () async {
      final controller = buildController();
      controller.passwordController.text = 'Password1!';
      controller.confirmController.text = '';

      final result = await controller.submit();

      expect(result, 'Please fill in all fields');
      verifyNever(() => mockAuthService.updatePassword(any()));
    });

    test('returns mismatch error when passwords differ', () async {
      final controller = buildController();
      controller.passwordController.text = 'Password1!';
      controller.confirmController.text = 'Different1!';

      final result = await controller.submit();

      expect(result, "Passwords don't match");
      expect(controller.iconColor, Colors.red);
      verifyNever(() => mockAuthService.updatePassword(any()));
    });

    test('returns requirement error from PasswordParser for weak password',
            () async {
          final controller = buildController();
          controller.passwordController.text = 'weak';
          controller.confirmController.text = 'weak';

          final result = await controller.submit();

          expect(result, isNotNull); // PasswordParser returned a requirement
          expect(controller.iconColor, Colors.red);
          verifyNever(() => mockAuthService.updatePassword(any()));
        });

    test('returns null and calls updatePassword on valid matching passwords',
            () async {
          when(() => mockAuthService.updatePassword(any()))
              .thenAnswer((_) async => AuthenticationResponses.success);

          final controller = buildController();
          controller.passwordController.text = 'StrongPass1!';
          controller.confirmController.text = 'StrongPass1!';

          final result = await controller.submit();

          expect(result, isNull);
          verify(() => mockAuthService.updatePassword('StrongPass1!')).called(1);
        });

    test('trims whitespace from password before submitting', () async {
      when(() => mockAuthService.updatePassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();
      controller.passwordController.text = '  StrongPass1!  ';
      controller.confirmController.text = '  StrongPass1!  ';

      await controller.submit();

      verify(() => mockAuthService.updatePassword('StrongPass1!')).called(1);
    });

    test('sets and clears isLoading around updatePassword', () async {
      when(() => mockAuthService.updatePassword(any()))
          .thenAnswer((_) async => AuthenticationResponses.success);

      final controller = buildController();
      controller.passwordController.text = 'StrongPass1!';
      controller.confirmController.text = 'StrongPass1!';

      final future = controller.submit();
      expect(controller.isLoading, isTrue);

      await future;
      expect(controller.isLoading, isFalse);
    });

    test('clears isLoading even when service throws', () async {
      when(() => mockAuthService.updatePassword(any()))
          .thenThrow(Exception('network'));

      final controller = buildController();
      controller.passwordController.text = 'StrongPass1!';
      controller.confirmController.text = 'StrongPass1!';

      await expectLater(controller.submit(), throwsException);
      expect(controller.isLoading, isFalse);
    });

    test('notifies listeners twice — once for isLoading true, once false',
            () async {
          when(() => mockAuthService.updatePassword(any()))
              .thenAnswer((_) async => AuthenticationResponses.success);

          final controller = buildController();
          controller.passwordController.text = 'StrongPass1!';
          controller.confirmController.text = 'StrongPass1!';

          var notifyCount = 0;
          controller.addListener(() => notifyCount++);

          await controller.submit();

          expect(notifyCount, 2);
        });
  });
}