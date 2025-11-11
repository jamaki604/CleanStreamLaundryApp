import 'package:clean_stream_laundry_app/Logic/Payment/Stripe/payment_processor.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html show window;

class StripeService implements PaymentProcessor {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<int> makePayment(double amount) async {
    try {
      final response = await DatabaseService.instance.functionRunner.runEdgeFunction(
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
