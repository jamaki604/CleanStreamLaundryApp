import 'package:clean_stream_laundry_app/Logic/Authentication/auth_system.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/authentication_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authenticator implements AuthSystem{

  final SupabaseClient _client;

  Authenticator(this._client);

  @override
  String? get currentUserId {
    return _client.auth.currentUser?.id;
  }

  @override
  Future<AuthenticationResponses> isLoggedIn() async {
    AuthenticationResponses output = AuthenticationResponses.failure;
    try {
      await _client.auth.refreshSession();
      if(_client.auth.currentUser != null){
        output = AuthenticationResponses.success;
      }
    } catch (e) {

    }
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

    }on AuthApiException catch (e) {
      if (e.code == 'email_not_confirmed') {
        output = AuthenticationResponses.emailNotVerified;
      } else {
        print(e.message);
      }
    }catch(e){
      print(e);
    }

    return output;
  }

  @override
  Future<void> logout() async{
    await _client.auth.signOut();
  }

  @override
  Future<AuthenticationResponses> signUp(String email, String password) async{
    AuthenticationResponses output = AuthenticationResponses.failure;
    AuthenticationResponses validatePasswordResponse = _validatePassword(password);

    if(validatePasswordResponse == AuthenticationResponses.success) {
      final AuthResponse response = await _client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: 'clean-stream://email-verification'
      );

      if (response.user != null) {
        output = AuthenticationResponses.success;
      }
    }else{
      output = validatePasswordResponse;
    }

    return output;
  }

  AuthenticationResponses _validatePassword(String password) {
    AuthenticationResponses output = AuthenticationResponses.success;

    bool hasDigit = false;
    bool hasUpper = false;
    bool hasSpecialCharacter = false;

    var validSpecialCharacters = ['!', '@', '#', r'$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', '{', '}', ';', ':', "'", ',', '.', '?', '/'];

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
        await _client.auth.resend(
          type: OtpType.signup,
          email: userEmail,
        );
      }else{
        output = AuthenticationResponses.failure;
      }
    }catch(e){
      output = AuthenticationResponses.failure;
    }

    return output;
  }
}