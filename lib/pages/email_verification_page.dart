import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late final StreamSubscription? _linkSub;
  final AppLinks _appLinks = AppLinks();
  final authService = GetIt.instance<AuthService>();

  bool _isOldEmailStep = true;
  bool _resent = false;
  Widget _resendWidget = const Text(
    'Resend Verification',
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
  );

  @override
  void initState() {
    super.initState();

    // authService.onAuthChange.listen((isLoggedIn) {
    //   if (isLoggedIn && authService.isEmailVerified()) {
    //     context.go("/homePage");
    //   }
    // });

    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri == null) return;

      if (uri.scheme == 'clean-stream' &&
          (uri.host == 'email-verification' ||
              uri.host == 'email-verification')) {
        try {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go("/homePage");
          });
        } catch (e) {
          print("Deep link handling error: $e");
        }
      }
    });

    _isOldEmailStep = !authService.isEmailVerified();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _resendVerification() async {
    if (_resent) return;

    final result = await authService.resendVerification();
    if (!mounted) return;

    setState(() {
      if (result == AuthenticationResponses.success) {
        _resendWidget = Icon(Icons.check_circle, size: 40, color: Colors.green);
        _resent = true;
      } else {
        _resendWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.close, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please try resending the verification again later.',
              textAlign: TextAlign.center,
            ),
          ],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepMessage = _isOldEmailStep
        ? 'Check your email inbox and click the verification link to finish signing up.'
        : 'Check your new email inbox and click the verification link to finalize your email change.';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go("/login"),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                'Email Verification Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.fontInverted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                stepMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.fontSecondary,
                ),
              ),
              const SizedBox(height: 24),
              InkWell(onTap: _resendVerification, child: _resendWidget),
            ],
          ),
        ),
      ),
    );
  }
}
