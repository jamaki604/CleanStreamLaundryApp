import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';

class StripeService implements PaymentService {
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();

  final _stripeInstance = GetIt.instance<Stripe>();

  @override
  Future<void> makePayment(double amount) async {
    try {
      String? paymentIntentClientSecret = await createPaymentIntent(
        amount,
        "usd",
      );
      if (paymentIntentClientSecret == null) {
        throw StripeConfigException("Failed to create payment intent");
      }
      await _stripeInstance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Clean Stream Laundry Solutions",
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF2073A9),
              background: CupertinoColors.systemBackground,
            ),
            shapes: const PaymentSheetShape(borderRadius: 12),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF2073A9),
                  text: CupertinoColors.white,
                ),
              ),
              shapes: const PaymentSheetPrimaryButtonShape(blurRadius: 12),
            ),
          ),
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'US'),
        ),
      );
      await _stripeInstance.presentPaymentSheet();
    } on StripeException {
      rethrow;
    } catch (e) {
      print("payment error: $e");
      rethrow;
    }
  }

  @protected
  Future<String?> createPaymentIntent(double amount, String currency) async {
    try {
      final response = await edgeFunctionService.runEdgeFunction(
        name: 'paymentIntent',
        body: {'amount': convertDollarsToCents(amount), 'currency': currency},
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

  @protected
  String convertDollarsToCents(double amount) {
    final calculatedAmount = (amount * 100).toInt();
    return calculatedAmount.toString();
  }
}
