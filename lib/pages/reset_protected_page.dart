import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/parsing/password_parser.dart';
import 'package:get_it/get_it.dart';

class ResetProtectedPage extends StatefulWidget {
  final Uri? incomingUri;
  const ResetProtectedPage({this.incomingUri, super.key});

  @override
  State<ResetProtectedPage> createState() => _ResetProtectedPageState();
}

class _ResetProtectedPageState extends State<ResetProtectedPage> {
  final authService = GetIt.instance<AuthService>();

  String? code;
  bool loading = true;
  bool valid = false;
  String? lastReceivedUri;
  Map<String, String>? lastParams;

  final _pwController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String passwordText = "New Password";
  String confirmPasswordText = "Confirm Password";
  Color iconColor = Colors.blue;
  Color labelColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _initFromUri(widget.incomingUri);
  }

  void _changeColorsToRed(String reason) {
    setState(() {
      passwordText = reason;
      confirmPasswordText = reason;
      iconColor = Colors.red;
      labelColor = Colors.red;
    });
  }

  void _changeColorsToDefault() {
    setState(() {
      passwordText = "New Password";
      confirmPasswordText = "Confirm Password";
      iconColor = Colors.blue;
      labelColor = Colors.blue;
    });
  }

  Future<void> _initFromUri(Uri? uri) async {
    setState(() {
      loading = true;
      valid = false;
    });

    Uri effective = uri ?? Uri.base;

    final isResetUri =
        (effective.scheme == 'clean-stream' &&
            (effective.host == 'reset-protected' ||
                effective.path.contains('reset-protected'))) ||
            effective.path == '/reset-protected' ||
            effective.path.contains('reset-protected');

    if (!isResetUri) {
      setState(() {
        loading = false;
        valid = false;
      });
      return;
    }

    final Map<String, String> queryParams = effective.queryParameters;

    final Map<String, String> fragmentParams =
    effective.fragment.isNotEmpty
        ? Uri.splitQueryString(effective.fragment)
        : <String, String>{};

    final Map<String, String> params = {
      ...queryParams,
      ...fragmentParams,
    };

    code = params['code'] ?? params['oobCode'];

    if (code == null) {
      setState(() {
        loading = false;
        valid = false;
        lastReceivedUri = effective.toString();
        lastParams = params;
      });
      return;
    }

    try {
      final response = await authService.exchangeCodeForSession(code!);
      setState(() {
        valid = response == AuthenticationResponses.success;
        loading = false;
      });
    } catch (_) {
      setState(() {
        valid = false;
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pwController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (code == null) return;

    final password = _pwController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _changeColorsToRed("Please fill all fields");
      return;
    }

    if (password != confirm) {
      _changeColorsToRed("Passwords don't match");
      return;
    }

    setState(() => loading = true);

    try {
      final response = await authService.updatePassword(password);
      setState(() => loading = false);

      if (!mounted) return;

      if (response == AuthenticationResponses.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful')),
        );
        context.go('/login');
      } else if (response == AuthenticationResponses.noDigit) {
        _changeColorsToRed('Please include a digit');
      } else if (response ==
          AuthenticationResponses.lessThanMinLength) {
        _changeColorsToRed("Password length is too short");
      } else if (response ==
          AuthenticationResponses.noSpecialCharacter) {
        _changeColorsToRed("Please include a special character");
      } else if (response ==
          AuthenticationResponses.noUppercase) {
        _changeColorsToRed("Please include an uppercase letter");
      } else if (response ==
          AuthenticationResponses.invalidSpecialCharacter) {
        _changeColorsToRed("Please use a different special character");
      } else {
        _changeColorsToRed("Failed to reset password");
      }
    } catch (_) {
      setState(() => loading = false);
      if (!mounted) return;
      _changeColorsToRed("Failed to reset password");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (loading) {
      return Scaffold(
        backgroundColor: scheme.surface,
        body: const Center(child: CircularProgressIndicator()),
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
                style: TextStyle(color: scheme.fontInverted),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.fontInverted,
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            /// Password Requirements (Same as Sign Up)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _pwController,
              builder: (context, value, _) {
                final requirementText =
                PasswordParser.process(value.text);

                if (requirementText == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        requirementText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            /// New Password
            TextField(
              controller: _pwController,
              obscureText: _obscurePassword,
              style: TextStyle(color: scheme.fontInverted),
              decoration: InputDecoration(
                labelText: passwordText,
                labelStyle: TextStyle(color: labelColor),
                prefixIcon: Icon(Icons.lock, color: iconColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: scheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) {
                if (iconColor == Colors.red) {
                  _changeColorsToDefault();
                }
              },
            ),

            const SizedBox(height: 16),

            /// Confirm Password
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              style: TextStyle(color: scheme.fontInverted),
              decoration: InputDecoration(
                labelText: confirmPasswordText,
                labelStyle: TextStyle(color: labelColor),
                prefixIcon: Icon(Icons.lock, color: iconColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: scheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) {
                if (_pwController.text.trim() !=
                    _confirmController.text.trim()) {
                  _changeColorsToRed("Passwords don't match");
                } else {
                  _changeColorsToDefault();
                }
              },
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Set Password'),
            ),
          ],
        ),
      ),
    );
  }
}