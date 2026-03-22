import 'package:clean_stream_laundry_app/features/refund_request/controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';
import 'dart:async';

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

  RefundController buildController() => RefundController(
    authService: mockAuthService,
    transactionService: mockTransactionService,
    edgeFunctionService: mockEdgeFunctionService,
    profileService: mockProfileService,
  );

  group('fetchTransactions', () {
    test('populates recentTransactions and recentTransactionIDs', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$10.00 - Washer on Jan 01'],
      ids: [1],
      ));

      final controller = buildController();
      await controller.fetchTransactions();

      expect(controller.recentTransactions, ['\$10.00 - Washer on Jan 01']);
      expect(controller.recentTransactionIDs, [1]);
    });

    test('filters out loyalty card transactions', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: [
        '\$10.00 added to Loyalty Card on Jan 01',
        '\$5.00 - Washer on Jan 02',
      ],
      ids: [1, 2],
      ));

      final controller = buildController();
      await controller.fetchTransactions();

      expect(controller.recentTransactions.length, 1);
      expect(controller.recentTransactions.first, '\$5.00 - Washer on Jan 02');
    });

    test('sets isFetchingTransactions to false after completion', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async =>
      (transactions: <String>[], ids: <int>[]));

      final controller = buildController();
      expect(controller.isFetchingTransactions, isTrue);

      await controller.fetchTransactions();

      expect(controller.isFetchingTransactions, isFalse);
    });

    test('sets isFetchingTransactions to false even when service throws',
            () async {
          when(() => mockTransactionService.getRefundableTransactionsForUser())
              .thenThrow(Exception('Network error'));

          final controller = buildController();
          await controller.fetchTransactions();

          expect(controller.isFetchingTransactions, isFalse);
        });

    test('notifies listeners when fetch completes', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async =>
      (transactions: <String>[], ids: <int>[]));

      final controller = buildController();
      var notified = false;
      controller.addListener(() => notified = true);

      await controller.fetchTransactions();

      expect(notified, isTrue);
    });
  });

  group('selectTransaction', () {
    test('sets selectedTransaction and selectedTransactionIndex', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: [
        '\$10.00 - Washer on Jan 01',
        '\$20.00 - Dryer on Jan 02',
      ],
      ids: [1, 2],
      ));

      final controller = buildController();
      await controller.fetchTransactions();

      controller.selectTransaction('\$20.00 - Dryer on Jan 02');

      expect(controller.selectedTransaction, '\$20.00 - Dryer on Jan 02');
      expect(controller.selectedTransactionIndex, 1);
    });

    test('notifies listeners on selection', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$10.00 - Washer on Jan 01'],
      ids: [1],
      ));

      final controller = buildController();
      await controller.fetchTransactions();

      var notified = false;
      controller.addListener(() => notified = true);

      controller.selectTransaction('\$10.00 - Washer on Jan 01');

      expect(notified, isTrue);
    });
  });

  group('isFormValid', () {
    test('returns false when no transaction selected and description empty',
            () {
          final controller = buildController();
          expect(controller.isFormValid, isFalse);
        });

    test('returns false when transaction selected but description empty', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$10.00 - Washer on Jan 01'],
      ids: [1],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$10.00 - Washer on Jan 01');

      expect(controller.isFormValid, isFalse);
    });

    test('returns false when description filled but no transaction selected',
            () {
          final controller = buildController();
          controller.descriptionController.text = 'Some reason';

          expect(controller.isFormValid, isFalse);
        });

    test('returns true when both transaction and description are set', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$10.00 - Washer on Jan 01'],
      ids: [1],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$10.00 - Washer on Jan 01');
      controller.descriptionController.text = 'I want a refund';

      expect(controller.isFormValid, isTrue);
    });

    test('returns false when description is whitespace only', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$10.00 - Washer on Jan 01'],
      ids: [1],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$10.00 - Washer on Jan 01');
      controller.descriptionController.text = '   ';

      expect(controller.isFormValid, isFalse);
    });
  });

  group('getTransactionID', () {
    test('returns the correct ID for selected index', () async {
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: [
        '\$10.00 - Washer on Jan 01',
        '\$20.00 - Dryer on Jan 02',
      ],
      ids: [111, 222],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$20.00 - Dryer on Jan 02');

      expect(controller.getTransactionID(), '222');
    });
  });

  group('submitRefund', () {
    setUp(() async {});

    test('returns false immediately when userId is null', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);

      final controller = buildController();
      final result = await controller.submitRefund();

      expect(result, isFalse);
      verifyNever(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      ));
    });

    test('calls recordRefundRequest with correct args', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
      when(() => mockProfileService.getUserNameById('user-1'))
          .thenAnswer((_) async => 'John Doe');
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => '25.50');
      when(() => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$25.50 - Washer on Jan 01'],
      ids: [123],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$25.50 - Washer on Jan 01');
      controller.descriptionController.text = 'Test reason';

      await controller.submitRefund();

      verify(() => mockTransactionService.recordRefundRequest(
        transaction_id: '123',
        description: 'Test reason',
      )).called(1);
    });

    test('calls edge function with correct body', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
      when(() => mockProfileService.getUserNameById('user-1'))
          .thenAnswer((_) async => 'John Doe');
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => '25.50');
      when(() => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$25.50 - Washer on Jan 01'],
      ids: [123],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$25.50 - Washer on Jan 01');
      controller.descriptionController.text = 'Wrong charge';

      await controller.submitRefund();

      verify(() => mockEdgeFunctionService.runEdgeFunction(
        name: 'refund-email',
        body: {
          'username': 'John Doe',
          'user_id': 'user-1',
          'transaction_id': '123',
          'amount': '25.50',
          'description': 'Wrong charge',
        },
      )).called(1);
    });

    test('returns true on successful submission', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
      when(() => mockProfileService.getUserNameById('user-1'))
          .thenAnswer((_) async => 'John Doe');
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => '10.00');
      when(() => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$10.00 - Washer on Jan 01'],
      ids: [1],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$10.00 - Washer on Jan 01');
      controller.descriptionController.text = 'Reason';

      final result = await controller.submitRefund();

      expect(result, isTrue);
    });

    test('sets and clears isLoading around submission', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
      when(() => mockProfileService.getUserNameById('user-1'))
          .thenAnswer((_) async => 'John Doe');

      final completer = Completer<String>();
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenAnswer((_) => completer.future);
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$10.00 - Washer on Jan 01'],
      ids: [1],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$10.00 - Washer on Jan 01');
      controller.descriptionController.text = 'Reason';

      final future = controller.submitRefund();
      expect(controller.isLoading, isTrue);

      when(() => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);
      completer.complete('10.00');
      await future;

      expect(controller.isLoading, isFalse);
    });

    test('clears isLoading even when service throws', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
      when(() => mockProfileService.getUserNameById('user-1'))
          .thenAnswer((_) async => 'John Doe');
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenThrow(Exception('Server error'));
      when(() => mockTransactionService.getRefundableTransactionsForUser())
          .thenAnswer((_) async => (
      transactions: ['\$10.00 - Washer on Jan 01'],
      ids: [1],
      ));

      final controller = buildController();
      await controller.fetchTransactions();
      controller.selectTransaction('\$10.00 - Washer on Jan 01');
      controller.descriptionController.text = 'Reason';

      await expectLater(controller.submitRefund(), throwsException);

      expect(controller.isLoading, isFalse);
    });
  });

  group('markAttemptedSubmit', () {
    test('sets attemptedSubmit to true and notifies', () {
      final controller = buildController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.markAttemptedSubmit();

      expect(controller.attemptedSubmit, isTrue);
      expect(notified, isTrue);
    });
  });
}