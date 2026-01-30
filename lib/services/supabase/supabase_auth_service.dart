import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService implements AuthService {
  late final SupabaseClient _client;
  String? lastSignedUpUserId;

  SupabaseAuthService({required SupabaseClient client}) {
    _client = client;
  }

  @override
  String? get getCurrentUserId {
    return _client.auth.currentUser?.id;
  }

  @override
  String getLastSignedUpUserId() {
    return lastSignedUpUserId!;
  }

  @override
  Future<AuthenticationResponses> isLoggedIn() async {
    AuthenticationResponses output = AuthenticationResponses.failure;
    try {
      await _client.auth.refreshSession();
      if (_client.auth.currentUser != null) {
        output = AuthenticationResponses.success;
      }
    } catch (e) {}
    return output;
  }

  @override
  Future<AuthenticationResponses> login(String email, String password) async {
    AuthenticationResponses output = AuthenticationResponses.failure;
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        output = AuthenticationResponses.failure;
      } else {
        output = AuthenticationResponses.success;
      }
    } on AuthApiException catch (e) {
      if (e.code == 'email_not_confirmed') {
        output = AuthenticationResponses.emailNotVerified;
      } else {
        print(e.message);
      }
    } catch (e) {
      print(e);
    }

    return output;
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<AuthenticationResponses> signUp(String email, String password) async {
    AuthenticationResponses output = AuthenticationResponses.failure;
    AuthenticationResponses validatePasswordResponse = _validatePassword(
      password,
    );

    if (validatePasswordResponse == AuthenticationResponses.success) {
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'clean-stream://email-verification',
      );

      if (response.user != null) {
        lastSignedUpUserId = response.user!.id;
        output = AuthenticationResponses.success;
      }
    } else {
      output = validatePasswordResponse;
    }

    return output;
  }

  AuthenticationResponses _validatePassword(String password) {
    AuthenticationResponses output = AuthenticationResponses.success;

    bool hasDigit = false;
    bool hasUpper = false;
    bool hasSpecialCharacter = false;

    var validSpecialCharacters = [
      '!',
      '@',
      '#',
      r'$',
      '%',
      '^',
      '&',
      '*',
      '(',
      ')',
      '_',
      '+',
      '-',
      '=',
      '[',
      ']',
      '{',
      '}',
      ';',
      ':',
      "'",
      ',',
      '.',
      '?',
      '/',
    ];

    if (password.length >= 8) {
      for (String ch in password.split('')) {
        if (int.tryParse(ch) != null) {
          hasDigit = true;
        } else if (validSpecialCharacters.contains(ch)) {
          hasSpecialCharacter = true;
        } else if (ch == ch.toUpperCase() && ch != ch.toLowerCase()) {
          hasUpper = true;
        }
      }
    } else {
      return AuthenticationResponses.lessThanMinLength;
    }

    if (!hasDigit) {
      output = AuthenticationResponses.noDigit;
    } else if (!hasUpper) {
      output = AuthenticationResponses.noUppercase;
    } else if (!hasSpecialCharacter) {
      output = AuthenticationResponses.noSpecialCharacter;
    }

    return output;
  }

  Future<AuthenticationResponses> resendVerification() async {
    AuthenticationResponses output = AuthenticationResponses.success;

    final userEmail = _client.auth.currentUser?.email;

    try {
      if (userEmail != null) {
        await _client.auth.resend(type: OtpType.signup, email: userEmail);
      } else {
        output = AuthenticationResponses.failure;
      }
    } catch (e) {
      output = AuthenticationResponses.failure;
    }

    return output;
  }

  @override
  Stream<bool> get onAuthChange {
    return _client.auth.onAuthStateChange.map((tuple) {
      final session = tuple.session;
      return session?.user != null;
    });
  }

  @override
  bool isEmailVerified() {
    return _client.auth.currentUser?.emailConfirmedAt != null;
  }

  @override
  Future<AuthenticationResponses> resetPassword(String email) async {
    AuthenticationResponses output = AuthenticationResponses.failure;
    try {
      // Send password reset email and redirect back to the app via deep link.
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'clean-stream://reset-protected',
      );
      output = AuthenticationResponses.success;
    } catch (e) {
      print('resetPassword error: $e');
      output = AuthenticationResponses.failure;
    }
    return output;
  }

  @override
  Future<AuthenticationResponses> exchangeCodeForSession(String code) async {
    AuthenticationResponses output = AuthenticationResponses.failure;
    try {
      final response = await _client.auth.exchangeCodeForSession(code);
      if (response.session?.user != null) {
        output = AuthenticationResponses.success;
      }
    } catch (e) {
      output = AuthenticationResponses.failure;
    }
    return output;
  }

  @override
  Future<AuthenticationResponses> updatePassword(String newPassword) async {
    AuthenticationResponses output = AuthenticationResponses.failure;
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
      output = AuthenticationResponses.success;
    } catch (e) {
      output = AuthenticationResponses.failure;
    }
    return output;
  }
}
