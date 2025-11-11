abstract class ProfileService {
  Future<void> createAccount({required String name});
  Future<Map<String, dynamic>?> getUserBalanceById(String userId);
  Future<void> updateBalanceById(double balance);
}