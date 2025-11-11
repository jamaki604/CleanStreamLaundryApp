import 'package:clean_stream_laundry_app/Logic/Supabase/authentication_response.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  var passwordText = "Password";
  var emailText = "Email";
  var iconColor = Colors.blue;
  var enabledBorderColor = Colors.grey;
  var focusedBorderColor = Colors.blue;
  var borderColor = Colors.blue;
  var labelColor = Colors.blue;



  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in both fields.');
      return;
    }

    // Authentication API goes here.
    _showMessage('Logging in as $email...');
    final authResposne = await DatabaseService.instance.authenticator.login(email, password);
    if (!mounted) return;

    if (authResposne == AuthenticationResponses.success) {
      _showMessage('Logged in as $email');
      context.go("/homePage");
    } else if(authResposne == AuthenticationResponses.emailNotVerified) {
      context.go("/email-Verification");
    }else{
      _changeColors();
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _changeColors(){
    setState(() {
      passwordText = "Invalid Password or Email";
      emailText = "Invalid Password or Email";
      iconColor = Colors.red;
      enabledBorderColor = Colors.red;
      focusedBorderColor = Colors.red;
      borderColor = Colors.red;
      labelColor = Colors.red;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/Logo.png", height: 250, width: 250,),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: emailText,
                  labelStyle: TextStyle(color: labelColor), // matches button color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:focusedBorderColor, width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: enabledBorderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email, color: iconColor),
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
                  obscureText: true
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor:Colors.blue,foregroundColor:Colors.white),
                  child: const Text('Log In'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () => context.go("/signup"),
                  child: const Text(
                    'Create Account',
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
