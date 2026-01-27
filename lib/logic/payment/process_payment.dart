import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';

Future<PaymentResult> processPayment(double amount, description) async {
  final paymentService = GetIt.instance<PaymentService>();
  final transactionService = GetIt.instance<TransactionService>();

  try {
    await paymentService.makePayment(amount);
    transactionService.recordTransaction(
      amount: amount,
      description: description,
      type: "Laundry",
    );
    return PaymentResult.success;
  } on StripeException {
    return PaymentResult.canceled;
  } catch (_) {
    return PaymentResult.failed;
  }
}
