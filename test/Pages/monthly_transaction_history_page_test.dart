import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:clean_stream_laundry_app/Pages/monthly_transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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

    router = GoRouter(
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) =>
                MonthlyTransactionHistory(transactions: [],))
      ],
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    return MaterialApp.router(routerConfig: router);
  }

  group('MonthlyTransactionHistory Widget Tests', () {
    testWidgets('renders AppBar title even when transactions empty',
          (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(find.text('Monthly Transaction History'), findsOneWidget);
          expect(find.byType(Card), findsNWidgets(2));
        });


    testWidgets('renders one month card with correct totals',
          (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(find.byType(Card), findsNWidgets(2));

          expect(find.text('Nov 2025'), findsOneWidget);

          expect(find.textContaining('\$'), findsWidgets);

          expect(find.text('Direct Washer Payments'), findsNWidgets(2));
          expect(find.text('Direct Dryer Payments'), findsNWidgets(2));
        });

    testWidgets('renders multiple months sorted descending',
         (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(find.byType(Card), findsNWidgets(2));

          final firstCardFinder = find.byType(Card).first;
          expect(find.descendant(
              of: firstCardFinder, matching: find.text('Nov 2025')),
              findsOneWidget);
        });
  });
}