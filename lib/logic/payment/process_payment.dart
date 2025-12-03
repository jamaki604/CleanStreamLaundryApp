import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:get_it/get_it.dart';


Future<bool> processPayment(BuildContext context, double amount, description) async {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(child: CircularProgressIndicator())
  );

  final paymentService = GetIt.instance<PaymentService>();
  final transactionService = GetIt.instance<TransactionService>();

  final int status = await paymentService.makePayment(amount);

  Navigator.of(context, rootNavigator: true).pop();

  if(status == 200) {
    if (description != "Machine") {
      statusDialog(context,
          title: "payment Successful!",
          message: "Thank you! Your payment was processed successfully.",
          isSuccess: true
      );
    }
    transactionService.recordTransaction(amount: amount, description: description, type: "Laundry");
    return true;
  } else if (status == 401) {
    statusDialog(context,
        title: "payment Failed!",
        message: "The payment was canceled or declined.",
        isSuccess: false
    );
    return false;
  }else if (status == 403) {
    statusDialog(context,
        title: "payment Failed!",
        message: "stripe service is not available on this platform.",
        isSuccess: false
    );
    return false;
  }  else {
    statusDialog(context,
        title: "payment Failed!",
        message: "An unexpected error occurred.",
        isSuccess: false
    );
    return false;
  }
}

