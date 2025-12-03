import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/location_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/machine_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/payment_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/profile_service.dart';
import 'package:clean_stream_laundry_app/Middleware/app_router.dart';
import 'package:clean_stream_laundry_app/Services/Nayax/machine_communicator.dart';
import 'package:clean_stream_laundry_app/Services/Stripe/stripe_service.dart';
import 'package:clean_stream_laundry_app/Services/supabase/supabase_auth_service.dart';
import 'package:clean_stream_laundry_app/Services/supabase/supabase_edge_function_service.dart';
import 'package:clean_stream_laundry_app/Services/supabase/supabase_location_service.dart';
import 'package:clean_stream_laundry_app/Services/supabase/supabase_machine_service.dart';
import 'package:clean_stream_laundry_app/Services/supabase/supabase_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Pages/root_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';
import 'Logic/Theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:clean_stream_laundry_app/Services/Supabase/supabase_transaction_service.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await setupDependencies();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}                                              


Future<void> setupDependencies() async{
  await Supabase.initialize(url: '${dotenv.env['SUPABASE_URL']}', anonKey: '${dotenv.env['ANON_KEY']}');
  final supabase = Supabase.instance.client;

  Stripe.publishableKey = "${dotenv.env['STRIPE_PUBLISHABLE_KEY']}";

  getIt.registerLazySingleton<TransactionService>(
      () => SupabaseTransactionService(client: supabase)
  );

  getIt.registerLazySingleton<ProfileService>(
          () => SupabaseProfileService(client: supabase)
  );

  getIt.registerLazySingleton<MachineService>(
          () => SupabaseMachineService(client: supabase)
  );

  getIt.registerLazySingleton<LocationService>(
          () => SupabaseLocationHandler(client: supabase)
  );

  getIt.registerLazySingleton<EdgeFunctionService>(
          () => SupabaseEdgeFunctionService(client: supabase)
  );

  getIt.registerLazySingleton<AuthService>(
          () => SupabaseAuthService(client: supabase)
  );

  getIt.registerLazySingleton<PaymentService>(
      () => StripeService()
  );

  getIt.registerLazySingleton<Stripe>(
      () => Stripe.instance
  );

  getIt.registerLazySingleton<MachineCommunicationService>(
      () => MachineCommunicator()
  );

  getIt.registerLazySingleton<RouterService>(
      () => RouterService()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeManager.themeData,
      home: RootApp(theme: themeManager.themeData),
    );
  }
}