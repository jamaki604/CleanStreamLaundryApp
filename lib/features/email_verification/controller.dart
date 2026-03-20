import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class EmailVerificationController {
  final AuthService _authService = GetIt.instance<AuthService>();
  final AppLinks appLinks;
  final BuildContext context;

  StreamSubscription? _authSub;
  StreamSubscription? _linkSub;

  bool resent = false;
  bool isLoading = false;
  AuthenticationResponses? lastResponse;

  EmailVerificationController({
    required this.appLinks,
    required this.context,
  });

  void init() {
    _authSub = _authService.onAuthChange.listen((isLoggedIn) {
      if (isLoggedIn && _authService.isEmailVerified()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/homePage');
        });
      }
    });

    _linkSub = appLinks.uriLinkStream.listen(_handleUri);
  }

  void dispose() {
    _authSub?.cancel();
    _linkSub?.cancel();
  }

  Future<void> _handleUri(Uri? uri) async {
    if (uri != null &&
        uri.scheme == 'clean-stream' &&
        uri.host == 'email-verification') {
      await _authService.getSessionFromURI(uri);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/homePage');
      });
    }
  }

  Future<void> resendVerification() async {
    if (resent) return;

    isLoading = true;
    lastResponse = await _authService.resendVerification();
    isLoading = false;

    if (lastResponse == AuthenticationResponses.success) {
      resent = true;
    }
  }
}