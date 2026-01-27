import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/middleware/app_router.dart';
import 'package:clean_stream_laundry_app/services/nayax/machine_communicator.dart';
import 'package:clean_stream_laundry_app/services/stripe/stripe_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_auth_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_edge_function_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_location_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_machine_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';
import 'services/notification_service.dart';
import 'logic/theme/theme_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';

final getIt = GetIt.instance;

late final GoRouter pageRouter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await setupDependencies();
  final authService = getIt<AuthService>();
  final routerService = getIt<RouterService>();
  pageRouter = routerService.createRouter(authService);

  runApp(
    ChangeNotifierProvider(create: (_) => ThemeManager(), child: const MyApp()),
  );
}

Future<void> setupDependencies() async {
  await Supabase.initialize(
    url: '${dotenv.env['SUPABASE_URL']}',
    anonKey: '${dotenv.env['ANON_KEY']}',
  );
  final supabase = Supabase.instance.client;

  Stripe.publishableKey = "${dotenv.env['STRIPE_PUBLISHABLE_KEY']}";

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
    () => MachineCommunicator(),
  );

  getIt.registerLazySingleton<RouterService>(
      () => RouterService()
  );

  getIt.registerLazySingleton<NotificationService>(
      () => NotificationService());

  getIt.registerLazySingleton<LoyaltyViewModel>(() => LoyaltyViewModel());

  getIt.registerLazySingleton<PaymentProcessor>(() => PaymentProcessor(
        paymentService: getIt<PaymentService>(),
        transactionService: getIt<TransactionService>(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        return MaterialApp.router(
          routerConfig: pageRouter,
          theme: themeManager.themeData,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
