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

      final userId = _authService.getCurrentUserId;
      final data = await _profileService.getUserBalanceById(userId!);
      final rewards = processRewards(amount);
      _profileService.updateBalanceById(userId, data?['balance'].toDouble() + rewards);
      _transactionService.recordTransaction(
        amount: rewards,
        description: "Reward from payment",
        type: "Rewards",
      );

      return PaymentResult.success;
    } on StripeException {
      return PaymentResult.canceled;
    } catch (_) {
      return PaymentResult.failed;
    }
  }

  double processRewards(double amount) {
    double rewardAmount = amount * 0.01;
    return (rewardAmount);
  }
}
