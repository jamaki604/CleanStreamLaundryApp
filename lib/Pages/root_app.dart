import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:clean_stream_laundry_app/Middleware/app_router.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

class RootApp extends StatefulWidget {
  final ThemeData theme;
  const RootApp({super.key, required this.theme});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  late final AuthService _authenticator = GetIt.instance<AuthService>();

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