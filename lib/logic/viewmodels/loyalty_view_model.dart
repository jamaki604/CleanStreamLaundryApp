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
  bool isLoading = true;
  bool showPastTransactions = false;

  List<String> recentTransactions = [];

  // Call once from loyalty page
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
      final data = await _profileService.getUserBalanceById(userId);

      userBalance = (data?['balance'] as num?)?.toDouble() ?? 0.0;
      userName = data?['full_name'] ?? 'John Doe';
    } catch (_) {
      errorMessage = 'Failed to fetch balance';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchTransactions() async {
    final transactions = await _transactionService.getTransactionsForUser();
    final limit = showPastTransactions ? 100 : 3;

    recentTransactions = TransactionParser.formatTransactionsList(
      transactions.take(limit),
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
      final newBalance = (userBalance ?? 0) + amount;
      await _profileService.updateBalanceById(newBalance);
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
