import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clean_stream_laundry_app/Components/base_page.dart';
import 'package:clean_stream_laundry_app/Logic/Transaction/transaction_parser.dart';
import 'package:clean_stream_laundry_app/Logic/Theme/theme.dart';

class MonthlyTransactionHistory extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const MonthlyTransactionHistory({Key? key, required this.transactions})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthlySums = TransactionParser.getMonthlySums(transactions);

    final sortedMonths = monthlySums.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMM yyyy').parse(a);
        final dateB = DateFormat('MMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });
    return BasePage(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            'Monthly Transaction History',
            style: TextStyle(color: Theme.of(context).colorScheme.fontSecondary),
          ),
          elevation: 2,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedMonths.length,
          itemBuilder: (context, index) {
            final month = sortedMonths[index];
            final data = monthlySums[month]!;
            final total =
                data['washer']! + data['dryer']!;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              color: Theme.of(context).colorScheme.cardPrimary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          month,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildTransactionRow(
                      'Washer Payments',
                      data['washer']!,
                      Colors.black,
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionRow(
                      'Dryer Payments',
                      data['dryer']!,
                      Colors.black,
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionRow(
                      'Loyalty Card Loads',
                      data['loyaltyCard']!,
                      Colors.black,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionRow(String label, double amount, Color color) {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
