import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/parsing/password_parser.dart';

import '../Logic/Theme/theme.dart';

class ResetProtectedPage extends StatefulWidget {
  const ResetProtectedPage({super.key});

  @override
  State<ResetProtectedPage> createState() => _ResetProtectedPageState();
}

class _ResetProtectedPageState extends State<ResetProtectedPage> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final authService = GetIt.instance<AuthService>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  var passwordText = "New Password";
  var confirmText = "Confirm Password";
  var iconColor = Colors.blue;
  var labelColor = Colors.blue;

  void _changeColorsToRed(String reason) {
    setState(() {
      passwordText = reason;
      confirmText = reason;
      iconColor = Colors.red;
      labelColor = Colors.red;
    });
  }

  void _resetColors() {
    setState(() {
      passwordText = "New Password";
      confirmText = "Confirm Password";
      iconColor = Colors.blue;
      labelColor = Colors.blue;
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _submit() async {
    final password = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    if (password != confirm) {
      _changeColorsToRed("Passwords don't match");
      return;
    }

    final requirementError = PasswordParser.process(password);
    if (requirementError != null) {
      _changeColorsToRed(requirementError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.updatePassword(password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful')),
      );

      context.go("/login");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reset password')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor),

      contentPadding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.fontSecondary,
        ),
        borderRadius: BorderRadius.circular(12),
      ),

      prefixIcon: Icon(icon, color: iconColor),

      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.blue,
        ),
        onPressed: toggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    "Reset Password",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Enter your new password below",
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  /// Password requirements (same style as signup)
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _passwordCtrl,
                    builder: (context, value, _) {
                      final requirement = PasswordParser.process(value.text);

                      if (requirement == null) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          requirement,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),

                  /// Password field
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      label: passwordText,
                      icon: Icons.lock,
                      obscure: _obscurePassword,
                      toggle: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    onChanged: (_) {
                      if (iconColor == Colors.red) _resetColors();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm field
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: _inputDecoration(
                      label: confirmText,
                      icon: Icons.lock,
                      obscure: _obscureConfirm,
                      toggle: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                    onChanged: (_) {
                      if (_passwordCtrl.text != _confirmCtrl.text) {
                        _changeColorsToRed("Passwords don't match");
                      } else {
                        _resetColors();
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Reset Password",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}