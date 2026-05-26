import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/services/wallet_service.dart';
import 'package:clean_stream_laundry_app/logic/parsing/transaction_parser.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';

class LoyaltyController extends ChangeNotifier {
  final _authService = GetIt.instance<AuthService>();
  final _profileService = GetIt.instance<ProfileService>();
  final _transactionService = GetIt.instance<TransactionService>();
  final _paymentProcessor = GetIt.instance<PaymentProcessor>();
  final _walletService = GetIt.instance<WalletService>();

  double? userBalance;
  double? paidBalance;
  double? promoBalance;
  double? userReward;
  String? userName;
  String? errorMessage;
  bool isLoading = true;
  bool showPastTransactions = false;

  List<String> recentTransactions = [];

  Future<void> initialize() async {
    await Future.wait([_fetchBalance(), _fetchTransactions()]);
  }

  Future<void> _fetchBalance() async {
    final userId = _authService.getCurrentUserId;

    if (userId == null) {
      errorMessage = 'User not known';
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final profile = await _profileService.getUserBalanceById(userId);
      final balance = await _walletService.getBalance();

      userBalance = balance.totalBalance;
      paidBalance = balance.paidBalance;
      promoBalance = balance.promoBalance;
      userName = profile?['full_name'] ?? 'John Doe';
      userReward = (profile?["reward_tracker"] as num?)?.toDouble() ?? 0.0;
    } catch (_) {
      errorMessage = 'Failed to fetch balance';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchTransactions() async {
    final transactions = await _transactionService.getTransactionsForUser();
    final limit = showPastTransactions ? 100 : 3;

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final filtered = transactions.where((transaction) {
      final createdAt = DateTime.parse(transaction['created_at'] as String);
      final type = transaction['type'] as String?;
      return createdAt.isAfter(thirtyDaysAgo) && type != "Rewards";
    });

    recentTransactions = TransactionParser.formatTransactionsList(
      filtered.take(limit),
      "transactionHistory",
    )..removeWhere((e) => e.isEmpty);

    notifyListeners();
  }

  Future<void> toggleTransactionView() async {
    showPastTransactions = !showPastTransactions;
    notifyListeners();
    await _fetchTransactions();
  }

  Future<PaymentResult> loadCard(double amount) async {
    final result = await _paymentProcessor.processPayment(
      amount,
      "Loyalty Card",
    );

    if (result == PaymentResult.success) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      await _fetchBalance();
      await _fetchTransactions();
    }

    notifyListeners();
    return result;
  }

  Future<void> fetchTransactions() async {
    await _transactionService.getTransactionsForUser();
  }

  @Deprecated('Rewards are now calculated by the server wallet ledger.')
  double checkRewards(double amount) {
    double combined = (userReward ?? 0) + amount;
    double remainder = combined % 20;
    int rewardsEarned = combined ~/ 20;

    userReward = remainder;

    return amount + (rewardsEarned * 5);
  }
}
