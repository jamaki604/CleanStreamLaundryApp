import 'package:clean_stream_laundry_app/Logic/Supabase/authentication_response_enum.dart';

abstract class AuthService{
  Future<AuthenticationResponses> login(String email, String password);
  Future<AuthenticationResponses> signUp(String email, String password);
  Future<void> logout();
  Future<AuthenticationResponses> isLoggedIn();
  String? get getCurrentUserId;
  Future<AuthenticationResponses> resendVerification();
}