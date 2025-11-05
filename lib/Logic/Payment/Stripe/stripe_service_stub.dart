import 'package:clean_stream_laundry_app/Logic/Payment/Stripe/payment_processor.dart';

class StripeService implements PaymentProcessor {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<int> makePayment(double amount) async {
    print("StripeService is not supported on this platform.");
    return 403;
  }
}
