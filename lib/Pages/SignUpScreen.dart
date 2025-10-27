import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthenticationResponses.dart';

class SignUpScreen extends StatefulWidget {
  late final AuthSystem _auth;

  SignUpScreen({super.key,required AuthSystem auth}){
    this._auth = auth;
  }

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
  bool _isLoading = false;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)));
  }

  void _changeColorsToRed(String reason){
    setState(() {
      passwordText = reason;
      confirmPasswordText = reason;
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
      final authResponse = await widget._auth.signUp( email, password);
      if (authResponse == AuthenticationResponses.success) {
        _showMessage('Account created successfully.');
        context.go('/email-Verification');
      }else if(authResponse == AuthenticationResponses.noDigit){
        _changeColorsToRed('Please include a digit');
      }else if(authResponse == AuthenticationResponses.lessThanMinLength){
        _changeColorsToRed("Password length is too short");
      }else if(authResponse == AuthenticationResponses.noSpecialCharacter){
        _changeColorsToRed("Please include a special character");
      }else if(authResponse == AuthenticationResponses.noUppercase){
        _changeColorsToRed("Please include an uppercase letter");
      }else if(authResponse == AuthenticationResponses.invalidSpecialCharacter){
        _changeColorsToRed("Please use a different special character");
      }else {
        _showMessage('Sign-up failed. Try again.');
      }
    } catch (e) {
      _showMessage('Error: $e');
      print(e);
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
                onChanged: (_){
                  if (iconColor == Colors.red) {
                    _changeColorsToDefault();
                  }
                },
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
                      _changeColorsToRed("Passwords don't match");
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
