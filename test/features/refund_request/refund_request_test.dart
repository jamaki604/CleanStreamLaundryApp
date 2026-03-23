import 'package:clean_stream_laundry_app/features/refund_request/refund_request.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/features/refund_request/widgets/transactions_search_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';
import 'dart:async';

void main() {
  late MockAuthService mockAuthService;
  late MockTransactionService mockTransactionService;
  late MockEdgeFunctionService mockEdgeFunctionService;
  late MockProfileService mockProfileService;

  setUp(() async {
    mockAuthService = MockAuthService();
    mockTransactionService = MockTransactionService();
    mockEdgeFunctionService = MockEdgeFunctionService();
    mockProfileService = MockProfileService();

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<TransactionService>(mockTransactionService);
    GetIt.instance.registerSingleton<EdgeFunctionService>(mockEdgeFunctionService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);

    when(() => mockAuthService.getCurrentUserId).thenReturn('test-user-id');
    when(() => mockTransactionService.getRefundableTransactionsForUser())
        .thenAnswer((_) async => (transactions: <String>[], ids: <int>[]));
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const RefundPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) =>
            const Scaffold(body: Text('Settings Page')),
          ),
        ],
      ),
    );
  }

  void mockTransactions({
    List<String> transactions = const [],
    List<int> ids = const [],
  }) {
    when(() => mockTransactionService.getRefundableTransactionsForUser())
        .thenAnswer((_) async => (transactions: transactions, ids: ids));
  }

  Future<void> selectTransaction(WidgetTester tester, String transaction) async {
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    await tester.tap(find.text(transaction));
    await tester.pumpAndSettle();
  }

  Future<void> enterDescription(WidgetTester tester, String text) async {
    await tester.enterText(
      find.widgetWithText(
          TextField, 'Describe the issue with your transaction...'),
      text,
    );
    await tester.pumpAndSettle();
  }

  group('Static UI', () {
    testWidgets('renders all required UI elements', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Request Refund'), findsOneWidget);
      expect(find.text('Submit a Refund Request'), findsOneWidget);
      expect(
        find.text(
          'Select a transaction and describe your issue. '
              'Our team will review it shortly.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
      expect(find.text('Select a Transaction'), findsOneWidget);
      expect(
        find.text('Describe the issue with your transaction...'),
        findsOneWidget,
      );
      expect(find.text('Submit Refund Request'), findsOneWidget);
    });

    testWidgets('displays disclaimer text', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Refund requests are reviewed within 3–5 business days.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('displays back arrow in AppBar', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });


  group('Transaction fetching', () {
    testWidgets('calls getRefundableTransactionsForUser on init', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      verify(() => mockTransactionService.getRefundableTransactionsForUser())
          .called(1);
    });

    testWidgets('shows loading indicator while fetching', (tester) async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return (transactions: <String>[], ids: <int>[]);
      });

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('handles fetch error gracefully', (tester) async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Request Refund'), findsOneWidget);
    });
  });


  group('Transaction selection', () {
    testWidgets('opens bottom sheet when transaction picker tapped',
            (tester) async {
          mockTransactions(
            transactions: ['\$10.00 - machine on Jan 01, 2024'],
            ids: [1],
          );

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await tester.tap(find.byType(TextFormField));
          await tester.pumpAndSettle();

          expect(find.byType(TransactionSearchSheet), findsOneWidget);
        });

    testWidgets('selecting a transaction updates the picker field',
            (tester) async {
          mockTransactions(
            transactions: ['\$10.00 - machine on Jan 01, 2024'],
            ids: [1],
          );

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await selectTransaction(tester, '\$10.00 - machine on Jan 01, 2024');

          expect(find.text('\$10.00 - machine on Jan 01, 2024'), findsOneWidget);
        });
  });

  group('Form validation', () {
    testWidgets('shows error when submit tapped with empty form', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Refund Request'));
      await tester.pump();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('does not show error before first submit attempt', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsNothing);
    });

    testWidgets('error disappears after form becomes valid', (tester) async {
      mockTransactions(
        transactions: ['\$10.00 - machine on Jan 01, 2024'],
        ids: [1],
      );

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Trigger validation error
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Refund Request'));
      await tester.pump();
      expect(find.text('Please fill in all fields'), findsOneWidget);

      // Fill in form
      await selectTransaction(tester, '\$10.00 - machine on Jan 01, 2024');
      await enterDescription(tester, 'Test reason');

      expect(find.text('Please fill in all fields'), findsNothing);
    });
  });

  group('Refund submission', () {
    testWidgets('calls all required services on valid submission',
            (tester) async {
          mockTransactions(
            transactions: ['\$25.50 - machine on Jan 01, 2024'],
            ids: [123],
          );
          when(() => mockProfileService.getUserNameById('test-user-id'))
              .thenAnswer((_) async => 'Test User');
          when(() => mockTransactionService.recordRefundRequest(
            transaction_id: any(named: 'transaction_id'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => '25.50');
          when(() => mockEdgeFunctionService.runEdgeFunction(
            name: any(named: 'name'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => null);

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await selectTransaction(tester, '\$25.50 - machine on Jan 01, 2024');
          await enterDescription(tester, 'Test refund reason');

          await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Refund Request'));
          await tester.pumpAndSettle();

          verify(() => mockProfileService.getUserNameById('test-user-id')).called(1);
          verify(() => mockTransactionService.recordRefundRequest(
            transaction_id: '123',
            description: 'Test refund reason',
          )).called(1);
          verify(() => mockEdgeFunctionService.runEdgeFunction(
            name: 'refund-email',
            body: any(named: 'body'),
          )).called(1);
        });

    testWidgets('calls edge function with correct parameters', (tester) async {
      mockTransactions(
        transactions: ['\$50.00 - machine on Jan 15, 2024'],
        ids: [456],
      );
      when(() => mockProfileService.getUserNameById('test-user-id'))
          .thenAnswer((_) async => 'John Doe');
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => '50.00');
      when(() => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await selectTransaction(tester, '\$50.00 - machine on Jan 15, 2024');
      await enterDescription(tester, 'Wrong charge');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Refund Request'));
      await tester.pumpAndSettle();

      verify(() => mockEdgeFunctionService.runEdgeFunction(
        name: 'refund-email',
        body: {
          'username': 'John Doe',
          'user_id': 'test-user-id',
          'transaction_id': '456',
          'amount': '50.00',
          'description': 'Wrong charge',
        },
      )).called(1);
    });

    testWidgets('does not call services when userId is null', (tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      verifyNever(() => mockProfileService.getUserNameById(any()));
      verifyNever(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      ));
    });

    testWidgets('shows success dialog after submission', (tester) async {
      mockTransactions(
        transactions: ['\$10.00 - machine on Jan 01, 2024'],
        ids: [1],
      );
      when(() => mockProfileService.getUserNameById(any()))
          .thenAnswer((_) async => 'Test User');
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => '10.00');
      when(() => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await selectTransaction(tester, '\$10.00 - machine on Jan 01, 2024');
      await enterDescription(tester, 'Test reason');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Refund Request'));
      await tester.pumpAndSettle();

      expect(find.text('Success'), findsOneWidget);
      expect(
        find.text('Your refund request has been submitted'),
        findsOneWidget,
      );
    });

    testWidgets('navigates to settings after dismissing success dialog',
            (tester) async {
          mockTransactions(
            transactions: ['\$10.00 - machine on Jan 01, 2024'],
            ids: [1],
          );
          when(() => mockProfileService.getUserNameById(any()))
              .thenAnswer((_) async => 'Test User');
          when(() => mockTransactionService.recordRefundRequest(
            transaction_id: any(named: 'transaction_id'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => '10.00');
          when(() => mockEdgeFunctionService.runEdgeFunction(
            name: any(named: 'name'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => null);

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await selectTransaction(tester, '\$10.00 - machine on Jan 01, 2024');
          await enterDescription(tester, 'Test reason');

          await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Refund Request'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();

          expect(find.text('Settings Page'), findsOneWidget);
        });

    testWidgets('shows loading indicator while submitting', (tester) async {
      mockTransactions(
        transactions: ['\$10.00 - machine on Jan 01, 2024'],
        ids: [1],
      );
      when(() => mockProfileService.getUserNameById(any()))
          .thenAnswer((_) async => 'Test User');

      final completer = Completer<String>();
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await selectTransaction(tester, '\$10.00 - machine on Jan 01, 2024');
      await enterDescription(tester, 'Test reason');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Refund Request'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete('10.00');
      when(() => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);
      await tester.pumpAndSettle();
    });
  });

  group('Keyboard enter', () {
    testWidgets('pressing Enter triggers refund when form is valid',
            (tester) async {
          mockTransactions(
            transactions: ['\$25.50 - machine on Jan 01, 2024'],
            ids: [123],
          );
          when(() => mockProfileService.getUserNameById('test-user-id'))
              .thenAnswer((_) async => 'Test User');
          when(() => mockTransactionService.recordRefundRequest(
            transaction_id: any(named: 'transaction_id'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => '25.50');
          when(() => mockEdgeFunctionService.runEdgeFunction(
            name: any(named: 'name'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => null);

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await selectTransaction(tester, '\$25.50 - machine on Jan 01, 2024');
          await enterDescription(tester, 'Test refund reason');

          final keyboardListener =
          tester.widget<KeyboardListener>(find.byType(KeyboardListener));
          keyboardListener.focusNode.requestFocus();
          await tester.pump();

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          verify(() => mockEdgeFunctionService.runEdgeFunction(
            name: 'refund-email',
            body: any(named: 'body'),
          )).called(1);
        });
  });
}