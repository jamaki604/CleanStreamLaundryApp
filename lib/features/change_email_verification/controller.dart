import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';

class ChangeEmailVerificationController {
  final AuthService _authService = GetIt.instance<AuthService>();
  final AppLinks appLinks;
  final BuildContext context;

  StreamSubscription? _linkSub;

  bool resent = false;
  bool isLoading = false;
  AuthenticationResponses? lastResponse;

  ChangeEmailVerificationController({
    required this.appLinks,
    required this.context,
  });

  void init() {
    _linkSub = appLinks.uriLinkStream.listen(_handleUri);
  }

  void dispose() {
    _linkSub?.cancel();
  }

  /// Handles deeplink from email
  Future<void> _handleUri(Uri? uri) async {
    if (uri != null &&
        uri.scheme == 'clean-stream' &&
        uri.host == 'change-email') {
      await _authService.refreshSession();
      await _authService.getCurrentUser();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/editProfile');
        }
      });
    }
  }

  /// Resends verification email
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