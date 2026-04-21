import 'package:clean_stream_laundry_app/features/refund_request/controller.dart';
import 'package:clean_stream_laundry_app/features/refund_request/widgets/refund_form.dart';
import 'package:clean_stream_laundry_app/features/refund_request/widgets/transactions_search_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../mocks.dart';

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
  });

  RefundController buildController({
    List<String> transactions = const [],
    List<int> ids = const [],
    bool isFetchingTransactions = false,
    String? selectedTransaction,
    bool attemptedSubmit = false,
  }) {
    when(() => mockTransactionService.getRefundableTransactionsForUser())
        .thenAnswer((_) async => (transactions: transactions, ids: ids));

    final controller = RefundController(
      authService: mockAuthService,
      transactionService: mockTransactionService,
      edgeFunctionService: mockEdgeFunctionService,
      profileService: mockProfileService,
    );

    controller.recentTransactions = List.from(transactions);
    controller.recentTransactionIDs = List.from(ids);
    controller.isFetchingTransactions = isFetchingTransactions;
    if (selectedTransaction != null) {
      controller.selectedTransaction = selectedTransaction;
      controller.selectedTransactionIndex =
          transactions.indexOf(selectedTransaction);
    }
    if (attemptedSubmit) controller.attemptedSubmit = true;

    return controller;
  }

  Widget buildWidget(RefundController controller) {
    return MaterialApp(
      home: Scaffold(
        body: _ControllerWrapper(
          controller: controller,
        ),
      ),
    );
  }


  group('Initial rendering', () {
    testWidgets('displays Select a Transaction label', (tester) async {
      final controller = buildController();
      await tester.pumpWidget(buildWidget(controller));

      expect(find.text('Select a Transaction'), findsOneWidget);
    });

    testWidgets('displays Reason for Refund label', (tester) async {
      final controller = buildController();
      await tester.pumpWidget(buildWidget(controller));

      expect(find.text('Reason for Refund'), findsOneWidget);
    });

    testWidgets('displays transaction picker hint text', (tester) async {
      final controller = buildController();
      await tester.pumpWidget(buildWidget(controller));

      expect(find.text('Select a transaction'), findsOneWidget);
    });

    testWidgets('displays description hint text', (tester) async {
      final controller = buildController();
      await tester.pumpWidget(buildWidget(controller));

      expect(
        find.text('Describe the issue with your transaction...'),
        findsOneWidget,
      );
    });

    testWidgets('does not show validation error initially', (tester) async {
      final controller = buildController();
      await tester.pumpWidget(buildWidget(controller));

      expect(find.text('Please fill in all fields'), findsNothing);
    });

    testWidgets('shows TextFormField and TextField', (tester) async {
      final controller = buildController();
      await tester.pumpWidget(buildWidget(controller));

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });
  });


  group('Loading state', () {
    testWidgets('shows CircularProgressIndicator while fetching', (tester) async {
      final controller = buildController(isFetchingTransactions: true);
      await tester.pumpWidget(buildWidget(controller));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('shows picker when not fetching', (tester) async {
      final controller = buildController(isFetchingTransactions: false);
      await tester.pumpWidget(buildWidget(controller));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });


  group('Selected transaction', () {
    testWidgets('displays selected transaction in picker field', (tester) async {
      final controller = buildController(
        transactions: ['\$10.00 - Washer on Jan 01'],
        ids: [1],
        selectedTransaction: '\$10.00 - Washer on Jan 01',
      );
      await tester.pumpWidget(buildWidget(controller));

      expect(find.text('\$10.00 - Washer on Jan 01'), findsOneWidget);
    });
  });


  group('Bottom sheet', () {
    testWidgets('tapping picker opens TransactionSearchSheet', (tester) async {
      final controller = buildController(
        transactions: ['\$10.00 - Washer on Jan 01'],
        ids: [1],
      );
      await tester.pumpWidget(buildWidget(controller));

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionSearchSheet), findsOneWidget);
    });

    testWidgets('selecting a transaction from sheet calls selectTransaction',
            (tester) async {
          final controller = buildController(
            transactions: ['\$10.00 - Washer on Jan 01'],
            ids: [1],
          );
          await tester.pumpWidget(buildWidget(controller));

          await tester.tap(find.byType(GestureDetector));
          await tester.pumpAndSettle();

          await tester.tap(find.text('\$10.00 - Washer on Jan 01'));
          await tester.pumpAndSettle();

          expect(controller.selectedTransaction, '\$10.00 - Washer on Jan 01');
        });
  });


  group('Description input', () {
    testWidgets('can enter text in description field', (tester) async {
      final controller = buildController();
      await tester.pumpWidget(buildWidget(controller));

      await tester.enterText(
        find.widgetWithText(
            TextField, 'Describe the issue with your transaction...'),
        'My machine broke',
      );

      expect(controller.descriptionController.text, 'My machine broke');
    });
  });


  group('Validation error', () {
    testWidgets('shows error when attemptedSubmit is true and form is invalid',
            (tester) async {
          final controller = buildController(attemptedSubmit: true);
          await tester.pumpWidget(buildWidget(controller));

          expect(find.text('Please fill in all fields'), findsOneWidget);
          expect(find.byIcon(Icons.info_outline), findsOneWidget);
        });

    testWidgets(
        'does not show error when attemptedSubmit is true but form is valid',
            (tester) async {
          final controller = buildController(
            transactions: ['\$10.00 - Washer on Jan 01'],
            ids: [1],
            selectedTransaction: '\$10.00 - Washer on Jan 01',
            attemptedSubmit: true,
          );
          controller.descriptionController.text = 'Valid reason';
          await tester.pumpWidget(buildWidget(controller));

          expect(find.text('Please fill in all fields'), findsNothing);
        });

    testWidgets('error disappears after form becomes valid', (tester) async {
      final controller = buildController(
        transactions: ['\$10.00 - Washer on Jan 01'],
        ids: [1],
        attemptedSubmit: true,
      );
      await tester.pumpWidget(buildWidget(controller));

      expect(find.text('Please fill in all fields'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('\$10.00 - Washer on Jan 01'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(
            TextField, 'Describe the issue with your transaction...'),
        'Good reason',
      );
      await tester.pump();

      expect(find.text('Please fill in all fields'), findsNothing);
    });
  });
}

// rebuilds form whenever the controller notifies.

class _ControllerWrapper extends StatefulWidget {
  final RefundController controller;

  const _ControllerWrapper({
    required this.controller,
  });

  @override
  State<_ControllerWrapper> createState() => _ControllerWrapperState();
}

class _ControllerWrapperState extends State<_ControllerWrapper> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    widget.controller.descriptionController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    widget.controller.descriptionController.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RefundForm(controller: widget.controller);
}