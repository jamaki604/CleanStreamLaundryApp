abstract class AdminWalletService {
  Future<List<Map<String, dynamic>>> searchWallets(String query);
  Future<Map<String, dynamic>> getWalletDetail(String walletAccountId);
  Future<void> adjustWallet({
    required String walletAccountId,
    required int amountCents,
    required int paidAmountCents,
    required int promoAmountCents,
    required String note,
  });
  Future<void> lockWallet(String walletAccountId, bool locked);
  Future<void> recordCashRedemptionOrStripeRefund({
    required String walletAccountId,
    required int amountCents,
    required String note,
  });
  Future<void> recordDeletedAccountComplaint({
    required String walletAccountId,
    required String note,
    String resolution,
  });
}
