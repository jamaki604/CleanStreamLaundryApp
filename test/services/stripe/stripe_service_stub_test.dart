import 'package:clean_stream_laundry_app/logic/exceptions/platform_exception.dart';
import 'package:clean_stream_laundry_app/services/stripe/stripe_service_stub.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {

  StripeService stripeService = StripeService();

  group("stripe test", () {

    test("Test that it throws correct error",() async{
      expectLater(
            () => stripeService.makePayment(10.0),
        throwsA(isA<PlatformException>()),
      );
    });

  });
}
