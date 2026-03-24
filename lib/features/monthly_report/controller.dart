import 'package:clean_stream_laundry_app/logic/parsing/transaction_parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyReportController extends ChangeNotifier {
  final List<Map<String, dynamic>> transactions;

  int? _selectedYear;

  MonthlyReportController({required this.transactions});

  late final Map<String, Map<String, double>> monthlySums =
  TransactionParser.getMonthlySums(transactions);

  late final List<String> sortedMonths = monthlySums.keys.toList()
    ..sort((a, b) {
      final dateA = DateFormat('MMM yyyy').parse(a);
      final dateB = DateFormat('MMM yyyy').parse(b);
      return dateB.compareTo(dateA);
    });

  late final List<int> availableYears = () {
    final years = sortedMonths
        .map((month) => DateFormat('MMM yyyy').parse(month).year)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (years.isEmpty) years.add(DateTime.now().year);
    return years;
  }();

  int get selectedYear =>
      (_selectedYear != null && availableYears.contains(_selectedYear))
          ? _selectedYear!
          : availableYears.first;

  List<String> get filteredMonths => sortedMonths.where((month) {
    final date = DateFormat('MMM yyyy').parse(month);
    return date.year == selectedYear;
  }).toList();

  void selectYear(int year) {
    if (year == selectedYear) return;
    _selectedYear = year;
    notifyListeners();
  }
}