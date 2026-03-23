import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/middleware/app_router.dart';

class MockAuthService extends Mock implements AuthService {}
class MockRouterService extends Mock implements RouterService {}