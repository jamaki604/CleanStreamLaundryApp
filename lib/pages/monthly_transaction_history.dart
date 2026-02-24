import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clean_stream_laundry_app/logic/parsing/transaction_parser.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:go_router/go_router.dart';

class MonthlyTransactionHistory extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  const MonthlyTransactionHistory({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final monthlySums = TransactionParser.getMonthlySums(transactions);
    final sortedMonths = monthlySums.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMM yyyy').parse(a);
        final dateB = DateFormat('MMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    final now = DateTime.now();
    final currentYear = now.year;
    final previousYear = currentYear - 1;
    final twelveMonthCutoff = DateTime(now.year, now.month - 11, 1);

    final previousYearMonths = sortedMonths.where((month) {
      final date = DateFormat('MMM yyyy').parse(month);
      return date.year == previousYear;
    }).toList();

    final currentYearMonths = sortedMonths.where((month) {
      final date = DateFormat('MMM yyyy').parse(month);
      return date.year == currentYear;
    }).toList();

    final lastTwelveMonths = sortedMonths.where((month) {
      final date = DateFormat('MMM yyyy').parse(month);
      return !date.isBefore(twelveMonthCutoff);
    }).toList();

    Widget buildMonthList(List<String> visibleMonths) {
      final ScrollController _scrollController = ScrollController();

      if (visibleMonths.isEmpty) {
        return const Center(
          child: Text(
            'No transactions found for this time range.',
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return Scaffold(
        body: Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(Colors.lightBlue),
              trackColor: WidgetStateProperty.all(Colors.transparent),
              thickness: WidgetStateProperty.all(8),
              radius: const Radius.circular(4),
            ),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: visibleMonths.length,
              itemBuilder: (context, index) {
                final month = visibleMonths[index];
                final data = monthlySums[month]!;
                final total =
                    data['directWasher']! +
                    data['directDryer']! +
                    data['loyaltyCard']!;
                if (total == 0 &&
                    data['loyaltyWasher'] == 0 &&
                    data['loyaltyDryer'] == 0) {
                  return const SizedBox(width: 0, height: 0);
                } else {
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildTransactionRow(
                            'Direct Washer Payments',
                            data['directWasher']!,
                            Colors.black,
                          ),
                          const SizedBox(height: 8),
                          _buildTransactionRow(
                            'Loyalty Washer Payments',
                            data['loyaltyWasher']!,
                            Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          _buildTransactionRow(
                            'Direct Dryer Payments',
                            data['directDryer']!,
                            Colors.black,
                          ),
                          const SizedBox(height: 8),
                          _buildTransactionRow(
                            'Loyalty Dryer Payments',
                            data['loyaltyDryer']!,
                            Theme.of(context).colorScheme.primary,
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
                }
              },
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.fontPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'Monthly Transaction History',
            style: TextStyle(color: Theme.of(context).colorScheme.fontPrimary),
          ),
          elevation: 2,
          centerTitle: true,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.fontPrimary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.fontPrimary.withOpacity(0.7),
            indicatorColor: Theme.of(context).colorScheme.fontPrimary,
            tabs: [
              Tab(text: 'Year $previousYear'),
              Tab(text: 'Year $currentYear'),
              const Tab(text: 'Last 12 Months'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildMonthList(previousYearMonths),
            buildMonthList(currentYearMonths),
            buildMonthList(lastTwelveMonths),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(String label, double amount, Color color) {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 16, color: color)),
        ),
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
