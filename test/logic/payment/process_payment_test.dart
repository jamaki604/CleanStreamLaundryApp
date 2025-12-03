import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/process_payment.dart';

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
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('processPayment', () {
    testWidgets('should show loading dialog and return true on successful payment (status 200)',
            (WidgetTester tester) async {
          const amount = 100.0;
          const description = 'Test payment';
          when(() => mockPaymentService.makePayment(amount))
              .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return 200;
          });
          when(() => mockTransactionService.recordTransaction(
            amount: amount,
            description: description,
            type: 'Laundry',
          )).thenAnswer((_) async => {});

          await tester.pumpWidget(
            createTestWidget(
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await processPayment(context, amount, description);
                    },
                    child: const Text('Pay'),
                  );
                },
              ),
            ),
          );

          await tester.tap(find.text('Pay'));
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          verify(() => mockPaymentService.makePayment(amount)).called(1);

          verify(() => mockTransactionService.recordTransaction(
            amount: amount,
            description: description,
            type: 'Laundry',
          )).called(1);

          expect(find.text('payment Successful!'), findsOneWidget);
          expect(find.text('Thank you! Your payment was processed successfully.'),
              findsOneWidget);
        });

    testWidgets('should return false and show error dialog when payment is canceled (status 401)',
            (WidgetTester tester) async {
          const amount = 50.0;
          const description = 'Test payment';
          when(() => mockPaymentService.makePayment(amount))
              .thenAnswer((_) async => 401);

          await tester.pumpWidget(
            createTestWidget(
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await processPayment(context, amount, description);
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
          verifyNever(() => mockTransactionService.recordTransaction(
            amount: any(named: 'amount'),
            description: any(named: 'description'),
            type: any(named: 'type'),
          ));

          expect(find.text('payment Failed!'), findsOneWidget);
          expect(find.text('The payment was canceled or declined.'), findsOneWidget);
        });

    testWidgets('should return false and show error dialog when stripe is unavailable (status 403)',
            (WidgetTester tester) async {
          const amount = 75.0;
          const description = 'Test payment';
          when(() => mockPaymentService.makePayment(amount))
              .thenAnswer((_) async => 403);

          await tester.pumpWidget(
            createTestWidget(
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await processPayment(context, amount, description);
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
          verifyNever(() => mockTransactionService.recordTransaction(
            amount: any(named: 'amount'),
            description: any(named: 'description'),
            type: any(named: 'type'),
          ));

          expect(find.text('payment Failed!'), findsOneWidget);
          expect(find.text('stripe service is not available on this platform.'),
              findsOneWidget);
        });

    testWidgets('should return false and show generic error dialog for unexpected status codes',
            (WidgetTester tester) async {
          const amount = 25.0;
          const description = 'Test payment';
          when(() => mockPaymentService.makePayment(amount))
              .thenAnswer((_) async => 500);

          await tester.pumpWidget(
            createTestWidget(
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await processPayment(context, amount, description);
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
          verifyNever(() => mockTransactionService.recordTransaction(
            amount: any(named: 'amount'),
            description: any(named: 'description'),
            type: any(named: 'type'),
          ));

          expect(find.text('payment Failed!'), findsOneWidget);
          expect(find.text('An unexpected error occurred.'), findsOneWidget);
        });

    testWidgets('should dismiss loading dialog before showing result dialog',
            (WidgetTester tester) async {
          const amount = 100.0;
          const description = 'Test payment';
          when(() => mockPaymentService.makePayment(amount))
              .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return 200;
          });
          when(() => mockTransactionService.recordTransaction(
            amount: amount,
            description: description,
            type: 'Laundry',
          )).thenAnswer((_) async => {});

          await tester.pumpWidget(
            createTestWidget(
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await processPayment(context, amount, description);
                    },
                    child: const Text('Pay'),
                  );
                },
              ),
            ),
          );

          await tester.tap(find.text('Pay'));
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          expect(find.byType(CircularProgressIndicator), findsNothing);

          expect(find.text('payment Successful!'), findsOneWidget);
        });
  });
}