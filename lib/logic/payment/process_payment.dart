import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:get_it/get_it.dart';

class PaymentProcessor {
  final PaymentService _paymentService = GetIt.instance<PaymentService>();
  final TransactionService _transactionService = GetIt.instance<TransactionService>();


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
      processRewards(amount);
      return PaymentResult.success;
    } on StripeException {
      return PaymentResult.canceled;
    } catch (_) {
      return PaymentResult.failed;
    }
  }

  void processRewards(double amount) {
    double rewardAmount = amount * 0.01;
    _transactionService.recordTransaction(
      amount: rewardAmount,
      description: "Reward from payment",
      type: "Rewards",
    );
  }
}
