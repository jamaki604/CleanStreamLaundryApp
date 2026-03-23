import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

enum VerifyResult { success, invalid, error }

enum ResendResult { success, failed, error }

class CodeVerificationController extends ChangeNotifier {
  final AuthService authService;

  CodeVerificationController({AuthService? authService})
      : authService = authService ?? GetIt.instance<AuthService>();

  final TextEditingController codeController = TextEditingController();

  bool isLoading = false;
  String? error;

  void disposeController() {
    codeController.dispose();
  }

  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }

  Future<VerifyResult> verifyCode(String email) async {
    final code = codeController.text.trim();

    if (code.length != 6) {
      error = 'Please enter the 6-digit code';
      notifyListeners();
      return VerifyResult.invalid;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await authService.verifyCode(
        email: email,
        code: code,
      );

      if (response == AuthenticationResponses.success) {
        return VerifyResult.success;
      } else {
        error = 'Invalid or expired code';
        notifyListeners();
        return VerifyResult.invalid;
      }
    } catch (_) {
      error = 'Something went wrong. Try again';
      notifyListeners();
      return VerifyResult.error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ResendResult> sendResetEmail(String email) async {
    try {
      final response = await authService.resetPassword(email);
      if (response == AuthenticationResponses.success) {
        return ResendResult.success;
      } else {
        return ResendResult.failed;
      }
    } catch (_) {
      return ResendResult.error;
    }
  }
}