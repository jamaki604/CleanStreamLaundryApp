import 'package:intl/intl.dart';

class TransactionParser {
  static String formatTransaction(Map<String, dynamic> transaction) {
    final amount = (transaction['amount'] as num).toDouble();
    final description = transaction['description'] as String;
    final createdAt = DateTime.parse(transaction['created_at'] as String);
    final formattedDate = DateFormat('MMM dd, yyyy').format(createdAt);

    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    int currentMonth = DateTime.now().month;

    if (DateFormat('M').format(createdAt) != currentMonth.toString()) {
      return "";
    }

    if (description == "Loyalty Card") {
      return '$formattedAmount added to $description on $formattedDate';
    } else {
      return '$formattedAmount used on $description on $formattedDate';
    }
  }

  static List<String> formatTransactionsList(
    Iterable<Map<String, dynamic>> data,
  ) {
    return data.map((transaction) => formatTransaction(transaction)).toList();
  }

  static Map<String, Map<String, double>> getMonthlySums(
    List<Map<String, dynamic>> transactions,
  ) {
    final now = DateTime.now();
    final result = <String, Map<String, double>>{};
    int currentMonth = DateTime.now().month;
    final cutoffDate = DateTime(now.year-1, now.month, 1);

    for (int i = 1; i <= 12; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MMM yyyy').format(monthDate);
      result[monthKey] = {'washer': 0.0, 'dryer': 0.0, 'loyaltyCard': 0.0};
    }


    for (final transaction in transactions) {
      final createdAt = DateTime.parse(transaction['created_at'] as String);

      if (createdAt.isBefore(cutoffDate)) {
        break;
      }
      if (DateFormat('M').format(createdAt) == currentMonth.toString()){
        continue;
      }

      final amount = (transaction['amount'] as num).toDouble();
      final description = (transaction['description'] as String).toLowerCase();
      final monthKey = DateFormat('MMM yyyy').format(createdAt);

      if (description.contains('washer')) {
        result[monthKey]!['washer'] = result[monthKey]!['washer']! + amount;
      } else if (description.contains('dryer')) {
        result[monthKey]!['dryer'] = result[monthKey]!['dryer']! + amount;
      } else if (description == 'loyalty card') {
        result[monthKey]!['loyaltyCard'] = result[monthKey]!['loyaltyCard']! + amount;
      }
    }
    return result;
  }
}
