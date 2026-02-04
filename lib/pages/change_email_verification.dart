import 'dart:async';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';

class ChangeEmailVerificationPage extends StatefulWidget {

  final AppLinks appLinks;

  const ChangeEmailVerificationPage({super.key,required this.appLinks});

  @override
  State<ChangeEmailVerificationPage> createState() =>
      _ChangeEmailVerificationPageState();
}

class _ChangeEmailVerificationPageState
    extends State<ChangeEmailVerificationPage> {
  late final StreamSubscription? _linkSub;
  final authService = GetIt.instance<AuthService>();

  @override
  void initState() {
    super.initState();

    _linkSub = widget.appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null &&
          uri.scheme == 'clean-stream' &&
          uri.host == 'change-email') {
        await authService.refreshSession();
        await authService.getCurrentUser();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/homePage');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Widget resendVerification = const Text(
    'Resend Verification',
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
  );

  bool resent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                'Please verify your new email address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.fontInverted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Check your new email\'s inbox and click the verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.fontSecondary,
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  if (resent == false) {
                    final result = await authService.resendVerification();

                    setState(() {
                      if (result == AuthenticationResponses.success) {
                        resendVerification = Icon(
                          Icons.check_circle,
                          size: 40,
                          color: Colors.green,
                        );
                        resent = true;
                      } else {
                        resendVerification = Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Please resend verification again at another time.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.fontPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    });
                  }
                },
                child: resendVerification,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
