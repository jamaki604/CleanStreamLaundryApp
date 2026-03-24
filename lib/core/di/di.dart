import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

// services
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';

// implementations
import 'package:clean_stream_laundry_app/services/supabase/supabase_auth_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_edge_function_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_location_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_machine_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_profile_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_transaction_service.dart';
import 'package:clean_stream_laundry_app/services/stripe/stripe_service.dart';
import 'package:clean_stream_laundry_app/services/nayax/machine_communicator.dart';

// misc
import 'package:clean_stream_laundry_app/core/router/app_router.dart';
import 'package:clean_stream_laundry_app/services/notification_service.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['ANON_KEY']!,
  );

  final supabase = Supabase.instance.client;

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  getIt.registerLazySingleton<TransactionService>(
        () => SupabaseTransactionService(client: supabase),
  );

  getIt.registerLazySingleton<ProfileService>(
        () => SupabaseProfileService(client: supabase),
  );

  getIt.registerLazySingleton<MachineService>(
        () => SupabaseMachineService(client: supabase),
  );

  getIt.registerLazySingleton<LocationService>(
        () => SupabaseLocationHandler(client: supabase),
  );

  getIt.registerLazySingleton<EdgeFunctionService>(
        () => SupabaseEdgeFunctionService(client: supabase),
  );

  getIt.registerLazySingleton<AuthService>(
        () => SupabaseAuthService(client: supabase),
  );

  getIt.registerLazySingleton<PaymentService>(() => StripeService());

  getIt.registerLazySingleton<Stripe>(() => Stripe.instance);

  getIt.registerLazySingleton<MachineCommunicationService>(
        () => MachineCommunicator(
      edgeFunctionService: getIt<EdgeFunctionService>(),
    ),
  );

  getIt.registerLazySingleton<RouterService>(() => RouterService());

  getIt.registerLazySingleton<NotificationService>(
        () => NotificationService(),
  );

  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin(),
  );

  getIt.registerLazySingleton<PaymentProcessor>(
        () => PaymentProcessor(),
  );

  getIt.registerLazySingleton<GoRouter>(() {
    final authService = getIt<AuthService>();
    final routerService = getIt<RouterService>();

    return routerService.createRouter(authService);
  });
}