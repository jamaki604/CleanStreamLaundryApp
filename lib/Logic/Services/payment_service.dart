abstract class PaymentService{
  Future<int> makePayment(double amount);
  Future<String> getTransactionResult(String sessionId);
}