import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'controller.dart';
import 'widgets/load_card_dialog.dart';
import 'widgets/header.dart';
import 'widgets/transaction_list.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoyaltyPage extends StatefulWidget {
  final LoyaltyController? controller;
  const LoyaltyPage({super.key, this.controller});

  @override
  State<LoyaltyPage> createState() => _LoyaltyPageState();
}

class _LoyaltyPageState extends State<LoyaltyPage> {
  late LoyaltyController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??LoyaltyController();
    controller.addListener(_rebuild);
    controller.initialize();
  }

  @override
  void dispose() {
    controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _showRewardInfoDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rewards program'),
        content: const Text(
          'For every \$20 you spend, you get an extra \$5 automatically added to your loyalty balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String? message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error'),
        content: Text(message ?? ''),
        icon: const Icon(Icons.error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (message == 'Failed to fetch balance') {
                context.go('/scanner');
              } else {
                context.go('/login');
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLoadCardDialog() {
    showDialog(
      context: context,
      builder: (_) => LoadCardDialog(onPay: _handlePayment),
    );
  }

  Future<void> _handlePayment(double amount) async {
    final result = await controller.loadCard(amount);
    if (!mounted) return;

    if (result == PaymentResult.success) {
      controller.fetchTransactions();
      statusDialog(
        context,
        title: 'Payment Successful!',
        message:
        'Thank you! Your payment of \$${amount.toStringAsFixed(2)} was processed successfully.',
        isSuccess: true,
      );
    } else if (result == PaymentResult.canceled) {
      statusDialog(
        context,
        title: 'Payment Canceled',
        message: 'Payment of \$${amount.toStringAsFixed(2)} was canceled.',
        isSuccess: false,
      );
    } else {
      statusDialog(
        context,
        title: 'Payment Failed',
        message:
        'An error occurred while processing your payment. Please try again.',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(controller.errorMessage);
      });
    }

    return BasePage(
      body: Column(
        children: [
          const SizedBox(height: 10),
          Header(
            controller: controller,
            onInfoTap: _showRewardInfoDialog,
          ),
          const SizedBox(height: 7),
          ElevatedButton(
            onPressed: _showLoadCardDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Load card',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: TransactionList(controller: controller),
          ),
        ],
      ),
    );
  }
}