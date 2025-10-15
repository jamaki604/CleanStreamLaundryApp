import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:clean_stream_laundry_app/Middleware/Authenticator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _passwordConfirmCtrl = TextEditingController();

  final Authenticator _auth = Authenticator();
  bool _isLoading = false;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _passwordConfirmCtrl.text;

    // Local validation first
    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _auth.signUp(email, password);
      if (success) {
        _showMessage('Account created successfully.');
        context.go('/scanner');
      } else {
        _showMessage('Sign-up failed. Try again.');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      currentIndex: 1,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _passwordConfirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                    child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Account'),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
