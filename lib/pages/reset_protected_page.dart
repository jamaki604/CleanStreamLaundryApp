import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';

class ResetProtectedPage extends StatefulWidget {
  final Uri? incomingUri;
  const ResetProtectedPage({this.incomingUri, super.key});

  @override
  State<ResetProtectedPage> createState() => _ResetProtectedPageState();
}

class _ResetProtectedPageState extends State<ResetProtectedPage> {
  final edgeService = GetIt.instance<EdgeFunctionService>();

  String? token;
  bool loading = true;
  bool valid = false;
  String? lastReceivedUri;
  Map<String, String>? lastParams;
  final _pwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

    // Common token param names: access_token, token, oobCode
    token = params['access_token'] ?? params['token'] ?? params['oobCode'];

    if (token == null) {
      setState(() {
        loading = false;
        valid = false;

        // store raw values for on-screen debugging
        lastReceivedUri = effective.toString();
        lastParams = params;
      });
      return;
    }

    // Validate token via edge function (you should implement an edge function '/complete-reset')
    try {
      final resp = await edgeService.runEdgeFunction(
        name: 'validate-reset-token',
        body: {'token': token},
      );
      if (resp != null && resp.status == 200) {
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
    if (!_formKey.currentState!.validate() || token == null) return;
    setState(() => loading = true);

    final resp = await edgeService.runEdgeFunction(
      name: 'complete-reset',
      body: {'token': token, 'password': _pwController.text.trim()},
    );

    setState(() => loading = false);

    if (resp != null && resp.status == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful')),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } else {
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
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('Set a New Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _pwController,
                obscureText: true,
                style: TextStyle(color: scheme.fontInverted),
                decoration: InputDecoration(
                  labelText: 'New password',
                  labelStyle: TextStyle(color: scheme.fontSecondary),
                  filled: true,
                  fillColor: scheme.cardPrimary,
                  border: const OutlineInputBorder(),
                ),
                validator: _validatePw,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Set Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
