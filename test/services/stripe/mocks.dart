import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mocktail/mocktail.dart';

class MockEdgeFunctionService extends Mock implements EdgeFunctionService {}
class MockStripe extends Mock implements Stripe {}
class FakeSetupPaymentSheetParameters extends Fake implements SetupPaymentSheetParameters {}