import 'package:clean_stream_laundry_app/Services/Supabase/supabase_edge_function_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class StripeMock extends Mock implements Stripe{}
class EdgeFunctionMock extends Mock implements SupabaseEdgeFunctionService{}
class SetupPaymentSheetParametersFake extends Fake implements SetupPaymentSheetParameters {}
class FunctionsClientMock extends Mock implements FunctionsClient{}