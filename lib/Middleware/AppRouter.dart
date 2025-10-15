import 'package:flutter/cupertino.dart';
import 'package:clean_stream_laundry_app/Pages/LogInScreen.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void navigateTo(int index) {
    switch (index) {
      case 0:
        navigatorKey.currentState?.pushReplacementNamed('/home');
        break;
      case 1:
        navigatorKey.currentState?.pushReplacementNamed('/settings');
    }
  }

  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginScreen(),
    //'/home': (context) => const HomePage(),
    //'/settings': (context) => const SettingsPage(),
  };
}