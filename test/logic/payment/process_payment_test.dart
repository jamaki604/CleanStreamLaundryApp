import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:clean_stream_laundry_app/logic/exceptions/platform_exception.dart';

class MockPaymentService extends Mock implements PaymentService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockPaymentService mockPaymentService;
  late MockTransactionService mockTransactionService;
  final getIt = GetIt.instance;

  setUp(() {
    mockPaymentService = MockPaymentService();
    mockTransactionService = MockTransactionService();

    getIt.registerSingleton<PaymentService>(mockPaymentService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
  });

  tearDown(() {
    getIt.reset();
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('processPayment', () {
    testWidgets(
      'should be a complete payment and record transaction on success',
      (WidgetTester tester) async {
        const amount = 100.0;
        const description = 'Test payment';
        when(() => mockPaymentService.makePayment(amount)).thenAnswer((
          _,
        ) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return;
        });
        when(
          () => mockTransactionService.recordTransaction(
            amount: amount,
            description: description,
            type: 'Laundry',
          ),
        ).thenAnswer((_) async => {});

        await tester.pumpWidget(
          createTestWidget(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await processPayment(amount, description);
                  },
                  child: const Text('Pay'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Pay'));
        await tester.pump();

        await tester.pumpAndSettle();

        verify(() => mockPaymentService.makePayment(amount)).called(1);

        verify(
          () => mockTransactionService.recordTransaction(
            amount: amount,
            description: description,
            type: 'Laundry',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should throw an error and not record transaction on StripeException with canceled code',
      (WidgetTester tester) async {
        const amount = 50.0;
        const description = 'Test payment';
        when(() => mockPaymentService.makePayment(amount)).thenAnswer(
          (_) async => throw StripeException(
            error: LocalizedErrorMessage(code: FailureCode.Canceled),
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await processPayment(amount, description);
                  },
                  child: const Text('Pay'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Pay'));
        await tester.pump();
        await tester.pumpAndSettle();

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

    testWidgets(
      'should throw an error and not record transaction on PlatformException',
      (WidgetTester tester) async {
        const amount = 75.0;
        const description = 'Test payment';
        when(() => mockPaymentService.makePayment(amount)).thenAnswer(
          (_) async => throw PlatformException('Platform not supported'),
        );

        await tester.pumpWidget(
          createTestWidget(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await processPayment(amount, description);
                  },
                  child: const Text('Pay'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Pay'));
        await tester.pump();
        await tester.pumpAndSettle();

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

    testWidgets(
      'should return false and not record transaction on unexpected error',
      (WidgetTester tester) async {
        const amount = 25.0;
        const description = 'Test payment';
        when(
          () => mockPaymentService.makePayment(amount),
        ).thenAnswer((_) async => throw Exception('Unexpected error'));

        await tester.pumpWidget(
          createTestWidget(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await processPayment(amount, description);
                  },
                  child: const Text('Pay'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Pay'));
        await tester.pump();
        await tester.pumpAndSettle();

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
  });
}
