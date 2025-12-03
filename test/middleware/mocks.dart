import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/middleware/storage_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:mocktail/mocktail.dart';

class StorageServiceMock extends Mock implements StorageService{}
class MockAuthService extends Mock implements AuthService {}
class MockTransactionService extends Mock implements TransactionService {}
class MockLocationService extends Mock implements LocationService {}
class MockMachineService extends Mock implements MachineService {}
class MockProfileService extends Mock implements ProfileService {}
class MockMachineCommunicationService extends Mock implements MachineCommunicationService {}
class FakeAuthService extends Fake implements AuthService {}
class MockEdgeFunctionService extends Mock implements EdgeFunctionService {}
class MockThemeManager extends Mock implements ThemeManager {}