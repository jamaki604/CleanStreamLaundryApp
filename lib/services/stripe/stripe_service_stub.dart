import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/exceptions/platform_exception.dart';

class StripeService implements PaymentService {
  @override
  Future<void> makePayment(double amount) async {
    print("StripeService is not supported on this platform.");
    throw PlatformException("StripeService is not supported on this platform.");
  }
}
