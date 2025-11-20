import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:html' as html show window;
import 'package:get_it/get_it.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService implements PaymentService {
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();
  late final _stripeInstance;

  StripeService({required Stripe instance}){
    _stripeInstance = instance;
  }

  Future<int> makePayment(double amount) async {
    try {
      final response = await edgeFunctionService.runEdgeFunction(
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

  @override
  Future<String> getTransactionResult(String sessionId) async {
    final session = await edgeFunctionService.runEdgeFunction(
        name: "checkPaymentResult", body: {"session_id":sessionId}
    );

    return session?.data["status"];
  }
}
