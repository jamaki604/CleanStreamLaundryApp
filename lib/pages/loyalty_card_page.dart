import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import '../Logic/Theme/theme.dart';
import 'package:clean_stream_laundry_app/logic/parsing/transaction_parser.dart';
import 'package:clean_stream_laundry_app/widgets/credit_card.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';

class LoyaltyPage extends StatefulWidget {
  const LoyaltyPage({super.key});

  @override
  State<LoyaltyPage> createState() => LoyaltyCardPage();
}

class LoyaltyCardPage extends State<LoyaltyPage> {
  double? _userBalance;
  bool _isLoading = true;
  String? _userName;
  String? _errorMessage;
  List<String> _recentTransactions = [];
  bool _showPastTransactions = false;

  final profileService = GetIt.instance<ProfileService>();
  final transactionService = GetIt.instance<TransactionService>();
  final authService = GetIt.instance<AuthService>();

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _fetchTransactions();
  }

  Future<void> _fetchBalance() async {
    final currentUserId = authService.getCurrentUserId;

    if (currentUserId == null) {
      setState(() {
        _errorMessage = 'User not known';
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, _errorMessage);
      });
      return;
    }

    try {
      final data = await profileService.getUserBalanceById(currentUserId);

      if (data != null) {
        setState(() {
          _userBalance = (data['balance'] as num).toDouble();
          _userName = (data['full_name']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _userBalance = 0;
          _userName = "John Doe";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch balance';
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, _errorMessage);
      });
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final transactions = await transactionService.getTransactionsForUser();
      final limit = _showPastTransactions ? 100 : 3;
      setState(() {
        _recentTransactions = TransactionParser.formatTransactionsList(
          transactions.take(limit),
          "transactionHistory",
        );
        _recentTransactions.removeWhere((e) => e.isEmpty);
      });
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void _toggleTransactionView() {
    setState(() {
      _showPastTransactions = !_showPastTransactions;
    });
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CreditCard(username: _userName),
                  const SizedBox(height: 50),
                  Text(
                    'Current Balance: \$${_userBalance?.toStringAsFixed(2) ?? '0.00'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.fontSecondary,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => _loadCard(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Load card",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.fontSecondary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _toggleTransactionView,
                              icon: Icon(
                                _showPastTransactions
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.blue,
                              ),
                              label: Text(
                                _showPastTransactions
                                    ? 'Show Less'
                                    : 'Show More',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_recentTransactions.isEmpty)
                          Text(
                            'No recent transactions',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          )
                        else
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _recentTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _recentTransactions[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 6.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 4,
                                color: Theme.of(
                                  context,
                                ).colorScheme.cardPrimary,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.receipt_long,
                                    color: Color(0xFF2073A9),
                                  ),
                                  title: Text(
                                    transaction.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  void _showErrorDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Error'),
          content: Text(message ?? ''),
          icon: Icon(Icons.error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (message == "Failed to fetch balance") {
                  context.go("/scanner");
                } else {
                  context.go("/login");
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _loadCard() {
    double selectedAmount = 10.0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Center(
                child: Text(
                  "Load Loyalty Card",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "\$${selectedAmount.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.fontInverted,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [25, 50, 75].map((amount) {
                      return ChoiceChip(
                        label: Text("\$$amount"),
                        selected: selectedAmount == amount.toDouble(),
                        onSelected: (_) {
                          setDialogState(() {
                            selectedAmount = amount.toDouble();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.blue.withOpacity(0.3),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,
                      ),
                      tickMarkShape: const RoundSliderTickMarkShape(
                        tickMarkRadius: 0,
                      ),
                    ),
                    child: Slider(
                      value: selectedAmount,
                      min: 10,
                      max: 100,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedAmount = (value / 5).round() * 5.0;
                        });
                      },
                    ),
                  ),
                  Text(
                    "Select an amount to add to your card.",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.fontInverted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    _handlePayment(selectedAmount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Pay",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handlePayment(double amount) async {
    final result = await processPayment(amount, "Loyalty Card");

    if (!mounted) {
      return;
    }

    if (result == PaymentResult.success) {
      final newBalance = _userBalance! + amount;
      await profileService.updateBalanceById(newBalance);

      setState(() {
        _userBalance = newBalance;
      });

      _fetchTransactions();

      statusDialog(
        context,
        title: "Payment Successful!",
        message: "Thank you! Your payment was processed successfully.",
        isSuccess: true,
      );
    } else if (result == PaymentResult.canceled) {
      statusDialog(
        context,
        title: "Payment Canceled",
        message: "Payment was canceled.",
        isSuccess: false,
      );
    } else {
      statusDialog(
        context,
        title: "Payment Failed",
        message:
            "An error occurred while processing your payment. Please try again.",
        isSuccess: false,
      );
    }
  }
}
