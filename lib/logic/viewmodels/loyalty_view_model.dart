import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/transaction_service.dart';
import '../parsing/transaction_parser.dart';
import '../enums/payment_result_enum.dart';
import '../payment/process_payment.dart';


class LoyaltyViewModel extends ChangeNotifier {
  final _authService = GetIt.instance<AuthService>();
  final _profileService = GetIt.instance<ProfileService>();
  final _transactionService = GetIt.instance<TransactionService>();
  final _paymentProcessor = GetIt.instance<PaymentProcessor>();

  double? userBalance;
  String? userName;
  String? errorMessage;
  double? monthlyRewards;
  bool isLoading = true;
  bool showPastTransactions = false;

  List<String> recentTransactions = [];

  // Call once from loyalty page
  Future<void> initialize() async {
    await Future.wait([_fetchBalance(), _fetchTransactions(), _fetchMonthlyRewards()]);
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
      final data = await _profileService.getUserBalanceById(userId);

      userBalance = (data?['balance'] as num?)?.toDouble() ?? 0.0;
      userName = data?['full_name'] ?? 'John Doe';
    } catch (_) {
      errorMessage = 'Failed to fetch balance';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchMonthlyRewards() async {
    final transactions = await _transactionService.getTransactionsForUser();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final rewardTransactions = transactions.where((t) {
      final createdAt = DateTime.parse(t['created_at'] as String);
      final type = t['type'] as String?;
      return createdAt.isAfter(thirtyDaysAgo) && type == 'Rewards';
    });

    monthlyRewards = rewardTransactions.fold<double>(
      0.0, (sum, transaction) => sum + (transaction['amount'] as num).toDouble(),
    );
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
    final userId = _authService.getCurrentUserId;
    final result = await _paymentProcessor.processPayment(
      amount,
      "Loyalty Card",
    );

    if (result == PaymentResult.success) {
      final newBalance = (userBalance ?? 0) + amount + _paymentProcessor.processRewards(amount);
      await _profileService.updateBalanceById(userId!, newBalance);
      userBalance = newBalance;
      await _fetchTransactions();
    }

    notifyListeners();
    return result;
  }

  Future<void> fetchTransactions() async {
    await _transactionService.getTransactionsForUser();
  }
}
