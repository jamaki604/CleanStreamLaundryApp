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
      } else if (user.emailConfirmedAt == null) {
        output = AuthenticationResponses.emailNotVerified;
      } else {
        return AuthenticationResponses.success;
      }
    }catch (e){

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
    );

    if(response.user != null){
      output = AuthenticationResponses.success;
    }

    return output;
  }

}