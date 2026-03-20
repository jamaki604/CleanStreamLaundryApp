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
import 'package:clean_stream_laundry_app/services/kisi/door_unlocker.dart';

class MockAuthService extends Mock implements AuthService {}

class MockProfileService extends Mock implements ProfileService {}

class MockEdgeFunctionService extends Mock implements EdgeFunctionService {}

