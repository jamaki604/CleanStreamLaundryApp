import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthService {
  Future<AuthenticationResponses> login(String email, String password);
  Future<AuthenticationResponses> signUp(
    String email,
    String password,
    String name,
  );
  Future<void> logout();
  Future<AuthenticationResponses> isLoggedIn();
  String? get getCurrentUserId;
  String getLastSignedUpUserId();
  Future<AuthenticationResponses> resendVerification();
  Stream<bool> get onAuthChange;
  bool isEmailVerified();
  Future<AuthenticationResponses> resetPassword(String email);
  Future<void> appleSignIn();
  Future<void> googleSignIn();
  Future<void> getSessionFromURI(Uri uri);
  Future<void> refreshSession();
  User? getCurrentUser();
  String? getCurrentUserEmail();
  Future<void> updateUserAttributes({
    String? email,
    Map<String, dynamic>? data,
  });
  Future<AuthenticationResponses> exchangeCodeForSession(String code);
  Future<AuthenticationResponses> updatePassword(String newPassword);
  Future<AuthenticationResponses> verifyCode({required String email, required String code});
}
