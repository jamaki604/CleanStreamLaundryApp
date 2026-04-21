import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/features/loyalty/controller.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'mocks.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';

void main() {
  late LoyaltyController controller;
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;
  late MockTransactionService mockTransactionService;
  late MockPaymentProcessor mockPaymentProcessor;

  setUp(() {
    GetIt.instance.reset();

    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();
    mockTransactionService = MockTransactionService();
    mockPaymentProcessor = MockPaymentProcessor();

    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);
    GetIt.instance.registerSingleton<TransactionService>(
      mockTransactionService,
    );
    GetIt.instance.registerSingleton<PaymentProcessor>(mockPaymentProcessor);

    controller = LoyaltyController();
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('initialize', () {
    test('should fetch balance and transactions successfully', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': 100.0, 'full_name': 'Jane Doe'});
      when(
            () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      await controller.initialize();

      expect(controller.userBalance, 100.0);
      expect(controller.userName, 'Jane Doe');
      expect(controller.isLoading, false);
      expect(controller.errorMessage, null);

      verify(() => mockAuthService.getCurrentUserId).called(1);
      verify(() => mockProfileService.getUserBalanceById('user123')).called(1);
      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    test('should handle profile service error gracefully', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockProfileService.getUserBalanceById('user123'),
      ).thenThrow(Exception('Network error'));
      when(
            () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      await controller.initialize();

      expect(controller.errorMessage, 'Failed to fetch balance');
      expect(controller.isLoading, false);
    });

    test('initialize should handle null userId', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);
      when(() => mockTransactionService.getTransactionsForUser())
          .thenAnswer((_) async => []);

      await controller.initialize();

      expect(controller.errorMessage, 'User not known');
      expect(controller.isLoading, false);

      verifyNever(() => mockProfileService.getUserBalanceById(any()));
    });

    test('should default to 0.0 balance when null', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': null, 'full_name': 'Jane Doe'});
      when(
            () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      await controller.initialize();

      expect(controller.userBalance, 0.0);
      expect(controller.userName, 'Jane Doe');
    });

    test('should default to "John Doe" when name is null', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': 100.0, 'full_name': null});
      when(
            () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      await controller.initialize();

      expect(controller.userName, 'John Doe');
    });
  });

  group('toggleTransactionView', () {
    test('should toggle showPastTransactions from false to true', () async {
      when(
            () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      expect(controller.showPastTransactions, false);

      await controller.toggleTransactionView();

      expect(controller.showPastTransactions, true);
      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    test('should toggle showPastTransactions from true to false', () async {
      when(
            () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      controller.showPastTransactions = true;

      await controller.toggleTransactionView();

      expect(controller.showPastTransactions, false);
    });
  });

  group('fetchTransactions', () {
    test('should call transaction service', () async {
      when(
            () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      await controller.fetchTransactions();

      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    test('fetchTransactions filters out Rewards and old transactions', () async {
      final now = DateTime.now();
      when(() => mockTransactionService.getTransactionsForUser()).thenAnswer(
            (_) async => [
          {
            'created_at': now.toIso8601String(),
            'type': 'Laundry',
            'amount': 10,
            'description': 'Wash',
          },
          {
            'created_at': now.toIso8601String(),
            'type': 'Rewards',
            'amount': 1,
            'description': 'Reward',
          },
          {
            'created_at':
            now.subtract(const Duration(days: 40)).toIso8601String(),
            'type': 'Laundry',
            'amount': 5,
            'description': 'Old wash',
          },
        ],
      );

      await controller.toggleTransactionView();

      expect(controller.recentTransactions.length, 1);
    });
  });

  group('loadCard', () {
    test('loadCard should update balance and fetch transactions on success',
            () async {
          when(() => mockAuthService.getCurrentUserId).thenReturn('user123');

          controller.userBalance = 20.0;

          when(() => mockPaymentProcessor.processPayment(
            10.0,
            'Loyalty Card',
          )).thenAnswer((_) async => PaymentResult.success);

          when(() => mockProfileService.updateBalanceById('user123', 30))
              .thenAnswer((_) async => Future.value());

          when(() => mockProfileService.updateRewardsById(any(), any()))
              .thenAnswer((_) async => Future.value());

          when(() => mockTransactionService.getTransactionsForUser())
              .thenAnswer((_) async => []);

          final result = await controller.loadCard(10.0);

          expect(result, PaymentResult.success);
          expect(controller.userBalance, 30);

          verify(() => mockProfileService.updateBalanceById('user123', 30))
              .called(1);
          verify(() => mockTransactionService.getTransactionsForUser()).called(1);
        });

    test('loadCard should not update balance on failed payment', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');

      controller.userBalance = 20.0;

      when(() => mockPaymentProcessor.processPayment(
        10.0,
        'Loyalty Card',
      )).thenAnswer((_) async => PaymentResult.failed);

      final result = await controller.loadCard(10.0);

      expect(result, PaymentResult.failed);
      expect(controller.userBalance, 20.0);

      verifyNever(() => mockProfileService.updateBalanceById(any(), any()));
    });
  });
}