import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthenticationResponses.dart';
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
      print(user?.emailConfirmedAt);

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

    final AuthResponse response = await _client.auth.signUp(
      email: email,
      password: password,
        emailRedirectTo: 'clean-stream://email-verification'
    );

    if(response.user != null){
      output = AuthenticationResponses.success;
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