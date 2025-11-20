import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';

import '../../Logic/Services/edge_function_service.dart';

class StripeService implements PaymentService {
  late final _stripeInstance;
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();

  StripeService({required Stripe instance}){
    _stripeInstance = instance;
  }

  Future<int> makePayment(double amount) async {
    print("StripeService is not supported on this platform.");
    return 403;
  }

  @override
  Future<String> getTransactionResult(String sessionId) async {
    final session = await edgeFunctionService.runEdgeFunction(
        name: "checkPaymentResult", body: {"session_id":sessionId}
    );

    return session?.data["status"];
  }
}
