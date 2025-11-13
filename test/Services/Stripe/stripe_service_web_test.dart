import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/Services/Stripe/stripe_service_web.dart';
import 'package:clean_stream_laundry_app/main.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mocks.dart';

void main() {
  late StripeMock stripeMock;
  late EdgeFunctionMock edgeFunctionMock;
  late StripeService stripeService;

  setUpAll(() {
    registerFallbackValue(SetupPaymentSheetParametersFake());
  });

  setUp(() {
    getIt.reset();

    edgeFunctionMock = EdgeFunctionMock();
    getIt.registerLazySingleton<EdgeFunctionService>(() => edgeFunctionMock);

    stripeMock = StripeMock();
    stripeService = StripeService(instance: stripeMock);

  });

  group("Stripe test for web", () {

    test("Will return 400 if no client secret is found", () async {

      when(() => stripeMock.initPaymentSheet(
        paymentSheetParameters: any(named: "paymentSheetParameters"),
      )).thenAnswer((_) async => null);

      when(() => edgeFunctionMock.runEdgeFunction(name: any(named:"name"), body: any(named:"body")))
          .thenAnswer((_) async => null);

      when(() => stripeMock.presentPaymentSheet())
          .thenAnswer((_) async => null);

      final result = await stripeService.makePayment(2.60);

      expect(result, 400);

    });

    test("Will return 401 if Stripe exception is thrown", () async {

      when(() => stripeMock.initPaymentSheet(
        paymentSheetParameters: any(named: "paymentSheetParameters"),
      )).thenThrow(StripeException(error: LocalizedErrorMessage(code: FailureCode.Unknown)));

      when(() => edgeFunctionMock.runEdgeFunction(name: any(named:"name"), body: any(named:"body")))
          .thenAnswer((_) async => FunctionResponse(status: 200,data: {"clientSecret": "testSecret"}));

      when(() => stripeMock.presentPaymentSheet())
          .thenAnswer((_) async => null);

      final result = await stripeService.makePayment(2.60);

      expect(result, 401);
    });

    test("Will return 400 if any other exception is thrown", () async {

      when(() => stripeMock.initPaymentSheet(
        paymentSheetParameters: any(named: "paymentSheetParameters"),
      )).thenThrow(StripeException(error: LocalizedErrorMessage(code: FailureCode.Unknown)));

      when(() => edgeFunctionMock.runEdgeFunction(name: any(named:"name"), body: any(named:"body")))
          .thenAnswer((_) async => FunctionResponse(status: 200,data: {"clientSecret": "testSecret"}));

      when(() => stripeMock.presentPaymentSheet())
          .thenAnswer((_) async => null);

      final result = await stripeService.makePayment(2.60);

      expect(result, 401);
    });

  });
}
