import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<int> makePayment() async {
    try{
      String? paymentIntentClientSecret = await _createPaymentIntent(10, "usd");
      if (paymentIntentClientSecret == null) {
        return 400;
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Clean Stream Laundry Solutions",
        ),
      );
      int paymentStatus = await _processPayment();
      return paymentStatus;
    } catch(e) {
      return 400;
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      await dotenv.load(fileName: '.env');
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency
      };

      var response = await dio.post(
          "https://api.stripe.com/v1/payment_intents",
          data: data,
          options: Options(
              contentType: Headers.formUrlEncodedContentType,
              headers: {
                "Authorization":"Bearer ${dotenv.env['STRIPE_SECRET_KEY']}",
                "Content-Type": 'application/x-www-form-urlencoded'
              }
          )
      );

      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<int> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return 200;
    } on StripeException catch(e) {
      return 401;
    } catch (e) {
      return 400;
    }
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}