import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'mocks.dart';

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
  });

  group('loadCard', () {
    // Note: This test is incomplete because processPayment is a top-level function
    // See options below for how to handle this
    test(
      'should update balance and fetch transactions on successful payment',
      () async {
        // You'll need to refactor processPayment to be testable
        // See suggestions below
      },
    );
  });
}
