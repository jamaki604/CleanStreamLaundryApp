import 'package:app_links/app_links.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class LoadingPageController extends ChangeNotifier {
  final AuthService authService;
  final AppLinks appLinks;

  LoadingPageController({
    AuthService? authService,
    AppLinks? appLinks,
  })  : authService = authService ?? GetIt.instance<AuthService>(),
        appLinks = appLinks ?? AppLinks();

  String? error;

  Future<void> init({
    required void Function(String route, {Object? extra}) navigate,
    required ValueGetter<bool> isMounted,
  }) async {
    await Future.wait([
      _automaticLogIn(navigate: navigate, isMounted: isMounted),
      _coldStartRedirect(navigate: navigate, isMounted: isMounted),
    ]);
  }

  Future<void> _automaticLogIn({
    required void Function(String route, {Object? extra}) navigate,
    required ValueGetter<bool> isMounted,
  }) async {
    await Future.delayed(Duration.zero);

    try {
      final response = await authService.isLoggedIn();
      if (!isMounted()) return;

      if (response == AuthenticationResponses.success) {
        navigate('/homePage');
      } else {
        navigate('/login');
      }
    } catch (e) {
      if (!isMounted()) return;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _coldStartRedirect({
    required void Function(String route, {Object? extra}) navigate,
    required ValueGetter<bool> isMounted,
  }) async {
    try {
      final Uri? initialUri = await appLinks.getInitialAppLink();

      if (initialUri == null) return;

      if (initialUri.scheme == 'clean-stream' &&
          initialUri.host == 'reset-protected') {
        if (!isMounted()) return;
        navigate('/reset-protected', extra: initialUri);
        return;
      }

      if (initialUri.scheme == 'clean-stream' &&
          initialUri.host == 'email-verification') {
        if (!isMounted()) return;
        navigate('/homePage');
        return;
      }

      if (initialUri.host == 'change-email') {
        if (!isMounted()) return;
        navigate('/email-verification');
        return;
      }

      if (initialUri.scheme == 'clean-stream' && initialUri.host == 'oauth') {
        await authService.getSessionFromURI(initialUri);
        if (!isMounted()) return;
        if (await authService.isLoggedIn() == AuthenticationResponses.success) {
          navigate('/homePage');
        } else {
          navigate('/login');
        }
      }
    } catch (_) {
      // cold-start failures are silent — same as original
    }
  }

  void disposeController() {}
}