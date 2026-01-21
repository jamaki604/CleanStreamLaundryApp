import 'package:intl/intl.dart';

class TransactionParser {
  static String formatTransaction(
    Map<String, dynamic> transaction,
    String type,
  ) {
    final amount = (transaction['amount'] as num).toDouble();
    final description = transaction['description'] as String;
    final createdAt = DateTime.parse(transaction['created_at'] as String);
    final formattedDate = DateFormat('MMM dd, yyyy').format(createdAt);
    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    final twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    if (createdAt.isBefore(thirtyDaysAgo) && type == "transactionHistory") {
      return "";
    }
    if (createdAt.isBefore(twoWeeksAgo) && type == "refundHistory") {
      return "";
    }

    final action = description == "Loyalty Card" ? "added to" : "used on";
    return '$formattedAmount $action $description on $formattedDate';
  }

  static List<String> formatTransactionsList(
    Iterable<Map<String, dynamic>> data,
    String type,
  ) {
    return data
        .map((transaction) => formatTransaction(transaction, type))
        .toList();
  }

  static List<int> createTransactionIDList(
    Iterable<Map<String, dynamic>> data,
  ) {
    return data.map((transaction) => getTransactionIDs(transaction)).toList();
  }

  static int getTransactionIDs(Map<String, dynamic> transaction) {
    final id = (transaction['id'] as num).toInt();
    final createdAt = DateTime.parse(transaction['created_at'] as String);
    final twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));

    if (createdAt.isBefore(twoWeeksAgo)) {
      return -1;
    } else {
      return id;
    }
  }

  static Map<String, Map<String, double>> getMonthlySums(
    List<Map<String, dynamic>> transactions,
  ) {
    final now = DateTime.now();
    final result = <String, Map<String, double>>{};
    int currentMonth = DateTime.now().month;
    final cutoffDate = DateTime(now.year - 1, now.month, 1);

    for (int i = 1; i <= 12; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MMM yyyy').format(monthDate);
      result[monthKey] = {
        'directWasher': 0.0,
        'loyaltyWasher': 0.0,
        'directDryer': 0.0,
        'loyaltyDryer': 0.0,
        'loyaltyCard': 0.0,
      };
    }

    for (final transaction in transactions) {
      final createdAt = DateTime.parse(transaction['created_at'] as String);

      if (createdAt.isBefore(cutoffDate)) {
        break;
      }
      if (DateFormat('M').format(createdAt) == currentMonth.toString()) {
        continue;
      }

      final amount = (transaction['amount'] as num).toDouble();
      final description = (transaction['description'] as String).toLowerCase();
      final monthKey = DateFormat('MMM yyyy').format(createdAt);

      if (description.contains('loyalty payment on washer')) {
        result[monthKey]!['loyaltyWasher'] =
            result[monthKey]!['loyaltyWasher']! + amount;
      } else if (description.contains('loyalty payment on dryer')) {
        result[monthKey]!['loyaltyDryer'] =
            result[monthKey]!['loyaltyDryer']! + amount;
      } else if (description.contains('washer')) {
        result[monthKey]!['directWasher'] =
            result[monthKey]!['directWasher']! + amount;
      } else if (description.contains('dryer')) {
        result[monthKey]!['directDryer'] =
            result[monthKey]!['directDryer']! + amount;
      } else if (description == 'loyalty card') {
        result[monthKey]!['loyaltyCard'] =
            result[monthKey]!['loyaltyCard']! + amount;
      }
    }
    return result;
  }
}
