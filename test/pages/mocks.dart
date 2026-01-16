import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/middleware/app_router.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';

class MockAuthService extends Mock implements AuthService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockLocationService extends Mock implements LocationService {}

class MockMachineService extends Mock implements MachineService {}

class MockThemeManager extends Mock implements ThemeManager {}

class MockProfileService extends Mock implements ProfileService {}

class MockRouterService extends Mock implements RouterService {}

class MockMachineCommunicationService extends Mock
    implements MachineCommunicationService {}

class FakeAuthService extends Fake implements AuthService {}

class MockEdgeFunctionService extends Mock implements EdgeFunctionService {}

class MockPaymentProcessor extends Mock implements PaymentProcessor {}

class MockLoyaltyViewModel extends Mock implements LoyaltyViewModel {}
