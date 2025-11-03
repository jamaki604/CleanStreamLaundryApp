import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Logic/Theme/Theme.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.fontPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/scanner'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}