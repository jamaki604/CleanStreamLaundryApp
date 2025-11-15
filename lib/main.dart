import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Pages/root_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'Logic/Theme/theme_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load env and initialize services with guarded logging so startup
  // exceptions are visible in logs (helps diagnose crashes on boot).
  try {
    await dotenv.load(fileName: '.env');
  } catch (e, st) {
    // Use print so the message appears in the device log / flutter run output
    print('ERROR: dotenv.load failed: $e');
    print(st);
  }

  try {
    await _setupStripe();
  } catch (e, st) {
    print('ERROR: _setupStripe failed: $e');
    print(st);
  }

  try {
    await _setupSupabase();
  } catch (e, st) {
    print('ERROR: _setupSupabase failed: $e');
    print(st);
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}

Future<void> _setupStripe() async {
  Stripe.publishableKey = "${dotenv.env['STRIPE_PUBLISHABLE_KEY']}";
}

Future<void> _setupSupabase() async {
  Supabase.initialize(
    url: '${dotenv.env['SUPABASE_URL']}',
    anonKey: '${dotenv.env['ANON_KEY']}',
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
