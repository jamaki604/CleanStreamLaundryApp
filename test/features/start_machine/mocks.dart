import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/services/kisi/door_unlocker.dart';
import 'package:mocktail/mocktail.dart';

class MockDoorUnlocker extends Mock implements DoorUnlocker {}
class MockProfileService extends Mock implements ProfileService {}
class MockAuthService extends Mock implements AuthService {}