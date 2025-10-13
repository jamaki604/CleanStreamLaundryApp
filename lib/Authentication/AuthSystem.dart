abstract class AuthSystem{
  Future<bool> login(String email, String password);
  Future<bool> signUp(String email, String password);
  Future<void> logout();
  bool get isLoggedIn;
  String? get currentUserId;
}