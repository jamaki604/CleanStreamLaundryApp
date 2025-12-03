import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/location_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/machine_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/profile_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:clean_stream_laundry_app/Middleware/app_router.dart';
import 'package:clean_stream_laundry_app/Logic/Theme/theme_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/Logic/Services/machine_communication_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockLocationService extends Mock implements LocationService {}

class MockMachineService extends Mock implements MachineService {}

class MockThemeManager extends Mock implements ThemeManager {}

class MockProfileService extends Mock implements ProfileService {}

class MockRouterService extends Mock implements RouterService {}

class MockMachineCommunicationService extends Mock implements MachineCommunicationService {}

class FakeAuthService extends Fake implements AuthService {}
