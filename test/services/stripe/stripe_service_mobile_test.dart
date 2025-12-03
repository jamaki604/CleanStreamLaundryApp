import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/services/stripe/stripe_service_mobile.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';
import 'mocks.dart';

void main() {
  late MockStripe mockStripe;
  late MockEdgeFunctionService mockEdgeFunctionService;
  late StripeService stripeService;
  final getIt = GetIt.instance;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Register fallback values
    registerFallbackValue(FakeSetupPaymentSheetParameters());
  });

  setUp(() {
    // Reset GetIt before each test
    getIt.reset();

    // Create mocks
    mockEdgeFunctionService = MockEdgeFunctionService();
    mockStripe = MockStripe();

    // Register mock in GetIt
    getIt.registerSingleton<EdgeFunctionService>(mockEdgeFunctionService);
    getIt.registerSingleton<Stripe>(mockStripe);

    // Create service instance
    stripeService = StripeService();
  });

  tearDown(() {
    getIt.reset();
  });

  group("StripeService Tests", () {
    group("makePayment", () {
      test("returns 400 when no client secret is found", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer((_) async => null);

        // Act
        final result = await stripeService.makePayment(2.60);

        // Assert
        expect(result, 400);
        verify(() => mockEdgeFunctionService.runEdgeFunction(
          name: 'paymentIntent',
          body: {'amount': '260', 'currency': 'usd'},
        )).called(1);
      });

      test("returns 200 when payment succeeds", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer(
              (_) async => FunctionResponse(
            status: 200,
            data: {"clientSecret": "testSecret"},
          ),
        );

        when(() => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: "paymentSheetParameters"),
        )).thenAnswer((_) async => null);

        when(() => mockStripe.presentPaymentSheet())
            .thenAnswer((_) async => null);

        // Act
        final result = await stripeService.makePayment(2.60);

        // Assert
        expect(result, 200);
        verify(() => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: "paymentSheetParameters"),
        )).called(1);
        verify(() => mockStripe.presentPaymentSheet()).called(1);
      });

      test("returns 401 when StripeException is thrown", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer(
              (_) async => FunctionResponse(
            status: 200,
            data: {"clientSecret": "testSecret"},
          ),
        );

        when(() => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: "paymentSheetParameters"),
        )).thenThrow(
          StripeException(
            error: LocalizedErrorMessage(code: FailureCode.Unknown),
          ),
        );

        // Act
        final result = await stripeService.makePayment(2.60);

        // Assert
        expect(result, 401);
      });

      test("returns 400 when generic exception is thrown", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer(
              (_) async => FunctionResponse(
            status: 200,
            data: {"clientSecret": "testSecret"},
          ),
        );

        when(() => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: "paymentSheetParameters"),
        )).thenThrow(Exception("Generic error"));

        // Act
        final result = await stripeService.makePayment(2.60);

        // Assert
        expect(result, 400);
      });

      test("returns 400 when presentPaymentSheet throws exception", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer(
              (_) async => FunctionResponse(
            status: 200,
            data: {"clientSecret": "testSecret"},
          ),
        );

        when(() => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: "paymentSheetParameters"),
        )).thenAnswer((_) async => null);

        when(() => mockStripe.presentPaymentSheet())
            .thenThrow(Exception("Payment sheet error"));

        // Act
        final result = await stripeService.makePayment(2.60);

        // Assert
        expect(result, 400);
      });
    });

    group("createPaymentIntent", () {
      test("returns client secret when successful", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer(
              (_) async => FunctionResponse(
            status: 200,
            data: {"clientSecret": "testSecret123"},
          ),
        );

        // Act
        final result = await stripeService.createPaymentIntent(25.70, "usd");

        // Assert
        expect(result, "testSecret123");
        verify(() => mockEdgeFunctionService.runEdgeFunction(
          name: 'paymentIntent',
          body: {'amount': '2570', 'currency': 'usd'},
        )).called(1);
      });

      test("returns null when response is null", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer((_) async => null);

        // Act
        final result = await stripeService.createPaymentIntent(25.70, "usd");

        // Assert
        expect(result, null);
      });

      test("returns null when response data is null", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer(
              (_) async => FunctionResponse(status: 200, data: null),
        );

        // Act
        final result = await stripeService.createPaymentIntent(25.70, "usd");

        // Assert
        expect(result, null);
      });

      test("returns null when clientSecret is not in response", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenAnswer(
              (_) async => FunctionResponse(
            status: 200,
            data: {"someOtherField": "value"},
          ),
        );

        // Act
        final result = await stripeService.createPaymentIntent(25.70, "usd");

        // Assert
        expect(result, null);
      });

      test("returns null when exception is thrown", () async {
        // Arrange
        when(() => mockEdgeFunctionService.runEdgeFunction(
          name: any(named: "name"),
          body: any(named: "body"),
        )).thenThrow(Exception("Network error"));

        // Act
        final result = await stripeService.createPaymentIntent(25.70, "usd");

        // Assert
        expect(result, null);
      });
    });

    group("convertDollarsToCents", () {
      test("converts dollars to cents correctly", () {
        expect(stripeService.convertDollarsToCents(2.75), "275");
      });

      test("handles zero amount", () {
        expect(stripeService.convertDollarsToCents(0), "0");
      });

      test("handles whole dollar amounts", () {
        expect(stripeService.convertDollarsToCents(10.00), "1000");
      });

      test("handles large amounts", () {
        expect(stripeService.convertDollarsToCents(1234.56), "123456");
      });

      test("handles small decimal amounts", () {
        expect(stripeService.convertDollarsToCents(0.01), "1");
      });

      test("rounds down fractional cents", () {
        expect(stripeService.convertDollarsToCents(1.999), "199");
      });
    });
  });
}