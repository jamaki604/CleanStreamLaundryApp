import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';

class StripeService implements PaymentService {
  StripeService();

  Future<int> makePayment(double amount) async {
    print("StripeService is not supported on this platform.");
    return 403;
  }
}
