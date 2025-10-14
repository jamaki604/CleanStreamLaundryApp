import 'package:clean_stream_laundry_app/Authentication/AuthSystem.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authenticator implements AuthSystem{

  final SupabaseClient _client;

  Authenticator(this._client);

  @override
  String? get currentUserId {
    return _client.auth.currentUser?.id;
  }

  @override
  bool get isLoggedIn => _client.auth.currentUser != null;

  @override
  Future<bool> login(String email, String password) async {
    final AuthResponse response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.session != null;
  }

  @override
  Future<void> logout() async{
    await _client.auth.signOut();
  }

  @override
  Future<bool> signUp(String email, String password) async{
    final AuthResponse response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return response.user != null;
  }

}