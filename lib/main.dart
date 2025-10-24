import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Pages/RootApp.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  print('${dotenv.env['SUPABASE_URL']}');

  await _setupStripe();

  await Supabase.initialize(
    url: '${dotenv.env['SUPABASE_URL']}',
    anonKey: '${dotenv.env['ANON_KEY']}'
  );
  runApp(const RootApp());
}

Future<void> _setupStripe() async {
  Stripe.publishableKey = "${dotenv.env['STRIPE_PUBLISHABLE_KEY']}";
}
