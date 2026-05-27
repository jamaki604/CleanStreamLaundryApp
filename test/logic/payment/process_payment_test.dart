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
      const amount = 100.0;
      const description = 'Test payment';

      when(
        () => mockPaymentService.makePayment(
          amount,
          purpose: PaymentPurpose.directMachinePayment,
        ),
      ).thenAnswer((_) async => PaymentResult.success);
      when(
        () => mockTransactionService.recordTransaction(
          amount: any(named: 'amount'),
          description: any(named: 'description'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => {});

      // Act
      final result = await paymentProcessor.processPayment(amount, description);

      // Assert
      expect(result, PaymentResult.success);
      verify(
        () => mockPaymentService.makePayment(
          amount,
          purpose: PaymentPurpose.directMachinePayment,
        ),
      ).called(1);
      verify(
        () => mockTransactionService.recordTransaction(
          amount: amount,
          description: description,
          type: 'Laundry',
        ),
      ).called(1);
    });

    test(
      'should return canceled and not record transaction on StripeException with canceled code',
      () async {
        // Arrange
        const amount = 50.0;
        const description = 'Test payment';

        when(
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.directMachinePayment,
          ),
        ).thenThrow(
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
        verify(
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.directMachinePayment,
          ),
        ).called(1);
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
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.directMachinePayment,
          ),
        ).thenThrow(PlatformException('Platform not supported'));

        // Act
        final result = await paymentProcessor.processPayment(
          amount,
          description,
        );

        // Assert
        expect(result, PaymentResult.failed);
        verify(
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.directMachinePayment,
          ),
        ).called(1);
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
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.directMachinePayment,
          ),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await paymentProcessor.processPayment(
          amount,
          description,
        );

        // Assert
        expect(result, PaymentResult.failed);
        verify(
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.directMachinePayment,
          ),
        ).called(1);
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

      when(
        () => mockPaymentService.makePayment(
          amount,
          purpose: PaymentPurpose.directMachinePayment,
        ),
      ).thenThrow(
        StripeException(error: LocalizedErrorMessage(code: FailureCode.Failed)),
      );

      // Act
      final result = await paymentProcessor.processPayment(amount, description);

      // Assert
      expect(result, PaymentResult.canceled);
      verify(
        () => mockPaymentService.makePayment(
          amount,
          purpose: PaymentPurpose.directMachinePayment,
        ),
      ).called(1);
      verifyNever(
        () => mockTransactionService.recordTransaction(
          amount: any(named: 'amount'),
          description: any(named: 'description'),
          type: any(named: 'type'),
        ),
      );
    });

    test(
      'should not record a legacy transaction for wallet load success',
      () async {
        const amount = 40.0;
        const description = 'Loyalty Card';

        when(
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.walletLoad,
          ),
        ).thenAnswer((_) async => PaymentResult.success);

        final result = await paymentProcessor.processPayment(
          amount,
          description,
        );

        expect(result, PaymentResult.success);
        verify(
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.walletLoad,
          ),
        ).called(1);
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
      'should return pending and not record transaction while processing',
      () async {
        const amount = 40.0;
        const description = 'Loyalty Card';

        when(
          () => mockPaymentService.makePayment(
            amount,
            purpose: PaymentPurpose.walletLoad,
          ),
        ).thenAnswer((_) async => PaymentResult.pending);

        final result = await paymentProcessor.processPayment(
          amount,
          description,
        );

        expect(result, PaymentResult.pending);
        verifyNever(
          () => mockTransactionService.recordTransaction(
            amount: any(named: 'amount'),
            description: any(named: 'description'),
            type: any(named: 'type'),
          ),
        );
      },
    );
  });
}
