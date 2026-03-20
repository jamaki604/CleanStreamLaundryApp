import 'package:app_links/app_links.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class LoadingPageController extends ChangeNotifier {
  final AuthService authService = GetIt.instance<AuthService>();

  String? error;

  Future<void> init(BuildContext context) async {
    await Future.wait([
      _automaticLogIn(context),
      _coldStartRedirect(context),
    ]);
  }

  Future<void> _automaticLogIn(BuildContext context) async {
    await Future.delayed(Duration.zero);

    try {
      if (await authService.isLoggedIn() == AuthenticationResponses.success) {
        if (!context.mounted) return;
        context.go('/homePage');
      } else {
        if (!context.mounted) return;
        context.go('/login');
      }
    } catch (e) {
      if (!context.mounted) return;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _coldStartRedirect(BuildContext context) async {
    try {
      final AppLinks appLinks = AppLinks();
      final Uri? initialUri = await appLinks.getInitialAppLink();

      if (initialUri == null) return;

      if (initialUri.scheme == 'clean-stream' &&
          initialUri.host == 'reset-protected') {
        if (!context.mounted) return;
        context.go('/reset-protected', extra: initialUri);
        return;
      }

      if (initialUri.scheme == 'clean-stream' &&
          initialUri.host == 'email-verification') {
        if (!context.mounted) return;
        context.go('/homePage');
        return;
      }

      if (initialUri.host == 'change-email') {
        if (!context.mounted) return;
        context.go('/email-verification');
        return;
      }

      if (initialUri.scheme == 'clean-stream' &&
          initialUri.host == 'oauth') {
        await authService.getSessionFromURI(initialUri);
        if (!context.mounted) return;
        if (await authService.isLoggedIn() == AuthenticationResponses.success) {
          context.go('/homePage');
        } else {
          context.go('/login');
        }
      }
    } catch (e) {
      // cold start redirect failures are silent — _automaticLogIn covers nav
    }
  }

  void disposeController() {}
}