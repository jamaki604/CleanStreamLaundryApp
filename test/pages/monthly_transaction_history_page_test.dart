import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/pages/monthly_transaction_history.dart';
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
              MonthlyTransactionHistory(transactions: []),
        ),
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
    testWidgets('renders AppBar title even when transactions empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Monthly Transaction History'), findsOneWidget);
    });
  });
}
