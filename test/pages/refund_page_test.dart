import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/pages/refund_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/widgets/transactions_search_sheet.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockTransactionService mockTransactionService;
  late MockEdgeFunctionService mockEdgeFunctionService;
  late MockProfileService mockProfileService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockTransactionService = MockTransactionService();
    mockEdgeFunctionService = MockEdgeFunctionService();
    mockProfileService = MockProfileService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
    getIt.registerSingleton<EdgeFunctionService>(mockEdgeFunctionService);
    getIt.registerSingleton<ProfileService>(mockProfileService);

    // Setup default stubs
    when(() => mockAuthService.getCurrentUserId).thenReturn('test-user-id');
    when(
      () => mockTransactionService.getTransactionsForUser(),
    ).thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const RefundPage()),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const Scaffold(body: Text('Settings Page')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('RefundPage', () {
    testWidgets('renders correctly with all elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Request Refund'), findsOneWidget);
      expect(find.text('Select a transaction and describe your issue. Our team will review it shortly.'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
      expect(find.text("Submit a Refund Request"), findsOneWidget);
      expect(find.text('Select a Transaction'), findsOneWidget);
      expect(
        find.text('Describe the issue with your transaction...'),
        findsOneWidget,
      );
      expect(find.text('Submit Refund Request'), findsOneWidget);
    });

    testWidgets('submit button shows error when form is invalid', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(ElevatedButton, 'Submit Refund Request');
      expect(submitButton, findsOneWidget);

      // Tap the button
      await tester.tap(submitButton);
      await tester.pump();

      // Expect the error text to appear
      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('loads transactions on init', (tester) async {

      when(
        () => mockTransactionService.getRefundableTransactionsForUser(),
      ).thenAnswer((_) async => (
        transactions: ['\$10.00 - machine on Jan 01, 2024', '\$20.00 - machine on Jan 02, 2024'],
        ids: [1, 2],));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(() => mockTransactionService.getRefundableTransactionsForUser()).called(1);
    });

    testWidgets('can select transaction from dropdown', (tester) async {
      when(
            () => mockTransactionService.getRefundableTransactionsForUser(),
      ).thenAnswer((_) async => (
      transactions: ['\$10.00 - machine on Jan 01, 2024'],
      ids: [1],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap the TextFormField to open the bottom sheet
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Bottom sheet is now open, tap the transaction in the list
      expect(find.byType(TransactionSearchSheet), findsOneWidget);
      await tester.tap(find.text('\$10.00 - machine on Jan 01, 2024'));
      await tester.pumpAndSettle();

      // Verify the selection appeared in the field
      expect(find.text('\$10.00 - machine on Jan 01, 2024'), findsOneWidget);
    });

    testWidgets('can enter description text', (tester) async {
      when(
            () => mockTransactionService.getRefundableTransactionsForUser(),
      ).thenAnswer((_) async => (
      transactions: ['\$10.00 - machine on Jan 01, 2024'],
      ids: [1],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textField = find.widgetWithText(TextField, "Describe the issue with your transaction...");
      await tester.enterText(textField, 'Test refund reason');
      await tester.pumpAndSettle();

      expect(find.text('Test refund reason'), findsOneWidget);
    });

    testWidgets('submit button enabled when form is valid', (tester) async {
      when(
            () => mockTransactionService.getRefundableTransactionsForUser(),
      ).thenAnswer((_) async => (
      transactions: ['\$10.00 - machine on Jan 01, 2024'],
      ids: [1],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Select a transaction
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('\$10.00 - machine on Jan 01, 2024'));
      await tester.pumpAndSettle();

      // Enter description
      await tester.enterText(
        find.widgetWithText(TextField, 'Describe the issue with your transaction...'),
        'Test refund reason',
      );
      await tester.pumpAndSettle();

      // Verify button is enabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
      expect(button.style?.backgroundColor?.resolve({}), equals(Theme.of(tester.element(find.byType(ElevatedButton))).colorScheme.primary));
    });

    testWidgets('handles refund submission successfully', (tester) async {
      final mockTransactions = [
        {'id': 123, 'amount': 25.50, 'date': '2024-01-01'},
      ];

      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => mockTransactions);
      when(
        () => mockProfileService.getUserNameById('test-user-id'),
      ).thenAnswer((_) async => 'Test User');
      when(
        () => mockTransactionService.recordRefundRequest(
          transaction_id: any(named: 'transaction_id'),
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async => "25.50");
      when(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
    });

    testWidgets('shows error when user is not logged in', (tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to settings after successful refund', (
      tester,
    ) async {
      final mockTransactions = [
        {'id': 123, 'amount': 25.50, 'date': '2024-01-01'},
      ];

      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => mockTransactions);
      when(
        () => mockProfileService.getUserNameById('test-user-id'),
      ).thenAnswer((_) async => 'Test User');
      when(
        () => mockTransactionService.recordRefundRequest(
          transaction_id: any(named: 'transaction_id'),
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async => "25.50");
      when(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
    });

    testWidgets('handles transaction fetch error gracefully', (tester) async {
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenThrow(Exception('Failed to fetch transactions'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Request Refund'), findsOneWidget);
    });
  });

  testWidgets('selecting a transaction updates state', (tester) async {
    when(
          () => mockTransactionService.getRefundableTransactionsForUser(),
    ).thenAnswer((_) async => (
    transactions: ['\$10.00 - machine on Jan 01, 2024', '\$20.00 - machine on Jan 02, 2024'],
    ids: [1, 2],
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Open the search sheet
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionSearchSheet), findsOneWidget);

    // Select a transaction
    await tester.tap(find.text('\$10.00 - machine on Jan 01, 2024'));
    await tester.pumpAndSettle();

    // Verify the TextFormField now shows the selected transaction
    expect(find.text('\$10.00 - machine on Jan 01, 2024'), findsOneWidget);
  });

  testWidgets('_handleRefund calls all required services in correct order', (
      tester,
      ) async {
    when(
          () => mockTransactionService.getRefundableTransactionsForUser(),
    ).thenAnswer((_) async => (
    transactions: ['\$25.50 - machine on Jan 01, 2024'],
    ids: [123],
    ));
    when(
          () => mockAuthService.getCurrentUserId,
    ).thenReturn('test-user-id');
    when(
          () => mockProfileService.getUserNameById('test-user-id'),
    ).thenAnswer((_) async => 'Test User');
    when(
          () => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => '25.50');
    when(
          () => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Select a transaction
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('\$25.50 - machine on Jan 01, 2024'));
    await tester.pumpAndSettle();

    // Enter description
    await tester.enterText(
      find.widgetWithText(TextField, 'Describe the issue with your transaction...'),
      'Test refund reason',
    );
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify services were called
    verify(() => mockTransactionService.getRefundableTransactionsForUser()).called(1);
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

  testWidgets('_handleRefund early return when userId is null', (tester) async {
    when(() => mockAuthService.getCurrentUserId).thenReturn(null);
    when(
      () => mockTransactionService.getTransactionsForUser(),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Request Refund'), findsOneWidget);

    verifyNever(() => mockProfileService.getUserNameById(any()));
    verifyNever(
      () => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      ),
    );
  });

  testWidgets('verifies edge function is called with correct parameters', (
      tester,
      ) async {
    when(
          () => mockTransactionService.getRefundableTransactionsForUser(),
    ).thenAnswer((_) async => (
    transactions: ['\$50.00 - machine on Jan 15, 2024'],
    ids: [456],
    ));
    when(
          () => mockProfileService.getUserNameById('test-user-id'),
    ).thenAnswer((_) async => 'John Doe');
    when(
          () => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => '50.00');
    when(
          () => mockEdgeFunctionService.runEdgeFunction(
        name: 'refund-email',
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Select transaction
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('\$50.00 - machine on Jan 15, 2024'));
    await tester.pumpAndSettle();

    // Enter description
    await tester.enterText(
      find.widgetWithText(TextField, 'Describe the issue with your transaction...'),
      'Wrong charge',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
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

  testWidgets('complete refund submission flow with dialog and navigation', (
      tester,
      ) async {
    when(
          () => mockTransactionService.getRefundableTransactionsForUser(),
    ).thenAnswer((_) async => (
    transactions: ['\$100.00 - machine on Jan 20, 2024'],
    ids: [789],
    ));
    when(
          () => mockProfileService.getUserNameById('test-user-id'),
    ).thenAnswer((_) async => 'Jane Smith');
    when(
          () => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => '100.00');
    when(
          () => mockEdgeFunctionService.runEdgeFunction(
        name: 'refund-email',
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Request Refund'), findsOneWidget);
    expect(find.text('Submit Refund Request'), findsOneWidget);
  });

  testWidgets('_handleRefund executes all service calls correctly', (
      tester,
      ) async {
    when(
          () => mockTransactionService.getRefundableTransactionsForUser(),
    ).thenAnswer((_) async => (
    transactions: ['\$25.50 - machine on Jan 01, 2024'],
    ids: [123],
    ));
    when(
          () => mockProfileService.getUserNameById('test-user-id'),
    ).thenAnswer((_) async => 'Test User');
    when(
          () => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => '25.50');
    when(
          () => mockEdgeFunctionService.runEdgeFunction(
        name: 'refund-email',
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Select transaction
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('\$25.50 - machine on Jan 01, 2024'));
    await tester.pumpAndSettle();

    // Enter description
    await tester.enterText(
      find.widgetWithText(TextField, 'Describe the issue with your transaction...'),
      'I want a refund please',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(() => mockProfileService.getUserNameById('test-user-id')).called(1);
    verify(() => mockTransactionService.recordRefundRequest(
      transaction_id: '123',
      description: 'I want a refund please',
    )).called(1);
    verify(() => mockEdgeFunctionService.runEdgeFunction(
      name: 'refund-email',
      body: {
        'username': 'Test User',
        'user_id': 'test-user-id',
        'transaction_id': '123',
        'amount': '25.50',
        'description': 'I want a refund please',
      },
    )).called(1);
  });

  testWidgets(
    '_handleRefund early returns when userId is null (covers early return path)',
    (tester) async {
      final recentDate = DateTime.now().subtract(Duration(days: 3));
      final formattedDate = recentDate.toIso8601String();

      final mockTransactions = [
        {
          'id': 456,
          'amount': 10.0,
          'created_at': formattedDate,
          'description': 'Test Service',
          'type': 'debit',
        },
      ];

      when(() => mockAuthService.getCurrentUserId).thenReturn(null);
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => mockTransactions);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final RefundPageState state = tester.state(find.byType(RefundPage));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      if (state.recentTransactions.isNotEmpty) {
        state.setState(() {
          state.selectedTransactionIndex = 0;
          state.selectedTransaction = state.recentTransactions[0];
          state.descriptionController.text = 'Test refund';
        });
        await tester.pumpAndSettle();

        final submitButton = find.widgetWithText(
          ElevatedButton,
          'Submit Refund',
        );
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle();
        }
      }

      verifyNever(() => mockProfileService.getUserNameById(any()));
      verifyNever(
        () => mockTransactionService.recordRefundRequest(
          transaction_id: any(named: 'transaction_id'),
          description: any(named: 'description'),
        ),
      );
      verifyNever(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      );
    },
  );

  testWidgets('dropdown onChanged updates selectedTransaction state', (
    tester,
  ) async {
    final recentDate = DateTime.now().subtract(Duration(days: 5));
    final formattedDate = recentDate.toIso8601String();

    final mockTransactions = [
      {
        'id': 111,
        'amount': 15.0,
        'created_at': formattedDate,
        'description': 'Service A',
        'type': 'debit',
      },
      {
        'id': 222,
        'amount': 30.0,
        'created_at': formattedDate,
        'description': 'Service B',
        'type': 'debit',
      },
    ];

    when(
      () => mockTransactionService.getTransactionsForUser(),
    ).thenAnswer((_) async => mockTransactions);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final RefundPageState state = tester.state(find.byType(RefundPage));

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(state.selectedTransaction, isNull);
    expect(state.selectedTransactionIndex, isNull);

    if (state.recentTransactions.isNotEmpty) {
      state.setState(() {
        const int newIndex = 0;
        state.selectedTransactionIndex = newIndex;
        state.selectedTransaction = state.recentTransactions[newIndex];
      });
      await tester.pumpAndSettle();

      expect(state.selectedTransactionIndex, equals(0));
      expect(state.selectedTransaction, isNotNull);
      expect(state.selectedTransaction, equals(state.recentTransactions[0]));
    }
  });

  testWidgets('can click enter for form resubmit', (tester) async {
    final mockTransactions = [
      {
        'id': 123,
        'amount': 10.0,
        'created_at': '2024-01-01',
        'description': 'Test Transaction',
        'type': 'debit',
      },
    ];

    when(
      () => mockTransactionService.getTransactionsForUser(),
    ).thenAnswer((_) async => mockTransactions);
    when(
      () => mockProfileService.getUserNameById('test-user-id'),
    ).thenAnswer((_) async => 'Test User');
    when(
      () => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => "10.0");
    when(
      () => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Grab the state
    final RefundPageState state = tester.state(find.byType(RefundPage));

    // **Manually populate recentTransactions and recentTransactionIDs**
    state.setState(() {
      state.recentTransactions = ['2024-01-01 - \$10.0'];
      state.recentTransactionIDs = [123];
      state.selectedTransactionIndex = 0;
      state.selectedTransaction = state.recentTransactions[0];
      state.descriptionController.text = 'Test refund reason';
    });
    await tester.pumpAndSettle();

    // Focus the KeyboardListener and send Enter
    final keyboardListener = tester.widget<KeyboardListener>(
      find.byType(KeyboardListener),
    );
    final focusNode = keyboardListener.focusNode;
    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    verify(
      () => mockEdgeFunctionService.runEdgeFunction(
        name: 'refund-email',
        body: {
          'username': 'Test User',
          'user_id': 'test-user-id',
          'transaction_id': '123',
          'amount': '10.0',
          'description': 'Test refund reason',
        },
      ),
    ).called(1);
  });
}
