abstract class AuthSystem{
  Future<bool> login(String email, String password);
  Future<bool> signUp(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  String? get currentUserId;
}