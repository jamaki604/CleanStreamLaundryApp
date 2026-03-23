import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'root_app.dart';
import 'core/di/di.dart';
import 'logic/theme/theme_manager.dart';

late final GoRouter pageRouter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  final router = getIt<GoRouter>();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: RootApp(
        router: router,
      ),
    ),
  );
}