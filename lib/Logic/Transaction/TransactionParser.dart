import 'package:intl/intl.dart';

class TransactionParser {
  static String formatTransaction(Map<String, dynamic> transaction) {
    final amount = (transaction['amount'] as num).toDouble();
    final description = transaction['description'] as String;
    final createdAt = DateTime.parse(transaction['created_at'] as String);
    final formattedDate = DateFormat('MMM dd, yyyy').format(createdAt);

    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    int currentMonth = new DateTime.now().month;

    if(DateFormat('M').format(createdAt) != currentMonth.toString() ){
      return "";
    }

    if(description == "Loyalty Card"){
      return '$formattedAmount added to $description on $formattedDate';
    }else{
      return '$formattedAmount used on $description on $formattedDate';
    }
  }

  static List<String> formatTransactionsList(Iterable<Map<String, dynamic>> data) {
    return data.map((transaction) => formatTransaction(transaction)).toList();
  }
}