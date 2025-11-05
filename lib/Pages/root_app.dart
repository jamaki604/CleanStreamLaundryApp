import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/Authenticator.dart';
import 'package:clean_stream_laundry_app/Middleware/AppRouter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class RootApp extends StatefulWidget {
  final ThemeData theme;
  const RootApp({super.key, required this.theme});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  late final AuthSystem _authenticator;

  @override
  void initState() {
    super.initState();
    _authenticator = Authenticator(Supabase.instance.client);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Clean Stream Laundry Solutions',
      theme: widget.theme,
      routerConfig: createRouter(_authenticator),
    );
  }
}