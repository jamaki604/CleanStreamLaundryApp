import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'dart:html' as html show window;
import 'package:get_it/get_it.dart';

class StripeService implements PaymentService {
  StripeService();
  final edgeFuntionService = GetIt.instance<EdgeFunctionService>();

  Future<int> makePayment(double amount) async {
    try {
      final response = await edgeFuntionService.runEdgeFunction(
          name:'createCheckoutSession',
          body: {'amount': (amount * 100).toInt()}
      );

      if (response?.data != null && response?.data['url'] != null) {
        html.window.location.href = response?.data['url'];
        return 200;
      } else {
        return 400;
      }
    } catch (e) {
      return 400;
    }
  }
}
