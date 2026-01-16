import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';

class MockAuthService extends Mock implements AuthService {}

class MockProfileService extends Mock implements ProfileService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockPaymentProcessor extends Mock implements PaymentProcessor {}
