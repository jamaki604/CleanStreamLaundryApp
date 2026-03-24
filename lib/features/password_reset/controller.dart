import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PasswordResetController extends ChangeNotifier {
  final AuthService authService;

  PasswordResetController({AuthService? authService})
      : authService = authService ?? GetIt.instance<AuthService>();

  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  void disposeController() {
    emailController.dispose();
  }

  String? validateEmail(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<AuthenticationResponses?> sendResetEmail() async {
    if (!formKey.currentState!.validate()) return null;

    isLoading = true;
    notifyListeners();

    try {
      final response = await authService.resetPassword(
        emailController.text.trim(),
      );
      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}