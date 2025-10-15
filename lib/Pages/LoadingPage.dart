import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:clean_stream_laundry_app/Middleware/AppRouter.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoadingPage extends StatefulWidget {
  final Uri authRedirectUri;

  const LoadingPage({Key? key, required this.authRedirectUri}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final _supabase = Supabase.instance.client;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleAuthRedirect();
  }

  Future<void> _handleAuthRedirect() async {
    try {
      // Exchange the auth code for a session
      await _supabase.auth.exchangeCodeForSession(widget.authRedirectUri.toString());
      // Hand off to route controller
      AppRouter.navigateTo(2);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      currentIndex: 4,
      body: Center(
        child: _error != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text('Authentication failed', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AppRouter.navigateTo(3),
              child: const Text('Return to Login'),
            )
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('Authenticating...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
