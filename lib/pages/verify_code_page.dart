import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../logic/services/auth_service.dart';
import '../logic/theme/theme.dart';

class CodeVerificationPage extends StatefulWidget {
  final String email;

  const CodeVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  final authService = GetIt.instance<AuthService>();

  bool _isLoading = false;
  String? _error;

  void _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() {
        _error = 'Please enter the 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await authService.verifyCode(
        email: widget.email,
        code: code,
      );

      if (!mounted) return;

      if (response == AuthenticationResponses.success) {
        context.go('/reset-protected');
        return;
      } else {
        setState(() {
          _error = 'Invalid or expired code';
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Something went wrong. Try again';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.fontInverted,
        title: const Text('Verify Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// Title
            Text(
              'Enter Verification Code',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scheme.fontInverted,
              ),
            ),

            const SizedBox(height: 12),

            /// Subtitle
            Text(
              'We sent a 6-digit code to',
              style: TextStyle(color: scheme.fontInverted.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            /// Email
            Text(
              widget.email,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            /// Code Input
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(
                color: scheme.fontInverted,
                letterSpacing: 8, // 👈 nice spaced digits
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: _error ?? '6-digit code',
                labelStyle: TextStyle(
                  color: _error != null ? Colors.red : scheme.primary,
                ),
                counterText: '',
                prefixIcon: Icon(
                  Icons.lock,
                  color: _error != null ? Colors.red : scheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),

            const SizedBox(height: 32),

            /// Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Verify'),
              ),
            ),

            const SizedBox(height: 16),

            /// Error Message (optional extra under field)
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 16),

            /// Resend
            TextButton(
              onPressed: () async {
                // TODO: implement resend
              },
              child: Text(
                'Resend code',
                style: TextStyle(color: scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}