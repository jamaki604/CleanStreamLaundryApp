import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/Authenticator.dart';
import 'package:clean_stream_laundry_app/Middleware/AppRouter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Middleware/AppRouter.dart';

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  final AuthSystem _authenticator = Authenticator(Supabase.instance.client);
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Clean Stream Laundry Solutions',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: createRouter(_authenticator),
    );
  }
}
