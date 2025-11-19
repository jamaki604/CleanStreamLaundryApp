import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/Services/Stripe/stripe_service_stub.dart';
import 'package:clean_stream_laundry_app/main.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mocks.dart';

void main() {

  StripeService stripeService = StripeService(instance: StripeMock());

  group("Stripe test", () {

    test("Test that it returns the correct message",() async{
      final result = await stripeService.makePayment(27.50);
      expect(result, 403);
    });

  });
}
