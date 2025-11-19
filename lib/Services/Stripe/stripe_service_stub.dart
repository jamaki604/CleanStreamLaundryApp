import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService implements PaymentService {
  late final _stripeInstance;

  StripeService({required Stripe instance}){
    _stripeInstance = instance;
  }

  Future<int> makePayment(double amount) async {
    print("StripeService is not supported on this platform.");
    return 403;
  }
}
