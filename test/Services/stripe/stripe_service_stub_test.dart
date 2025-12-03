import 'package:clean_stream_laundry_app/Services/stripe/stripe_service_stub.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks.dart';

void main() {

  StripeService stripeService = StripeService();

  group("stripe test", () {

    test("Test that it returns the correct message",() async{
      final result = await stripeService.makePayment(27.50);
      expect(result, 403);
    });

  });
}
