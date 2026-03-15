import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clean_stream_laundry_app/logic/parsing/transaction_parser.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:go_router/go_router.dart';

class MonthlyTransactionHistory extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  const MonthlyTransactionHistory({super.key, required this.transactions});

  @override
  State<MonthlyTransactionHistory> createState() =>
      _MonthlyTransactionHistoryState();
}

class _MonthlyTransactionHistoryState extends State<MonthlyTransactionHistory> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardBackgroundColor = colorScheme.cardPrimary;
    final cardTextColor =
        ThemeData.estimateBrightnessForColor(cardBackgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;

    final monthlySums = TransactionParser.getMonthlySums(widget.transactions);
    final sortedMonths = monthlySums.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMM yyyy').parse(a);
        final dateB = DateFormat('MMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    final availableYears =
        sortedMonths
            .map((month) => DateFormat('MMM yyyy').parse(month).year)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (availableYears.isEmpty) {
      availableYears.add(DateTime.now().year);
    }

    final selectedYear =
        (_selectedYear != null && availableYears.contains(_selectedYear))
        ? _selectedYear!
        : availableYears.first;

    final filteredMonths = sortedMonths.where((month) {
      final date = DateFormat('MMM yyyy').parse(month);
      return date.year == selectedYear;
    }).toList();

    Future<void> showYearPickerSheet() async {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: cardBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Year: $selectedYear',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cardTextColor,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ...availableYears.map(
                    (year) => ListTile(
                      key: ValueKey('year-option-$year'),
                      title: Text(
                        year.toString(),
                        style: TextStyle(color: cardTextColor),
                      ),
                      trailing: year == selectedYear
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        if (year == selectedYear) return;
                        setState(() {
                          _selectedYear = year;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

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

      return Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(colorScheme.primary),
            trackColor: WidgetStateProperty.all(Colors.transparent),
            thickness: WidgetStateProperty.all(8),
            radius: const Radius.circular(4),
          ),
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          interactive: true,
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
                  color: cardBackgroundColor,
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
                                color: cardTextColor,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: cardTextColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildTransactionRow(
                          'Direct Washer Payments',
                          data['directWasher']!,
                          cardTextColor,
                        ),
                        const SizedBox(height: 8),
                        _buildTransactionRow(
                          'Loyalty Washer Payments',
                          data['loyaltyWasher']!,
                          colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        _buildTransactionRow(
                          'Direct Dryer Payments',
                          data['directDryer']!,
                          cardTextColor,
                        ),
                        const SizedBox(height: 8),
                        _buildTransactionRow(
                          'Loyalty Dryer Payments',
                          data['loyaltyDryer']!,
                          colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        _buildTransactionRow(
                          'Loyalty Card Loads',
                          data['loyaltyCard']!,
                          cardTextColor,
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.fontPrimary),
          onPressed: () => context.pop(),
        ),
        backgroundColor: colorScheme.primary,
        title: Text(
          'Monthly Transaction History',
          style: TextStyle(color: colorScheme.fontPrimary),
        ),
        elevation: 2,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              key: const ValueKey('year-filter-button'),
              onPressed: showYearPickerSheet,
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.fontPrimary),
              label: Text(
                'Year',
                style: TextStyle(
                  color: colorScheme.fontPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: buildMonthList(filteredMonths),
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
