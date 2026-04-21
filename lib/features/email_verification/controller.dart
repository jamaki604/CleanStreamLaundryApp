import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

enum EmailVerifyResult { success, invalid, error }

enum EmailResendResult { success, failed, error }

class EmailVerificationController {
  final AuthService _authService = GetIt.instance<AuthService>();

  final TextEditingController codeController = TextEditingController();

  bool resent = false;
  bool isLoading = false;
  AuthenticationResponses? lastResponse;
  String? error;

  EmailVerificationController();

  void dispose() {
    codeController.dispose();
  }

  Future<void> resendVerification({String? email}) async {
    if (resent) return;

    isLoading = true;
    lastResponse = await _authService.resendVerification(email: email);
    isLoading = false;

    if (lastResponse == AuthenticationResponses.success) {
      resent = true;
    }
  }

  String? get currentEmail => _authService.getCurrentUserEmail();

  void clearError() {
    error = null;
  }

  Future<EmailVerifyResult> verifyEmailCode(String email) async {
    final code = codeController.text.trim();

    if (code.length != 6) {
      error = 'Please enter the 6-digit code';
      return EmailVerifyResult.invalid;
    }

    isLoading = true;
    error = null;

    try {
      final response = await _authService.verifyEmailCode(
        email: email,
        code: code,
      );

      if (response == AuthenticationResponses.success) {
        return EmailVerifyResult.success;
      }

      error = 'Invalid or expired code';
      return EmailVerifyResult.invalid;
    } catch (_) {
      error = 'Something went wrong. Try again';
      return EmailVerifyResult.error;
    } finally {
      isLoading = false;
    }
  }

  Future<EmailResendResult> resendVerificationEmail(String email) async {
    try {
      await resendVerification(email: email);
      if (lastResponse == AuthenticationResponses.success) {
        return EmailResendResult.success;
      }
      return EmailResendResult.failed;
    } catch (_) {
      return EmailResendResult.error;
    }
  }
}
