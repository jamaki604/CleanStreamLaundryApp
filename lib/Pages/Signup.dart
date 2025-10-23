import 'package:clean_stream_laundry_app/Logic/Authentication/AuthenticationResponses.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/Authenticator.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _passwordConfirmCtrl = TextEditingController();
  var passwordText = "Password";
  var confirmPasswordText = "Confirm Password";
  var iconColor = Colors.blue;
  var enabledBorderColor = Colors.grey;
  var focusedBorderColor = Colors.blue;
  var borderColor = Colors.blue;
  var labelColor = Colors.blue;

  final AuthSystem _auth = Authenticator(Supabase.instance.client);
  bool _isLoading = false;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)));
  }

  void _changeColorsToRed(){
    setState(() {
      passwordText = "Passwords do not match";
      confirmPasswordText = "Passwords do not match";
      iconColor = Colors.red;
      enabledBorderColor = Colors.red;
      focusedBorderColor = Colors.red;
      borderColor = Colors.red;
      labelColor = Colors.red;
    });
  }

  void _changeColorsToDefault(){
    setState(() {
      passwordText = "Password";
      confirmPasswordText = "Confirm Password";
      iconColor = Colors.blue;
      enabledBorderColor = Colors.grey;
      focusedBorderColor = Colors.blue;
      borderColor = Colors.blue;
      labelColor = Colors.blue;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _passwordConfirmCtrl.text;


    // Local validation first
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _auth.signUp( email, password);
      if (success == AuthenticationResponses.success) {
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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/Logo.png", height: 250, width: 250),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.blue), // matches button color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.blue), // matches button color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: passwordText,
                  labelStyle: TextStyle(color: labelColor), // matches button color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: enabledBorderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock, color: iconColor),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _passwordConfirmCtrl,
                decoration: InputDecoration(
                  labelText: confirmPasswordText,
                  labelStyle: TextStyle(color: labelColor), // matches button color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: enabledBorderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock, color: iconColor),
                ),
                obscureText: true,
                onChanged: (value){

                  if((_passwordCtrl.text.trim() != _passwordConfirmCtrl.text.trim())){
                    if(iconColor != Colors.red) {
                      _changeColorsToRed();
                    }
                  }else{
                    _changeColorsToDefault();
                  }

                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                    child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Account'),
                  style: ElevatedButton.styleFrom(backgroundColor:Colors.blue,foregroundColor:Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: InkWell(
                  onTap: () => context.go("/login"),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
