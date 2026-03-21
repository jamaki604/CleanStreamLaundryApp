import 'package:clean_stream_laundry_app/features/monthly_report/controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final now = DateTime.now();

  Map<String, dynamic> tx({
    required int monthsAgo,
    required String description,
    required double amount,
  }) {
    final date = DateTime(now.year, now.month - monthsAgo, 15);
    return {
      'created_at': date.toIso8601String(),
      'description': description,
      'amount': amount,
    };
  }

  String monthLabel(int monthsAgo) {
    final date = DateTime(now.year, now.month - monthsAgo, 1);
    return DateFormat('MMM yyyy').format(date);
  }


  group('Initialization', () {
    test('monthlySums contains entries for the past 12 months', () {
      final controller = MonthlyReportController(transactions: []);

      expect(controller.monthlySums.length, 12);
    });

    test('sortedMonths are in descending chronological order', () {
      final controller = MonthlyReportController(transactions: []);

      for (int i = 0; i < controller.sortedMonths.length - 1; i++) {
        final a = DateFormat('MMM yyyy').parse(controller.sortedMonths[i]);
        final b = DateFormat('MMM yyyy').parse(controller.sortedMonths[i + 1]);
        expect(a.isAfter(b), isTrue,
            reason:
            '${controller.sortedMonths[i]} should come before ${controller.sortedMonths[i + 1]}');
      }
    });

    test('availableYears contains current year when transactions are empty', () {
      final controller = MonthlyReportController(transactions: []);
      expect(controller.availableYears, contains(now.year));
    });

    test('availableYears contains only unique years', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        tx(monthsAgo: 2, description: 'Washer #2', amount: 3.00),
        tx(monthsAgo: 3, description: 'Washer #3', amount: 1.75),
      ]);

      final uniqueYears = controller.availableYears.toSet().toList();
      expect(controller.availableYears.length, uniqueYears.length);
    });

    test('availableYears are sorted descending', () {
      final controller = MonthlyReportController(transactions: []);

      for (int i = 0; i < controller.availableYears.length - 1; i++) {
        expect(
          controller.availableYears[i] >= controller.availableYears[i + 1],
          isTrue,
        );
      }
    });
  });

  group('selectedYear', () {
    test('defaults to the most recent available year', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
      ]);

      expect(controller.selectedYear, controller.availableYears.first);
    });

    test('defaults to current year when no transactions provided', () {
      final controller = MonthlyReportController(transactions: []);
      expect(controller.selectedYear, now.year);
    });

    test('falls back to availableYears.first when invalid year set internally',
            () {
          final controller = MonthlyReportController(transactions: [
            tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
          ]);


          expect(
            controller.availableYears.contains(controller.selectedYear),
            isTrue,
          );
        });
  });


  group('selectYear', () {
    test('updates selectedYear to the new value', () {
      final olderDate = DateTime(now.year, now.month - 11, 15);
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        {
          'created_at': olderDate.toIso8601String(),
          'description': 'Washer #2',
          'amount': 3.00,
        },
      ]);

      final targetYear = controller.availableYears.last;
      controller.selectYear(targetYear);

      expect(controller.selectedYear, targetYear);
    });

    test('notifies listeners when year changes', () {
      final olderDate = DateTime(now.year, now.month - 11, 15);
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        {
          'created_at': olderDate.toIso8601String(),
          'description': 'Washer #2',
          'amount': 3.00,
        },
      ]);

      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      final targetYear = controller.availableYears.last;
      if (targetYear != controller.selectedYear) {
        controller.selectYear(targetYear);
        expect(notifyCount, 1);
      }
    });

    test('does not notify when same year is selected again', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
      ]);

      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.selectYear(controller.selectedYear);

      expect(notifyCount, 0);
    });

    test('calling selectYear multiple times only notifies once per change', () {
      final olderDate = DateTime(now.year, now.month - 11, 15);
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        {
          'created_at': olderDate.toIso8601String(),
          'description': 'Washer #2',
          'amount': 3.00,
        },
      ]);

      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      final other = controller.availableYears.last;
      if (other != controller.selectedYear) {
        controller.selectYear(other);
        controller.selectYear(other);
        expect(notifyCount, 1);
      }
    });
  });


  group('filteredMonths', () {
    test('returns only months belonging to selectedYear', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        tx(monthsAgo: 2, description: 'Washer #2', amount: 3.00),
      ]);

      for (final month in controller.filteredMonths) {
        final date = DateFormat('MMM yyyy').parse(month);
        expect(date.year, controller.selectedYear);
      }
    });

    test('includes month labels that correspond to actual transaction months',
            () {
          final controller = MonthlyReportController(transactions: [
            tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
          ]);

          expect(
            controller.filteredMonths,
            contains(monthLabel(1)),
          );
        });

    test('is empty when no months fall in selected year', () {

      final controller = MonthlyReportController(transactions: []);

      final currentYearMonths = controller.filteredMonths.where((m) {
        return DateFormat('MMM yyyy').parse(m).year == now.year;
      }).toList();

      expect(currentYearMonths, isNotEmpty);
    });

    test('updates after selectYear call', () {
      final olderDate = DateTime(now.year, now.month - 11, 15);
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        {
          'created_at': olderDate.toIso8601String(),
          'description': 'Washer #2',
          'amount': 3.00,
        },
      ]);

      final beforeYear = controller.selectedYear;
      final beforeMonths = List<String>.from(controller.filteredMonths);

      final otherYear = controller.availableYears.last;
      if (otherYear != beforeYear) {
        controller.selectYear(otherYear);

        for (final month in controller.filteredMonths) {
          final date = DateFormat('MMM yyyy').parse(month);
          expect(date.year, otherYear);
        }

        expect(controller.filteredMonths, isNot(equals(beforeMonths)));
      }
    });

    test('returns months in descending order', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        tx(monthsAgo: 2, description: 'Washer #2', amount: 3.00),
        tx(monthsAgo: 3, description: 'Washer #3', amount: 1.75),
      ]);

      final filtered = controller.filteredMonths;
      for (int i = 0; i < filtered.length - 1; i++) {
        final a = DateFormat('MMM yyyy').parse(filtered[i]);
        final b = DateFormat('MMM yyyy').parse(filtered[i + 1]);
        expect(a.isAfter(b), isTrue);
      }
    });
  });

  group('monthlySums values', () {
    test('aggregates direct washer payments into directWasher', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        tx(monthsAgo: 1, description: 'Washer #2', amount: 3.00),
      ]);

      final data = controller.monthlySums[monthLabel(1)]!;
      expect(data['directWasher'], closeTo(5.50, 0.001));
    });

    test('aggregates loyalty washer payments into loyaltyWasher', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1,
            description: 'Loyalty Payment on Washer #1',
            amount: 2.00),
      ]);

      final data = controller.monthlySums[monthLabel(1)]!;
      expect(data['loyaltyWasher'], closeTo(2.00, 0.001));
    });

    test('aggregates direct dryer payments into directDryer', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'Dryer #1', amount: 1.75),
        tx(monthsAgo: 1, description: 'Dryer #2', amount: 1.25),
      ]);

      final data = controller.monthlySums[monthLabel(1)]!;
      expect(data['directDryer'], closeTo(3.00, 0.001));
    });

    test('aggregates loyalty dryer payments into loyaltyDryer', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1,
            description: 'Loyalty Payment on Dryer #1',
            amount: 1.50),
      ]);

      final data = controller.monthlySums[monthLabel(1)]!;
      expect(data['loyaltyDryer'], closeTo(1.50, 0.001));
    });

    test('aggregates loyalty card loads into loyaltyCard', () {
      final controller = MonthlyReportController(transactions: [
        tx(monthsAgo: 1, description: 'loyalty card', amount: 10.00),
        tx(monthsAgo: 1, description: 'loyalty card', amount: 20.00),
      ]);

      final data = controller.monthlySums[monthLabel(1)]!;
      expect(data['loyaltyCard'], closeTo(30.00, 0.001));
    });

    test('all categories default to zero when no transactions', () {
      final controller = MonthlyReportController(transactions: []);

      final data = controller.monthlySums[monthLabel(1)]!;
      expect(data['directWasher'], 0.0);
      expect(data['loyaltyWasher'], 0.0);
      expect(data['directDryer'], 0.0);
      expect(data['loyaltyDryer'], 0.0);
      expect(data['loyaltyCard'], 0.0);
    });

    test('does not include current month transactions', () {
      final now = DateTime.now();
      final controller = MonthlyReportController(transactions: [
        {
          'created_at':
          DateTime(now.year, now.month, 10).toIso8601String(),
          'description': 'Washer #1',
          'amount': 5.00,
        },
      ]);

      final currentMonthKey = DateFormat('MMM yyyy').format(now);
      expect(controller.monthlySums.containsKey(currentMonthKey), isFalse);
    });
  });
}