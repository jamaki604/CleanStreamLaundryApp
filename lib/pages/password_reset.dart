import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  StreamSubscription? _linkSub;
  final AppLinks _appLinks = AppLinks();

  var iconColor = Colors.blue;
  var enabledBorderColor = Colors.grey;
  var focusedBorderColor = Colors.blue;
  var labelColor = Colors.blue;

  final authService = GetIt.instance<AuthService>();

  @override
  void dispose() {
    _emailController.dispose();
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null &&
          uri.scheme == 'clean-stream' &&
          uri.host == 'reset-protected') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/reset-protected', extra: uri);
          }
        });
      }
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await authService.resetPassword(
          _emailController.text.trim(),
        );

        setState(() {
          _isLoading = false;
        });

        if (response == AuthenticationResponses.success) {
          _showMessage(
            'Password reset email sent! Check your email for the link.',
          );
        } else {
          _showMessage('Failed to send reset email.');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Error: $e');
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
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
                'Forgot your password?',
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
                'Enter your email address and we\'ll send you a reset link.',
                style:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.fontSecondary,
                    ) ??
                    TextStyle(color: scheme.fontSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: scheme.fontInverted),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: labelColor),
                  hintText: 'Enter your email address',
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
                  filled: true,
                  fillColor: scheme.cardPrimary,
                  prefixIcon: Icon(Icons.email, color: iconColor),
                ),
                validator: _validateEmail,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendResetEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Send Reset Link'),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => context.pop(),
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
