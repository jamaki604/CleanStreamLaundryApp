import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/services/wallet_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:clean_stream_laundry_app/features/loyalty/controller.dart';

class MockAuthService extends Mock implements AuthService {}

class MockProfileService extends Mock implements ProfileService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockWalletService extends Mock implements WalletService {}

class MockPaymentProcessor extends Mock implements PaymentProcessor {}

class MockLoyaltyController extends Mock implements LoyaltyController {}
