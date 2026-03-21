import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackToHome extends StatelessWidget {
  const BackToHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/homePage'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Back to Home',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}