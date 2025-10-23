import 'package:clean_stream_laundry_app/Logic/Authentication/AuthenticationResponses.dart';

abstract class AuthSystem{
  Future<AuthenticationResponses> login(String email, String password);
  Future<AuthenticationResponses> signUp(String email, String password);
  Future<void> logout();
  Future<AuthenticationResponses> isLoggedIn();
  String? get currentUserId;
}