import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/pages/monthly_transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockTransactionService mockTransactionService;
  late GoRouter router;

  setUp(() {
    mockAuthService = MockAuthService();
    mockTransactionService = MockTransactionService();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }
    if (getIt.isRegistered<TransactionService>()) {
      getIt.unregister<TransactionService>();
    }
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
  });

  tearDown(() => GetIt.instance.reset());

  /// Helper function to create a transaction in the past month
  Map<String, dynamic> createTransaction({
    required int monthsAgo,
    required String description,
    required double amount,
  }) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month - monthsAgo, 15);
    return {
      'created_at': date.toIso8601String(),
      'description': description,
      'amount': amount,
    };
  }

  Widget createWidgetUnderTest(List<Map<String, dynamic>> transactions) {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              MonthlyTransactionHistory(transactions: transactions),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  Future<void> selectYearFilter(WidgetTester tester, int year) async {
    await tester.tap(find.byKey(const ValueKey('year-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('year-option-$year')));
    await tester.pumpAndSettle();
  }

  group('MonthlyTransactionHistory Widget Tests', () {
    testWidgets('renders AppBar title even when transactions empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest([]));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Transaction History'), findsOneWidget);
    });

    testWidgets('renders AppBar with back button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest([]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button pops the route', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest([]));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNotNull);
    });

    testWidgets('displays no cards when transactions are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest([]));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('displays card for month with transactions', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      final transactionYear = DateTime.parse(
        transactions.first['created_at'] as String,
      ).year;
      await selectYearFilter(tester, transactionYear);

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays correct monthly total', (WidgetTester tester) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
        createTransaction(monthsAgo: 1, description: 'Dryer #3', amount: 1.75),
        createTransaction(
          monthsAgo: 1,
          description: 'loyalty card',
          amount: 10.00,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$14.25'), findsOneWidget);
    });

    testWidgets('displays all transaction categories', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
        createTransaction(
          monthsAgo: 1,
          description: 'Loyalty Payment on Washer #3',
          amount: 2.00,
        ),
        createTransaction(monthsAgo: 1, description: 'Dryer #2', amount: 1.75),
        createTransaction(
          monthsAgo: 1,
          description: 'Loyalty Payment on Dryer #1',
          amount: 1.50,
        ),
        createTransaction(
          monthsAgo: 1,
          description: 'loyalty card',
          amount: 10.00,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('Direct Washer Payments'), findsOneWidget);
      expect(find.text('Loyalty Washer Payments'), findsOneWidget);
      expect(find.text('Direct Dryer Payments'), findsOneWidget);
      expect(find.text('Loyalty Dryer Payments'), findsOneWidget);
      expect(find.text('Loyalty Card Loads'), findsOneWidget);
    });

    testWidgets('displays correct amounts for each category', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
        createTransaction(monthsAgo: 1, description: 'Washer #3', amount: 3.00),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$5.50'), findsWidgets);
    });

    testWidgets('sorts months in descending order', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 3, description: 'Washer #5', amount: 2.50),
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 3.00),
        createTransaction(monthsAgo: 2, description: 'Washer #5', amount: 2.75),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      final cardFinder = find.byType(Card);
      expect(cardFinder, findsAtLeastNWidgets(2));

      final firstCard = cardFinder.first;
      final firstCardTexts = find.descendant(
        of: firstCard,
        matching: find.byType(Text),
      );
      expect(firstCardTexts, findsAtLeastNWidgets(1));

      final expectedMostRecent = DateFormat(
        'MMM yyyy',
      ).format(DateTime(DateTime.now().year, DateTime.now().month - 1, 1));
      expect(
        find.descendant(of: firstCard, matching: find.text(expectedMostRecent)),
        findsOneWidget,
      );
    });

    testWidgets('displays scrollbar', (WidgetTester tester) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets('displays ListView with proper padding', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, const EdgeInsets.all(16));
    });

    testWidgets('displays multiple months correctly', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 3, description: 'Washer #5', amount: 2.50),
        createTransaction(monthsAgo: 2, description: 'Washer #5', amount: 3.00),
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 3.50),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsAtLeastNWidgets(2));
    });

    testWidgets('displays divider between month and transaction details', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('displays zero amounts when no transactions of that type', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      final zeroAmountFinder = find.text('\$0.00');
      expect(zeroAmountFinder, findsWidgets);
    });

    testWidgets('card has proper margin', (WidgetTester tester) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 16));
    });

    testWidgets('handles loyalty washer payments correctly', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(
          monthsAgo: 1,
          description: 'Loyalty Payment on Washer #5',
          amount: 2.50,
        ),
        createTransaction(
          monthsAgo: 1,
          description: 'loyalty payment on washer #3',
          amount: 3.00,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$5.50'), findsWidgets);
    });

    testWidgets('handles loyalty dryer payments correctly', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(
          monthsAgo: 1,
          description: 'Loyalty Payment on Dryer #2',
          amount: 1.50,
        ),
        createTransaction(
          monthsAgo: 1,
          description: 'loyalty payment on dryer #1',
          amount: 1.25,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$2.75'), findsWidgets);
    });

    testWidgets('handles direct dryer payments correctly', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Dryer #2', amount: 1.50),
        createTransaction(monthsAgo: 1, description: 'DRYER #1', amount: 1.25),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$2.75'), findsWidgets);
    });

    testWidgets('handles loyalty card loads correctly', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(
          monthsAgo: 1,
          description: 'loyalty card',
          amount: 10.00,
        ),
        createTransaction(
          monthsAgo: 1,
          description: 'loyalty card',
          amount: 20.00,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$30.00'), findsWidgets);
    });

    testWidgets('displays formatted decimal amounts correctly', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.5),
        createTransaction(monthsAgo: 1, description: 'Dryer #3', amount: 1.76),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$2.50'), findsWidgets);
      expect(find.text('\$1.76'), findsWidgets);
    });

    testWidgets('multiple transactions in same month aggregate correctly', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #1', amount: 2.50),
        createTransaction(monthsAgo: 1, description: 'Washer #2', amount: 3.00),
        createTransaction(monthsAgo: 1, description: 'Washer #3', amount: 2.75),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$8.25'), findsWidgets);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('ignores current month transactions', (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final transactions = [
        {
          'created_at': DateTime(now.year, now.month, 15).toIso8601String(),
          'description': 'Washer #5',
          'amount': 2.50,
        },
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 3.00),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      final transactionYear = DateTime.parse(
        transactions.first['created_at'] as String,
      ).year;
      await selectYearFilter(tester, transactionYear);

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('\$3.00'), findsExactly(2));
    });

    testWidgets('handles transactions from exactly 11 months ago', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(
          monthsAgo: 11,
          description: 'Washer #5',
          amount: 2.50,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      final transactionYear = DateTime.parse(
        transactions.first['created_at'] as String,
      ).year;
      await selectYearFilter(tester, transactionYear);

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles mixed transaction types in same month', (
      WidgetTester tester,
    ) async {
      final transactions = [
        createTransaction(monthsAgo: 1, description: 'Washer #5', amount: 2.50),
        createTransaction(
          monthsAgo: 1,
          description: 'Loyalty Payment on Washer #3',
          amount: 2.00,
        ),
        createTransaction(monthsAgo: 1, description: 'Dryer #2', amount: 1.75),
        createTransaction(
          monthsAgo: 1,
          description: 'Loyalty Payment on Dryer #1',
          amount: 1.50,
        ),
        createTransaction(
          monthsAgo: 1,
          description: 'loyalty card',
          amount: 10.00,
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.text('\$14.25'), findsOneWidget);
      expect(find.text('\$2.50'), findsWidgets);
      expect(find.text('\$2.00'), findsWidgets);
      expect(find.text('\$1.75'), findsWidgets);
      expect(find.text('\$1.50'), findsWidgets);
      expect(find.text('\$10.00'), findsWidgets);
    });

    testWidgets('shows year filter options from transaction years', (
      WidgetTester tester,
    ) async {
      final newerDate = DateTime(
        DateTime.now().year,
        DateTime.now().month - 1,
        15,
      );
      final olderDate = DateTime(
        DateTime.now().year,
        DateTime.now().month - 11,
        15,
      );

      final expectedYears = <int>{newerDate.year, olderDate.year}.toList()
        ..sort((a, b) => b.compareTo(a));

      final transactions = [
        {
          'created_at': olderDate.toIso8601String(),
          'description': 'Washer #1',
          'amount': 2.50,
        },
        {
          'created_at': newerDate.toIso8601String(),
          'description': 'Dryer #1',
          'amount': 1.75,
        },
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('year-filter-button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('year-filter-button')));
      await tester.pumpAndSettle();

      expect(find.text('Year: ${expectedYears.first}'), findsOneWidget);

      for (final year in expectedYears) {
        expect(find.byKey(ValueKey('year-option-$year')), findsOneWidget);
      }

      await tester.tap(
        find.byKey(ValueKey('year-option-${expectedYears.first}')),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('selecting a year filter shows that year data', (
      WidgetTester tester,
    ) async {
      final newerDate = DateTime(
        DateTime.now().year,
        DateTime.now().month - 1,
        15,
      );
      final olderDate = DateTime(
        DateTime.now().year,
        DateTime.now().month - 11,
        15,
      );
      final newerYear = newerDate.year;
      final olderYear = olderDate.year;
      final olderMonthLabel = DateFormat(
        'MMM yyyy',
      ).format(DateTime(olderDate.year, olderDate.month, 1));
      final newerMonthLabel = DateFormat(
        'MMM yyyy',
      ).format(DateTime(newerDate.year, newerDate.month, 1));

      final transactions = [
        {
          'created_at': olderDate.toIso8601String(),
          'description': 'Washer #5',
          'amount': 2.50,
        },
        {
          'created_at': newerDate.toIso8601String(),
          'description': 'Dryer #2',
          'amount': 3.00,
        },
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      if (olderYear == newerYear) {
        expect(find.text(newerMonthLabel), findsOneWidget);
        expect(find.text(olderMonthLabel), findsOneWidget);
        return;
      }

      expect(find.text(newerMonthLabel), findsOneWidget);
      expect(find.text(olderMonthLabel), findsNothing);

      await selectYearFilter(tester, olderYear);

      expect(find.text(olderMonthLabel), findsOneWidget);
      expect(find.text(newerMonthLabel), findsNothing);
    });

    testWidgets('can switch between year filters without errors', (
      WidgetTester tester,
    ) async {
      final newerDate = DateTime(
        DateTime.now().year,
        DateTime.now().month - 1,
        15,
      );
      final olderDate = DateTime(
        DateTime.now().year,
        DateTime.now().month - 11,
        15,
      );
      final olderYear = olderDate.year;
      final newerYear = newerDate.year;

      final transactions = [
        {
          'created_at': olderDate.toIso8601String(),
          'description': 'Dryer #2',
          'amount': 1.75,
        },
        {
          'created_at': newerDate.toIso8601String(),
          'description': 'Washer #2',
          'amount': 2.25,
        },
      ];

      await tester.pumpWidget(createWidgetUnderTest(transactions));
      await tester.pumpAndSettle();

      await selectYearFilter(tester, olderYear);

      expect(tester.takeException(), isNull);

      if (olderYear != newerYear) {
        await selectYearFilter(tester, newerYear);
      }

      expect(tester.takeException(), isNull);
    });
  });
}
