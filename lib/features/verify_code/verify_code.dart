import 'controller.dart';
import 'widgets/code_field.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CodeVerificationPage extends StatefulWidget {
  final String email;

  const CodeVerificationPage({super.key, required this.email});

  @override
  State<CodeVerificationPage> createState() =>
      _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  late final CodeVerificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeVerificationController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.disposeController();
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onVerifyPressed() async {
    final result = await _controller.verifyCode(widget.email);
    if (!mounted) return;

    if (result == VerifyResult.success) {
      context.go('/reset-protected');
    }
  }

  Future<void> _onResendPressed() async {
    final result = await _controller.sendResetEmail(widget.email);
    if (!mounted) return;

    switch (result) {
      case ResendResult.success:
        _showMessage('Password reset email sent! Check your email.');
        break;
      case ResendResult.failed:
        _showMessage('Failed to send reset email.');
        break;
      case ResendResult.error:
        _showMessage('Error sending reset email.');
        break;
    }
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
            Text(
              'Enter Verification Code',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scheme.fontInverted,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a 6-digit code to',
              style: TextStyle(
                  color: scheme.fontInverted.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              widget.email,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            VerificationCodeField(
              controller: _controller.codeController,
              error: _controller.error,
              onChanged: (_) => _controller.clearError(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                _controller.isLoading ? null : _onVerifyPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _controller.isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2),
                )
                    : const Text('Verify'),
              ),
            ),
            const SizedBox(height: 16),
            if (_controller.error != null)
              Text(
                _controller.error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _onResendPressed,
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