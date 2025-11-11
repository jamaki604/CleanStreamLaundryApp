import 'dart:async';

import 'package:clean_stream_laundry_app/Logic/Supabase/authentication_response.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import '../Logic/Theme/theme.dart';

class EmailVerificationPage extends StatefulWidget {
  late final AuthSystem _auth;

  EmailVerificationPage({super.key,required AuthSystem auth}){
    _auth = auth;
  }

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late final StreamSubscription? _authSubscription;
  late final StreamSubscription? _linkSub;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();

    //Checks for if application has been updated
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final User? user = event.session?.user;

      if(user != null){
        if(user.id == widget._auth.currentUserId) {
          if (user.emailConfirmedAt != null) {
            context.go("/scanner");
          }
        }
      }
    });

    // Handles app links
    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'clean-stream' && uri.host == 'email-verification') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/scanner');
          }
        });
      }});
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _linkSub?.cancel();
    super.dispose();
  }

  Widget resendVerification = const Text(
      'Resend Verification',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      )
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
                'Please verify your email address',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18,
                  color: Theme.of(context).colorScheme.fontPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                'Check your inbox and click the verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.fontSecondary),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  if(resent == false) {

                    final result = await widget._auth.resendVerification();

                    setState(() {
                      if(result == AuthenticationResponses.success) {
                        resendVerification = Icon(Icons.check_circle, size: 40,
                            color: Colors.green);
                        resent = true;
                      }else{
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
                                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.fontPrimary),
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