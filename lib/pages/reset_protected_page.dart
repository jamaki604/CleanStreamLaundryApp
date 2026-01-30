import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';

class ResetProtectedPage extends StatefulWidget {
  final Uri? incomingUri;
  const ResetProtectedPage({this.incomingUri, super.key});

  @override
  State<ResetProtectedPage> createState() => _ResetProtectedPageState();
}

class _ResetProtectedPageState extends State<ResetProtectedPage> {
  final SupabaseClient _client = Supabase.instance.client;

  String? code;
  bool loading = true;
  bool valid = false;
  String? lastReceivedUri;
  Map<String, String>? lastParams;
  final _pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  var iconColor = Colors.blue;
  var enabledBorderColor = Colors.grey;
  var focusedBorderColor = Colors.blue;
  var labelColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _initFromUri(widget.incomingUri);
  }

  Future<void> _initFromUri(Uri? uri) async {
    setState(() {
      loading = true;
      valid = false;
    });

    Uri effective = uri ?? Uri.base;

    // log for debugging
    print('reset-protected received uri: $effective');

    // Accept cases where path contains reset-protected (some redirects use path instead of host)
    final isResetUri =
        (effective.scheme == 'clean-stream' &&
        (effective.host == 'reset-protected' ||
            effective.path.contains('reset-protected')));

    if (!isResetUri) {
      setState(() {
        loading = false;
        valid = false;
      });
      return;
    }

    // Merge query parameters and fragment parameters (Supabase may use fragment)
    final Map<String, String> queryParams = effective.queryParameters;
    final Map<String, String> fragmentParams = effective.fragment.isNotEmpty
        ? Uri.splitQueryString(effective.fragment)
        : {};

    final params = {...queryParams, ...fragmentParams};

    // Common code param names: code, oobCode
    code = params['code'] ?? params['oobCode'];

    if (code == null) {
      setState(() {
        loading = false;
        valid = false;

        // store raw values for on-screen debugging
        lastReceivedUri = effective.toString();
        lastParams = params;
      });
      return;
    }

    try {
      final response = await _client.auth.exchangeCodeForSession(code!);
      if (response.session?.user != null) {
        setState(() {
          valid = true;
          loading = false;
        });
      } else {
        setState(() {
          valid = false;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        valid = false;
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || code == null) return;
    setState(() => loading = true);

    try {
      await _client.auth.updateUser(
        UserAttributes(password: _pwController.text.trim()),
      );
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful')),
        );
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reset password')),
        );
      }
    }
  }

  String? _validatePw(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (loading) {
      return Scaffold(
        backgroundColor: scheme.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              if (lastReceivedUri != null)
                Text(
                  'Received: $lastReceivedUri',
                  style: TextStyle(color: scheme.fontSecondary),
                ),
            ],
          ),
        ),
      );
    }

    if (!valid) {
      return Scaffold(
        backgroundColor: scheme.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_reset,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Invalid or expired reset link',
                style: TextStyle(color: scheme.fontPrimary),
              ),
              const SizedBox(height: 8),
              if (lastReceivedUri != null)
                Text(
                  'Received: $lastReceivedUri',
                  style: TextStyle(color: scheme.fontSecondary),
                ),
              if (lastParams != null) ...[
                const SizedBox(height: 8),
                Text('Params:', style: TextStyle(color: scheme.fontSecondary)),
                for (final e in lastParams!.entries)
                  Text(
                    '${e.key}: ${e.value}',
                    style: TextStyle(color: scheme.fontSecondary),
                  ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.lock_reset,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              Text(
                'Set a new password',
                style:
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.fontPrimary,
                    ) ??
                    TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scheme.fontPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter a new password for your account.',
                style:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.fontSecondary,
                    ) ??
                    TextStyle(color: scheme.fontSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _pwController,
                obscureText: true,
                style: TextStyle(color: scheme.fontInverted),
                decoration: InputDecoration(
                  labelText: 'New password',
                  labelStyle: TextStyle(color: labelColor),
                  filled: true,
                  fillColor: scheme.cardPrimary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: enabledBorderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock, color: iconColor),
                ),
                validator: _validatePw,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Set Password'),
              ),
              TextButton(
                onPressed: loading ? null : () => context.go('/login'),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
