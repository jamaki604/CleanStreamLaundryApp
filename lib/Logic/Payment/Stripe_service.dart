import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

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
      final response = await Supabase.instance.client.functions.invoke(
        'paymentIntent',
        body: {
          'amount': _calculateAmount(amount),
          'currency': currency
        },
      );

      if (response.data != null && response.data['clientSecret'] != null) {
        return response.data["clientSecret"];
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