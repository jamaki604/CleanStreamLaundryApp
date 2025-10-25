class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<int> makePayment(double amount) async {
    print("StripeService is not supported on this platform.");
    return 403;
  }
}
