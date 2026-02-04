import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../Logic/Theme/theme.dart';
import 'package:clean_stream_laundry_app/widgets/credit_card.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';

class LoyaltyPage extends StatefulWidget {
  const LoyaltyPage({super.key});

  @override
  State<LoyaltyPage> createState() => LoyaltyCardPage();
}

class LoyaltyCardPage extends State<LoyaltyPage> {
  final viewModel = GetIt.instance<LoyaltyViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (_, __) {
        if (viewModel.isLoading) {
          const Center(child: CircularProgressIndicator());
        }
        if (viewModel.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog(context, viewModel.errorMessage);
          });
        }

        return BasePage(body: _buildContent(context));
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CreditCard(username: viewModel.userName ?? 'John Doe'),
          const SizedBox(height: 50),
          Text(
            'Current Balance: \$${viewModel.userBalance?.toStringAsFixed(2) ?? '0.00'}',
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
          _transactions(),
        ],
      ),
    );
  }

  Widget _transactions() {
    if (viewModel.recentTransactions.isEmpty) {
      return Text(
        "No transactions found.",
        style: TextStyle(color: Theme.of(context).colorScheme.fontSecondary),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  color: Theme.of(context).colorScheme.fontSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: viewModel.toggleTransactionView,
                icon: Icon(
                  viewModel.showPastTransactions
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.blue,
                ),
                label: Text(
                  viewModel.showPastTransactions ? 'Show Less' : 'Show More',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = viewModel.recentTransactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 6.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                color: Theme.of(context).colorScheme.cardPrimary,
                child: ListTile(
                  leading: const Icon(
                    Icons.receipt_long,
                    color: Color(0xFF2073A9),
                  ),
                  title: Text(
                    transaction.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              );
            },
          ),
        ],
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
    double selectedAmount = 1.0;

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
                    color: Colors.blue,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: selectedAmount > 1.0
                            ? () {
                                setDialogState(() {
                                  selectedAmount = (selectedAmount - 0.25)
                                      .clamp(1.0, 500.0);
                                });
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: selectedAmount > 1.0
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "-25¢",
                          style: TextStyle(
                            color: selectedAmount > 1.0
                                ? Colors.blue
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "\$${selectedAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.fontInverted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: selectedAmount < 500.0
                            ? () {
                                setDialogState(() {
                                  selectedAmount = (selectedAmount + 0.25)
                                      .clamp(1.0, 500.0);
                                });
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: selectedAmount < 500.0
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "+25¢",
                          style: TextStyle(
                            color: selectedAmount < 500.0
                                ? Colors.blue
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [10, 15, 25].map((amount) {
                      return ChoiceChip(
                        label: Text("\$$amount"),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.fontInverted,
                        ),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
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
                      inactiveTrackColor: Colors.blue.withAlpha(3),
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
                    child: SizedBox(
                      width: 650,
                      child: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: selectedAmount,
                              min: 1,
                              max: 500,
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedAmount = value.roundToDouble();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
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
    final result = await viewModel.loadCard(amount);

    if (!mounted) {
      return;
    }

    if (result == PaymentResult.success) {

      viewModel.fetchTransactions();

      statusDialog(
        context,
        title: "Payment Successful!",
        message:
            "Thank you! Your payment of \$${amount.toStringAsFixed(2)} was processed successfully.",
        isSuccess: true,
      );
    } else if (result == PaymentResult.canceled) {
      statusDialog(
        context,
        title: "Payment Canceled",
        message: "Payment of \$${amount.toStringAsFixed(2)} was canceled.",
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
