import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/services/stripe/stripe_service.dart';
import 'mocks.dart';

class MockTransactionService extends Mock implements TransactionService {}

class FakeFunctionResponse extends Fake implements FunctionResponse {
  final Map<String, dynamic> _data;
  FakeFunctionResponse(this._data);

  @override
  Map<String, dynamic> get data => _data;
}

void main() {
  late StripeService stripeService;
  late MockEdgeFunctionService mockEdgeFunctionService;
  late MockTransactionService mockTransactionService;
  late MockStripe mockStripe;
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();

    mockEdgeFunctionService = MockEdgeFunctionService();
    mockTransactionService = MockTransactionService();
    mockStripe = MockStripe();

    getIt.registerSingleton<EdgeFunctionService>(mockEdgeFunctionService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
    getIt.registerSingleton<Stripe>(mockStripe);

    stripeService = StripeService();
  });

  tearDown(() {
    getIt.reset();
  });

  group('StripeService - makePayment', () {
    test(
      'should return 400 when edge function returns null response',
      () async {
        when(
          () => mockTransactionService.subscribeForPaymentConfirmation(
            any(),
            any(),
          ),
        ).thenAnswer((_) async => {});

        when(
          () => mockEdgeFunctionService.runEdgeFunction(
            name: any(named: 'name'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => null);

        final result = await stripeService.makePayment(100.0);

        expect(result, 400);
      },
    );

    test('should return 400 when url is null in response', () async {
      when(
        () => mockTransactionService.subscribeForPaymentConfirmation(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      when(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => FakeFunctionResponse({'url': null}));

      final result = await stripeService.makePayment(100.0);

      expect(result, 400);
    });

    test('should return 400 when url is missing in response', () async {
      when(
        () => mockTransactionService.subscribeForPaymentConfirmation(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      when(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => FakeFunctionResponse({}));

      final result = await stripeService.makePayment(100.0);

      expect(result, 400);
    });

    test('should return 400 when edge function throws exception', () async {
      when(
        () => mockTransactionService.subscribeForPaymentConfirmation(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      when(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('Network error'));

      final result = await stripeService.makePayment(100.0);

      expect(result, 400);
    });

    test(
      'should return 400 when transaction service throws exception',
      () async {
        when(
          () => mockTransactionService.subscribeForPaymentConfirmation(
            any(),
            any(),
          ),
        ).thenThrow(Exception('Subscription error'));

        final result = await stripeService.makePayment(100.0);

        expect(result, 400);
      },
    );

    test('should handle multiple payment requests correctly', () async {
      when(
        () => mockTransactionService.subscribeForPaymentConfirmation(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      when(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => null);

      final result1 = await stripeService.makePayment(50.0);
      final result2 = await stripeService.makePayment(75.0);

      expect(result1, 400);
      expect(result2, 400);
      verify(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).called(2);
    });

    test('should handle zero amount', () async {
      when(
        () => mockTransactionService.subscribeForPaymentConfirmation(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => {});

      when(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => null);

      final result = await stripeService.makePayment(0.0);

      expect(result, 400);
      verify(
        () => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: 'name'),
          body: any(named: 'body'),
        ),
      ).called(1);
    });
  });
}
