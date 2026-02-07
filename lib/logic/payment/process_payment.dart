import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:get_it/get_it.dart';

class PaymentProcessor {
  final PaymentService _paymentService = GetIt.instance<PaymentService>();
  final TransactionService _transactionService = GetIt.instance<TransactionService>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final ProfileService _profileService = GetIt.instance<ProfileService>();


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

  void processRewards(double amount) async {
    final userId = _authService.getCurrentUserId;
    final data = await _profileService.getUserBalanceById(userId!);
    double rewardAmount = amount * 0.01;
    double? balance = data?['balance'].toDouble();
    _transactionService.recordTransaction(
      amount: rewardAmount,
      description: "Reward from payment",
      type: "Rewards",
    );
    _profileService.updateBalanceById(userId, balance! + rewardAmount);

  }
}
