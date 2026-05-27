import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import '../controller.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  final LoyaltyController controller;

  const TransactionList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.recentTransactions.isEmpty) {
      return Text(
        'No transactions found.',
        style: TextStyle(color: Theme.of(context).colorScheme.fontSecondary),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView(
        cacheExtent: 1000,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                onPressed: controller.toggleTransactionView,
                icon: Icon(
                  controller.showPastTransactions
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.blue,
                ),
                label: Text(
                  controller.showPastTransactions ? 'Show Less' : 'Show More',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ...controller.recentTransactions.map((transaction) {
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 6.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
          }),
        ],
      ),
    );
  }
}
