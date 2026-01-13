import 'package:clean_stream_laundry_app/logic/exceptions/null_url_exception.dart';
import 'package:clean_stream_laundry_app/logic/exceptions/platform_exception.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';

Future<bool> processPayment(
  BuildContext context,
  double amount,
  description,
) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) =>
        const Center(child: CircularProgressIndicator()),
  );

  final paymentService = GetIt.instance<PaymentService>();
  final transactionService = GetIt.instance<TransactionService>();

  try {
    await paymentService.makePayment(amount);
    Navigator.of(context, rootNavigator: true).pop();
    if (description != "Machine") {
      statusDialog(
        context,
        title: "Payment Successful!",
        message: "Thank you! Your payment was processed successfully.",
        isSuccess: true,
      );
    }
    transactionService.recordTransaction(
      amount: amount,
      description: description,
      type: "Laundry",
    );
    return true;
  } on NullUrlException {
    Navigator.of(context, rootNavigator: true).pop();
    statusDialog(
      context,
      title: "Payment Failed!",
      message: "Internal error occured.",
      isSuccess: false,
    );
    return false;
  } on StripeConfigException {
    Navigator.of(context, rootNavigator: true).pop();
    statusDialog(
      context,
      title: "Payment Failed!",
      message: "Internal error occured.",
      isSuccess: false,
    );
    return false;
  } on PlatformException {
    Navigator.of(context, rootNavigator: true).pop();
    statusDialog(
      context,
      title: "Payment Failed!",
      message: "Platform is not supported for payments.",
      isSuccess: false,
    );
    return false;
  } on StripeException {
    Navigator.of(context, rootNavigator: true).pop();
    statusDialog(
      context,
      title: "Payment Failed!",
      message: "The payment was canceled or declined.",
      isSuccess: false,
    );
    return false;
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();
    statusDialog(
      context,
      title: "Payment Failed!",
      message: "An unexpected error occurred.",
      isSuccess: false,
    );
    return false;
  }
}
