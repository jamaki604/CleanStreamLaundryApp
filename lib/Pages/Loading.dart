import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';

class LoadingPage extends StatefulWidget {
  final Uri authRedirectUri;
  final AuthSystem auth;

  const LoadingPage({Key? key, required this.authRedirectUri, required this.auth}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final _supabase = Supabase.instance.client;
  String? _error;

  double begin = 0.95;
  double end = 1.05;

  @override
  void initState() {
    super.initState();
    _automaticLogIn();
    //_handleAuthRedirect();
  }

  Future<void> _handleAuthRedirect() async {
    try {
      await _supabase.auth.exchangeCodeForSession(widget.authRedirectUri.toString());
      context.go("/scanner");
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _automaticLogIn() async {
    await Future.delayed(Duration.zero);

    try {
      if (await widget.auth.isLoggedIn()) {
        if (!mounted) return;
        context.go("/scanner");
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
                color: Colors.redAccent.withOpacity(0.8),
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