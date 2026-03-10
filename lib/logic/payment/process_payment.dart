import 'package:clean_stream_laundry_app/logic/exceptions/payment_canceled_exception.dart';
import 'package:clean_stream_laundry_app/logic/exceptions/payment_failed_exception.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';

class PaymentProcessor {
  final PaymentService _paymentService;
  final TransactionService _transactionService;

  PaymentProcessor({
    required PaymentService paymentService,
    required TransactionService transactionService,
  }) : _paymentService = paymentService,
       _transactionService = transactionService;

  Future<PaymentResult> processPayment(
    double amount,
    String description,
  ) async {
    try {
      await _paymentService.makePayment(amount);
      _transactionService.recordTransaction(
        amount: amount,
        description: description,
        type: "Laundry",
      );
      return PaymentResult.success;
    } on PaymentCanceledException {
      return PaymentResult.canceled;
    } on PaymentFailedException {
      return PaymentResult.failed;
    } catch (_) {
      return PaymentResult.failed;
    }
  }
}
