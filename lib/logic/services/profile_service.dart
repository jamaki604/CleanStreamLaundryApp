abstract class ProfileService {
  Future<void> createAccount({required String id, required String name});
  Future<Map<String, dynamic>?> getUserBalanceById(String userId);
  Future<void> updateBalanceById(double balance);
  Future<String?> getUserNameById(String userId);
  Future<String?> getUserRefundAttempts(String userId);
}