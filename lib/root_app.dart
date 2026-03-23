import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RootApp extends StatelessWidget {
  final GoRouter router;

  const RootApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().themeData;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Clean Stream Laundry Solutions',
      theme: theme,
      routerConfig: router,
    );
  }
}