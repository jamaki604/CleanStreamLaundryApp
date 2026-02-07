import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:clean_stream_laundry_app/logic/exceptions/platform_exception.dart';
import 'package:get_it/get_it.dart';

class MockPaymentService extends Mock implements PaymentService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockAuthService extends Mock implements AuthService {}

class MockProfileService extends Mock implements ProfileService {}

void main() {
  late MockPaymentService mockPaymentService;
  late MockTransactionService mockTransactionService;
  late PaymentProcessor paymentProcessor;
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;

  setUp(() {
    mockPaymentService = MockPaymentService();
    mockTransactionService = MockTransactionService();
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<PaymentService>(mockPaymentService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<ProfileService>(mockProfileService);

    paymentProcessor = PaymentProcessor();

  });

  group('PaymentProcessor.processPayment', () {
    test('should complete payment and record transaction on success', () async {
      // Arrange
      const amount = 100.0;
      const description = 'Test payment';
      const userId = 'test-user-id';
      const currentBalance = 50.0;

      when(() => mockPaymentService.makePayment(amount))
          .thenAnswer((_) async => Future.value());
      when(() => mockTransactionService.recordTransaction(
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        type: any(named: 'type'),
      )).thenAnswer((_) async => {});
      when(() => mockAuthService.getCurrentUserId).thenReturn(userId);
      when(() => mockProfileService.getUserBalanceById(userId))
          .thenAnswer((_) async => {'balance': currentBalance});
      when(() => mockProfileService.updateBalanceById(any(), any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await paymentProcessor.processPayment(amount, description);

      // Assert
      expect(result, PaymentResult.success);
      verify(() => mockPaymentService.makePayment(amount)).called(1);
      verify(() => mockTransactionService.recordTransaction(
        amount: amount,
        description: description,
        type: 'Laundry',
      )).called(1);
      verify(() => mockTransactionService.recordTransaction(
        amount: 1.0, // 1% of 100
        description: "Reward from payment",
        type: "Rewards",
      )).called(1);
      verify(() => mockProfileService.updateBalanceById(userId, 51.0)).called(1);
    });

    test(
      'should return canceled and not record transaction on StripeException with canceled code',
      () async {
        // Arrange
        const amount = 50.0;
        const description = 'Test payment';

        when(() => mockPaymentService.makePayment(amount)).thenThrow(
          StripeException(
            error: LocalizedErrorMessage(code: FailureCode.Canceled),
          ),
        );

        // Act
        final result = await paymentProcessor.processPayment(
          amount,
          description,
        );

        // Assert
        expect(result, PaymentResult.canceled);
        verify(() => mockPaymentService.makePayment(amount)).called(1);
        verifyNever(
          () => mockTransactionService.recordTransaction(
            amount: any(named: 'amount'),
            description: any(named: 'description'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    test(
      'should return failed and not record transaction on PlatformException',
      () async {
        // Arrange
        const amount = 75.0;
        const description = 'Test payment';

        when(
          () => mockPaymentService.makePayment(amount),
        ).thenThrow(PlatformException('Platform not supported'));

        // Act
        final result = await paymentProcessor.processPayment(
          amount,
          description,
        );

        // Assert
        expect(result, PaymentResult.failed);
        verify(() => mockPaymentService.makePayment(amount)).called(1);
        verifyNever(
          () => mockTransactionService.recordTransaction(
            amount: any(named: 'amount'),
            description: any(named: 'description'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    test(
      'should return failed and not record transaction on unexpected error',
      () async {
        // Arrange
        const amount = 25.0;
        const description = 'Test payment';

        when(
          () => mockPaymentService.makePayment(amount),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await paymentProcessor.processPayment(
          amount,
          description,
        );

        // Assert
        expect(result, PaymentResult.failed);
        verify(() => mockPaymentService.makePayment(amount)).called(1);
        verifyNever(
          () => mockTransactionService.recordTransaction(
            amount: any(named: 'amount'),
            description: any(named: 'description'),
            type: any(named: 'type'),
          ),
        );
      },
    );

    test('should handle any StripeException as canceled', () async {
      // Arrange
      const amount = 60.0;
      const description = 'Test payment';

      when(() => mockPaymentService.makePayment(amount)).thenThrow(
        StripeException(error: LocalizedErrorMessage(code: FailureCode.Failed)),
      );

      // Act
      final result = await paymentProcessor.processPayment(amount, description);

      // Assert
      expect(result, PaymentResult.canceled);
      verify(() => mockPaymentService.makePayment(amount)).called(1);
      verifyNever(
        () => mockTransactionService.recordTransaction(
          amount: any(named: 'amount'),
          description: any(named: 'description'),
          type: any(named: 'type'),
        ),
      );
    });
  });

  group('PaymentProcessor.processRewards', () {
    test('should calculate 1% reward and update balance', () async {
      // Arrange
      const amount = 100.0;
      const userId = 'test-user-id';
      const currentBalance = 50.0;
      const expectedReward = 1.0;
      const expectedNewBalance = 51.0;

      when(() => mockAuthService.getCurrentUserId).thenReturn(userId);
      when(() => mockProfileService.getUserBalanceById(userId))
          .thenAnswer((_) async => {'balance': currentBalance});
      when(() => mockTransactionService.recordTransaction(
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        type: any(named: 'type'),
      )).thenAnswer((_) async => {});
      when(() => mockProfileService.updateBalanceById(userId, any()))
          .thenAnswer((_) async => {});

      // Act
      paymentProcessor.processRewards(amount);
      await Future.delayed(Duration.zero); // Allow async to complete

      // Assert
      verify(() => mockAuthService.getCurrentUserId).called(1);
      verify(() => mockProfileService.getUserBalanceById(userId)).called(1);
      verify(() => mockTransactionService.recordTransaction(
        amount: expectedReward,
        description: "Reward from payment",
        type: "Rewards",
      )).called(1);
      verify(() => mockProfileService.updateBalanceById(
        userId,
        expectedNewBalance,
      )).called(1);
    });

    test('should calculate correct reward for different amounts', () async {
      // Arrange
      const amount = 250.0;
      const userId = 'test-user-id';
      const currentBalance = 100.0;
      const expectedReward = 2.5;
      const expectedNewBalance = 102.5;

      when(() => mockAuthService.getCurrentUserId).thenReturn(userId);
      when(() => mockProfileService.getUserBalanceById(userId))
          .thenAnswer((_) async => {'balance': currentBalance});
      when(() => mockTransactionService.recordTransaction(
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        type: any(named: 'type'),
      )).thenAnswer((_) async => {});
      when(() => mockProfileService.updateBalanceById(userId, any()))
          .thenAnswer((_) async => {});

      // Act
      paymentProcessor.processRewards(amount);
      await Future.delayed(Duration.zero);

      // Assert
      verify(() => mockTransactionService.recordTransaction(
        amount: expectedReward,
        description: "Reward from payment",
        type: "Rewards",
      )).called(1);
      verify(() => mockProfileService.updateBalanceById(
        userId,
        expectedNewBalance,
      )).called(1);
    });

    test('should handle zero current balance', () async {
      // Arrange
      const amount = 50.0;
      const userId = 'test-user-id';
      const currentBalance = 0.0;
      const expectedReward = 0.5;
      const expectedNewBalance = 0.5;

      when(() => mockAuthService.getCurrentUserId).thenReturn(userId);
      when(() => mockProfileService.getUserBalanceById(userId))
          .thenAnswer((_) async => {'balance': currentBalance});
      when(() => mockTransactionService.recordTransaction(
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        type: any(named: 'type'),
      )).thenAnswer((_) async => {});
      when(() => mockProfileService.updateBalanceById(userId, any()))
          .thenAnswer((_) async => {});

      // Act
      paymentProcessor.processRewards(amount);
      await Future.delayed(Duration.zero);

      // Assert
      verify(() => mockProfileService.updateBalanceById(
        userId,
        expectedNewBalance,
      )).called(1);
    });

    test('should handle small payment amounts', () async {
      // Arrange
      const amount = 1.0;
      const userId = 'test-user-id';
      const currentBalance = 10.0;
      const expectedReward = 0.01;
      const expectedNewBalance = 10.01;

      when(() => mockAuthService.getCurrentUserId).thenReturn(userId);
      when(() => mockProfileService.getUserBalanceById(userId))
          .thenAnswer((_) async => {'balance': currentBalance});
      when(() => mockTransactionService.recordTransaction(
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        type: any(named: 'type'),
      )).thenAnswer((_) async => {});
      when(() => mockProfileService.updateBalanceById(userId, any()))
          .thenAnswer((_) async => {});

      // Act
      paymentProcessor.processRewards(amount);
      await Future.delayed(Duration.zero);

      // Assert
      verify(() => mockTransactionService.recordTransaction(
        amount: expectedReward,
        description: "Reward from payment",
        type: "Rewards",
      )).called(1);
      verify(() => mockProfileService.updateBalanceById(
        userId,
        expectedNewBalance,
      )).called(1);
    });
  });
}
