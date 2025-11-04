import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Pages/RootApp.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'Logic/Theme/ThemeManager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  print('${dotenv.env['SUPABASE_URL']}');

  await _setupStripe();

  await Supabase.initialize(
    url: '${dotenv.env['SUPABASE_URL']}',
    anonKey: '${dotenv.env['ANON_KEY']}'
  );
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