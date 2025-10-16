import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Pages/RootApp.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  await dotenv.load(fileName: '.env');
  print('${dotenv.env['SUPABASE_URL']}');
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '${dotenv.env['SUPABASE_URL']}',
    anonKey: '${dotenv.env['ANON_KEY']}'
  );


  runApp(const RootApp());
}
