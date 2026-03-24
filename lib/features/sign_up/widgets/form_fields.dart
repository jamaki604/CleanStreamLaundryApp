import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  final String passwordLabel;
  final String confirmLabel;
  final Color iconColor;
  final Color labelColor;

  final bool obscurePassword;
  final bool obscureConfirmPassword;

  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmChanged;

  const SignUpFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.passwordLabel,
    required this.confirmLabel,
    required this.iconColor,
    required this.labelColor,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onPasswordChanged,
    required this.onConfirmChanged,
  });

  InputDecoration _baseDecoration(BuildContext context) {
    return InputDecoration(
      contentPadding:
      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = _baseDecoration(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          inputFormatters: [LengthLimitingTextInputFormatter(36)],
          maxLength: 36,
          style: TextStyle(color: colorScheme.fontInverted),
          decoration: base.copyWith(
            labelText: 'Name',
            labelStyle: const TextStyle(color: Colors.blue),
            prefixIcon: const Icon(Icons.person, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: emailController,
          style: TextStyle(color: colorScheme.fontInverted),
          decoration: base.copyWith(
            labelText: 'Email',
            labelStyle: const TextStyle(color: Colors.blue),
            prefixIcon: const Icon(Icons.email, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          onChanged: onPasswordChanged,
          style: TextStyle(color: colorScheme.fontInverted),
          decoration: base.copyWith(
            labelText: passwordLabel,
            labelStyle: TextStyle(color: labelColor),
            prefixIcon: Icon(Icons.lock, color: iconColor),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.blue,
              ),
              onPressed: onTogglePassword,
            ),
          ),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: confirmController,
          obscureText: obscureConfirmPassword,
          onChanged: onConfirmChanged,
          style: TextStyle(color: colorScheme.fontInverted),
          decoration: base.copyWith(
            labelText: confirmLabel,
            labelStyle: TextStyle(color: labelColor),
            prefixIcon: Icon(Icons.lock, color: iconColor),
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.blue,
              ),
              onPressed: onToggleConfirm,
            ),
          ),
        ),
      ],
    );
  }
}