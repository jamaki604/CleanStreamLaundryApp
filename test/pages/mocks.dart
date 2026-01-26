import 'dart:async';

import 'package:app_links/app_links.dart';
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
import 'package:clean_stream_laundry_app/services/notification_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';

class MockAuthService extends Mock implements AuthService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockLocationService extends Mock implements LocationService {}

class MockMachineService extends Mock implements MachineService {}

class MockThemeManager extends Mock implements ThemeManager {}

class MockProfileService extends Mock implements ProfileService {}

class MockRouterService extends Mock implements RouterService {}

class MockLoyaltyViewModel extends Mock implements LoyaltyViewModel {}

class MockPaymentProcessor extends Mock implements PaymentProcessor {}

class MockMachineCommunicationService extends Mock
    implements MachineCommunicationService {}

class FakeAuthService extends Fake implements AuthService {}

class MockEdgeFunctionService extends Mock implements EdgeFunctionService {}

class MockNotificationService extends Mock implements NotificationService {}

class FakeUri extends Fake implements Uri {}

class FakeAppLinks extends Fake implements AppLinks {
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  /// Helper to emit a deep link in tests
  void emit(Uri uri) {
    _controller.add(uri);
  }

  void dispose() {
    _controller.close();
  }
}
