import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:app_links/app_links.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});


  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  String? _error;
  double begin = 0.95;
  double end = 1.05;

  final authService = GetIt.instance<AuthService>();

  @override
  void initState() {
    super.initState();
    _automaticLogIn();
    _coldStartRedirect();
  }


  Future<void>_coldStartRedirect() async {
    try {
      final AppLinks appLinks = AppLinks();
      final Uri? initialUri = await appLinks.getInitialAppLink();
      if (initialUri == null) return;

      if (initialUri.scheme == 'clean-stream' && initialUri.host == 'email-verification') {
        context.go("/homePage");
      }else if (initialUri.scheme == 'clean-stream' && initialUri.host == 'oauth') {
        await authService.handleOAuthRedirect(initialUri);
        if (await authService.isLoggedIn() == AuthenticationResponses.success) {
          if (!mounted) return;
          context.go("/homePage");
        } else {
          if (!mounted) return;
          context.go("/login");
        }
      }
    } catch (e) {

    }
  }

  void _automaticLogIn() async {
    await Future.delayed(Duration.zero);

    try {
      if (await authService.isLoggedIn() == AuthenticationResponses.success) {
        if (!mounted) return;
        context.go("/homePage");
      } else {
        if (!mounted) return;
        context.go("/login");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _error != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            Text(
              'Authentication Failed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.redAccent.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            ElevatedButton.icon(
              onPressed: () => context.go("/login"),
              icon: const Icon(Icons.login),
              label: const Text('Return to Login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        )
            : TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: begin, end: end),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Image.asset(
            "assets/Logo.png",
            height: 250,
          ),
          onEnd: () {
            setState(() {
              double temp = begin;
              begin = end;
              end = temp;
            });
          },
        ),
      );
   }
}