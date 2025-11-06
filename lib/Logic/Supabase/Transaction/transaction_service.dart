abstract class TransactionService {
  Future<void> recordTransaction({required double amount, required String description, required String type,});
  Future<List<Map<String, dynamic>>> getTransactionsForUser();
}