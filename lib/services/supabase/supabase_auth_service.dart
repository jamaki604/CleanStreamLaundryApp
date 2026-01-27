import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:flutter/foundation.dart';
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
  Future<AuthenticationResponses> signUp(
    String email,
    String password,
    String name,
  ) async {
    AuthenticationResponses output = AuthenticationResponses.failure;
    AuthenticationResponses validatePasswordResponse = _validatePassword(
      password,
    );

    if (validatePasswordResponse == AuthenticationResponses.success) {
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'clean-stream://email-verification',
        data: {"full_name": name},
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
  Future<void> appleSignIn() async {
    if (!kIsWeb) {
      try {
        await _client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: "clean-stream://oauth",
        );
      } catch (e) {}
    } else {
      //We don't have to worry about return type because it will navigate away during web and navigate back and login page will detect session or not
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: "http://localhost:8080/loading",
      );
    }
  }

  @override
  Future<void> googleSignIn() async {
    if (!kIsWeb) {
      try {
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: "clean-stream://oauth",
        );
      } catch (e) {}
    } else {
      //We don't have to worry about return type because it will navigate away during web and navigate back and login page will detect session or not
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: "http://localhost:8080/loading",
      );
    }
  }

  @override
  Future<void> handleOAuthRedirect(Uri uri) async {
    await _client.auth.getSessionFromUrl(uri);
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  @override
  Future<void> refreshSession() async {
    final session = _client.auth.currentSession;
    if (session != null) {
      await _client.auth.refreshSession();
    }
  }

  @override
  String? getCurrentUserEmail() {
    return _client.auth.currentUser?.email;
  }

  @override
  Future<void> updateUserAttributes({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    final response = await _client.auth.updateUser(
      UserAttributes(email: email, data: data),
      emailRedirectTo: "clean-stream://change-email"
    );

    if (response.user == null) {
      throw Exception("Failed to update user attributes");
    }
  }
}
