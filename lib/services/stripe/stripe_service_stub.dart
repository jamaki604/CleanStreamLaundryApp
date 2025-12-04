import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';

class StripeService implements PaymentService {

  Future<int> makePayment(double amount) async {
    print("StripeService is not supported on this platform.");
    return 403;
  }
}
