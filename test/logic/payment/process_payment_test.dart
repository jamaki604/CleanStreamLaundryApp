import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:clean_stream_laundry_app/logic/exceptions/platform_exception.dart';

class MockPaymentService extends Mock implements PaymentService {}

class MockTransactionService extends Mock implements TransactionService {}

void main() {
  late MockPaymentService mockPaymentService;
  late MockTransactionService mockTransactionService;
  late PaymentProcessor paymentProcessor;

  setUp(() {
    mockPaymentService = MockPaymentService();
    mockTransactionService = MockTransactionService();
    paymentProcessor = PaymentProcessor();
  });

  group('PaymentProcessor.processPayment', () {
    test('should complete payment and record transaction on success', () async {
      // Arrange
      const amount = 100.0;
      const description = 'Test payment';

      when(
        () => mockPaymentService.makePayment(amount),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockTransactionService.recordTransaction(
          amount: amount,
          description: description,
          type: 'Laundry',
        ),
      ).thenAnswer((_) async => {});

      // Act
      final result = await paymentProcessor.processPayment(amount, description);

      // Assert
      expect(result, PaymentResult.success);
      verify(() => mockPaymentService.makePayment(amount)).called(1);
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
}
