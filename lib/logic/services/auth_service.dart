import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';

abstract class AuthService{
  Future<AuthenticationResponses> login(String email, String password);
  Future<AuthenticationResponses> signUp(String email, String password);
  Future<void> logout();
  Future<AuthenticationResponses> isLoggedIn();
  String? get getCurrentUserId;
  String getLastSignedUpUserId();
  Future<AuthenticationResponses> resendVerification();
  Stream<bool> get onAuthChange;
  bool isEmailVerified();
  Future<AuthenticationResponses> appleSignIn();
  Future<void> googleSignIn();
  Future<void> handleOAuthRedirect(Uri uri);
}