import 'package:clean_stream_laundry_app/Components/base_page.dart';
import 'package:clean_stream_laundry_app/Logic/Enums/authentication_response_enum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../Logic/Services/auth_service.dart';
import '../Logic/Theme/theme.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authService = GetIt.instance<AuthService>();

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (await authService.isLoggedIn() == AuthenticationResponses.success){
                  context.go("/homePage");
                }else{
                  context.go("/login");
                }
              },
              child: const Text("Go to Home"),
            ),
          ],
        ),
      ),
    );
  }
}