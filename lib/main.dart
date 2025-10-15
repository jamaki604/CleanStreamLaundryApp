import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Pages/RootApp.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  /*
  await Supabase.initialize(
    url: 'SUPABASE_URL',
    amonKey: 'AMON_KEY'
  );
  */

  runApp(const RootApp());
}
