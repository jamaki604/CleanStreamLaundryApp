import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/wallet_service.dart';
import 'package:clean_stream_laundry_app/logic/models/wallet_ledger_entry.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:intl/intl.dart';

class LoyaltyController extends ChangeNotifier {
  final _authService = GetIt.instance<AuthService>();
  final _profileService = GetIt.instance<ProfileService>();
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
  List<String> rewardTransactions = [];

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
    try {
      final ledger = await _walletService.getLedger();
      final limit = showPastTransactions ? 100 : 3;
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentLedger = ledger
          .where((entry) => entry.createdAt.isAfter(thirtyDaysAgo))
          .toList();

      rewardTransactions = recentLedger
          .where(_isRewardLedgerEntry)
          .map(_formatWalletLedgerEntry)
          .toList();

      recentTransactions = recentLedger
          .take(limit)
          .map(_formatWalletLedgerEntry)
          .toList();
    } catch (_) {
      recentTransactions = [];
      rewardTransactions = [];
    }

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

    if (result == PaymentResult.success || result == PaymentResult.pending) {
      await _refreshWalletAfterPayment();
    }

    notifyListeners();
    return result;
  }

  Future<void> _refreshWalletAfterPayment() async {
    for (var attempt = 0; attempt < 3; attempt += 1) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
      }
      await _fetchBalance();
      await _fetchTransactions();
    }
  }

  Future<void> fetchTransactions() async {
    await _fetchTransactions();
  }

  String _formatWalletLedgerEntry(WalletLedgerEntry entry) {
    final amount = entry.amountCents.abs() / 100.0;
    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    final formattedDate = DateFormat(
      'MMM dd, yyyy',
    ).format(entry.createdAt.toLocal());

    return '$formattedAmount ${_ledgerAction(entry)} on $formattedDate';
  }

  String _ledgerAction(WalletLedgerEntry entry) {
    switch (entry.entryType) {
      case 'load_paid':
        return 'added to Loyalty Card';
      case 'load_bonus':
        return 'added as promotional credit';
      case 'redeem_paid':
      case 'redeem_promo':
        return entry.machineId == null
            ? 'used for machine payment'
            : 'used for machine #${entry.machineId}';
      default:
        if (entry.amountCents < 0) {
          return 'deducted from Loyalty Card';
        }
        return 'posted to Loyalty Card';
    }
  }

  bool _isRewardLedgerEntry(WalletLedgerEntry entry) {
    return entry.entryType == 'load_bonus' ||
        (entry.amountCents > 0 && entry.promoAmountCents > 0);
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
