import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginLinks extends StatelessWidget {
  const LoginLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: InkWell(
            onTap: () => context.go('/signup'),
            child: const Text(
              'Create Account',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: InkWell(
            onTap: () => context.go('/password-reset'),
            child: const Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}