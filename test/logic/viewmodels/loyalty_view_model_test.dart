import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'mocks.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';

void main() {
  late LoyaltyViewModel viewModel;
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;
  late MockTransactionService mockTransactionService;
  late MockPaymentProcessor mockPaymentProcessor;

  setUp(() {
    // Clear GetIt before each test
    GetIt.instance.reset();

    // Create mocks
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();
    mockTransactionService = MockTransactionService();
    mockPaymentProcessor = MockPaymentProcessor();

    // Register mocks with GetIt
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);
    GetIt.instance.registerSingleton<TransactionService>(
      mockTransactionService,
    );
    GetIt.instance.registerSingleton<PaymentProcessor>(mockPaymentProcessor);

    // Create viewModel
    viewModel = LoyaltyViewModel();
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('initialize', () {
    test('should fetch balance and transactions successfully', () async {
      // Arrange
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
        () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': 100.0, 'full_name': 'Jane Doe'});
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      // Act
      await viewModel.initialize();

      // Assert
      expect(viewModel.userBalance, 100.0);
      expect(viewModel.userName, 'Jane Doe');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);

      // Verify interactions
      verify(() => mockAuthService.getCurrentUserId).called(1);
      verify(() => mockProfileService.getUserBalanceById('user123')).called(1);
      verify(() => mockTransactionService.getTransactionsForUser()).called(2);
    });

    test('should handle profile service error gracefully', () async {
      // Arrange
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
        () => mockProfileService.getUserBalanceById('user123'),
      ).thenThrow(Exception('Network error'));
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      // Act
      await viewModel.initialize();

      // Assert
      expect(viewModel.errorMessage, 'Failed to fetch balance');
      expect(viewModel.isLoading, false);
    });

    test('initialize should handle null userId', () async {
      // Arrange
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);
      when(() => mockTransactionService.getTransactionsForUser())
          .thenAnswer((_) async => []);

      // Act
      await viewModel.initialize();

      // Assert
      expect(viewModel.errorMessage, 'User not known');
      expect(viewModel.isLoading, false);

      verifyNever(() => mockProfileService.getUserBalanceById(any()));
    });


    test('should default to 0.0 balance when null', () async {
      // Arrange
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
        () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': null, 'full_name': 'Jane Doe'});
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      // Act
      await viewModel.initialize();

      // Assert
      expect(viewModel.userBalance, 0.0);
      expect(viewModel.userName, 'Jane Doe');
    });

    test('should default to "John Doe" when name is null', () async {
      // Arrange
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
        () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': 100.0, 'full_name': null});
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      // Act
      await viewModel.initialize();

      // Assert
      expect(viewModel.userName, 'John Doe');
    });
  });

  group('toggleTransactionView', () {
    test('should toggle showPastTransactions from false to true', () async {
      // Arrange
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      expect(viewModel.showPastTransactions, false);

      // Act
      await viewModel.toggleTransactionView();

      // Assert
      expect(viewModel.showPastTransactions, true);
      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    test('should toggle showPastTransactions from true to false', () async {
      // Arrange
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      viewModel.showPastTransactions = true;

      // Act
      await viewModel.toggleTransactionView();

      // Assert
      expect(viewModel.showPastTransactions, false);
    });
  });

  group('fetchTransactions', () {
    test('should call transaction service', () async {
      // Arrange
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => []);

      // Act
      await viewModel.fetchTransactions();

      // Assert
      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    test('fetchTransactions filters out Rewards and old transactions', () async {
      // Arrange
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

      // Act
      await viewModel.toggleTransactionView();

      // Assert
      expect(viewModel.recentTransactions.length, 1);
    });


    test('fetchMonthlyRewards sums only recent reward transactions', () async {
      // Arrange
      final now = DateTime.now();
      when(() => mockTransactionService.getTransactionsForUser()).thenAnswer(
            (_) async => [
          {
            'created_at': now.toIso8601String(),
            'type': 'Rewards',
            'amount': 2.0,
          },
          {
            'created_at': now.toIso8601String(),
            'type': 'Rewards',
            'amount': 3.0,
          },
          {
            'created_at':
            now.subtract(const Duration(days: 40)).toIso8601String(),
            'type': 'Rewards',
            'amount': 10.0,
          },
        ],
      );

      // Act
      await viewModel.initialize();

      // Assert
      expect(viewModel.monthlyRewards, 5.0);
    });

  });

  group('loadCard', () {
    test('loadCard should update balance and fetch transactions on success', () async {
      // Arrange
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');

      viewModel.userBalance = 20.0;

      when(() => mockPaymentProcessor.processPayment(
        10.0,
        'Loyalty Card',
      )).thenAnswer((_) async => PaymentResult.success);

      when(() => mockPaymentProcessor.processRewards(10.0))
          .thenReturn(0.1);


      when(() => mockProfileService.updateBalanceById('user123', 30.1))
          .thenAnswer((_) async => Future.value());

      when(() => mockTransactionService.getTransactionsForUser())
          .thenAnswer((_) async => []);

      // Act
      final result = await viewModel.loadCard(10.0);

      // Assert
      expect(result, PaymentResult.success);
      expect(viewModel.userBalance, 30.1);

      verify(() => mockPaymentProcessor.processRewards(10.0)).called(1);
      verify(() => mockProfileService.updateBalanceById('user123', 30.1)).called(1);
      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    test('loadCard should not update balance on failed payment', () async {
      // Arrange
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');

      viewModel.userBalance = 20.0;

      when(() => mockPaymentProcessor.processPayment(
        10.0,
        'Loyalty Card',
      )).thenAnswer((_) async => PaymentResult.failed);

      // Act
      final result = await viewModel.loadCard(10.0);

      // Assert
      expect(result, PaymentResult.failed);
      expect(viewModel.userBalance, 20.0);

      verifyNever(() => mockProfileService.updateBalanceById(any(), any()));
    });


  });
}
