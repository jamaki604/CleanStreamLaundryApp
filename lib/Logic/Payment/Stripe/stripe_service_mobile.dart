import 'package:clean_stream_laundry_app/Logic/Payment/Stripe/payment_processor.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';

class StripeService implements PaymentProcessor{
  StripeService._();
  static final StripeService instance = StripeService._();
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();

  Future<int> makePayment(double amount) async {
    try{
        String? paymentIntentClientSecret = await _createPaymentIntent(amount, "usd");
        if (paymentIntentClientSecret == null) {
          return 400;
        }
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentClientSecret,
            merchantDisplayName: "Clean Stream Laundry Solutions",
          ),
        );
        await Stripe.instance.presentPaymentSheet();
        return 200;
    } on StripeException {
      return 401;
    } catch (e) {
      print("Payment error: $e");
      return 400;
    }
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      final response = await edgeFunctionService.runEdgeFunction(
          name: 'paymentIntent',
          body: {
            'amount': _calculateAmount(amount),
            'currency': currency
          }
      );


      if (response?.data != null && response?.data['clientSecret'] != null) {
        return response?.data["clientSecret"];
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }


  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt();
    return calculatedAmount.toString();
  }
}