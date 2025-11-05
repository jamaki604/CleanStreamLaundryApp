import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/Stripe/stripe_service.dart';
import 'package:clean_stream_laundry_app/Middleware/database_service.dart';
import 'package:clean_stream_laundry_app/Components/PaymentResult.dart';


Future<bool> processPayment(BuildContext context, double amount, description) async {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator())
  );

  final int status = await StripeService.instance.makePayment(amount);

  Navigator.of(context).pop();

  if(status == 200) {
    if (description != "Machine") {
      showPaymentResult(context,
          title: "Payment Successful!",
          message: "Thank you! Your payment was processed successfully.",
          isSuccess: true
      );
    }
    DatabaseService.instance.recordTransaction(amount: amount, description: description, type: "Laundry");
    return true;
  } else if (status == 401) {
    showPaymentResult(context,
        title: "Payment Failed!",
        message: "The payment was canceled or declined.",
        isSuccess: false
    );
    return false;
  }else if (status == 403) {
    showPaymentResult(context,
        title: "Payment Failed!",
        message: "Stripe service is not available on this platform.",
        isSuccess: false
    );
    return false;
  }  else {
    showPaymentResult(context,
        title: "Payment Failed!",
        message: "An unexpected error occurred.",
        isSuccess: false
    );
    return false;
  }
}

