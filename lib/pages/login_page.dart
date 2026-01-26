import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {

  final AppLinks appLinks;

  const LoginScreen({super.key,required this.appLinks});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  var passwordText = "Password";
  var emailText = "Email";
  var iconColor = Colors.blue;
  var enabledBorderColor = Colors.grey;
  var focusedBorderColor = Colors.blue;
  var borderColor = Colors.blue;
  var labelColor = Colors.blue;

  bool _obscurePassword = true;

  final authService = GetIt.instance<AuthService>();
  final profileService = GetIt.instance<ProfileService>();
  late final StreamSubscription<Uri?> _listener;

  final FocusNode _focusNode =  FocusNode();

  @override
  void initState() {
    super.initState();
    //Sets up a listener for when the app is already running
    //final appLinks = AppLinks();
    _listener = widget.appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri == null) return;

      if (uri.scheme == 'clean-stream' && uri.host == 'email-verification') {
        context.go("/homePage");
      }else if (uri.scheme == 'clean-stream' && uri.host == 'oauth') {

        await authService.handleOAuthRedirect(uri);

        if (await authService.isLoggedIn() == AuthenticationResponses.success) {

          if (!mounted) return;
          final currentUser = authService.getCurrentUser();

          if (currentUser != null) {

            final userId = currentUser.id;
            final name = currentUser.userMetadata?['full_name'] ??
                currentUser.userMetadata?['name'] ??
                currentUser.userMetadata?['given_name'];

            await profileService.createAccount(id: userId, name: name);
          }
          context.go("/homePage");
        } else {
          if (!mounted) return;
          context.go("/login");
        }
      }
    });
  }

  @override
  void dispose() {
    _listener.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in both fields.');
      return;
    }

    _showMessage('Logging in as $email...');
    final authResponse = await authService.login(email, password);
    if (!mounted) return;

    if (authResponse == AuthenticationResponses.success) {
      _showMessage('Logged in as $email');
      context.go("/homePage");
    } else if (authResponse == AuthenticationResponses.emailNotVerified) {
      context.go("/email-Verification");
    } else {
      _changeColors();
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _changeColors() {
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
      body: KeyboardListener(
      focusNode: _focusNode,
      autofocus: kIsWeb,
      onKeyEvent: (keyEvent) {
        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.enter){
          _handleLogin();
        }},
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(Colors.blue),
          ),
          child: Scrollbar(
            controller: _scrollCtrl,
            interactive: true,
            thickness: 6,
            radius: const Radius.circular(8),
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/Logo.png", height: 250, width: 250,key: const Key('app_logo'),),
                  TextField(
                    controller: _emailCtrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontInverted,
                    ),
                    decoration: InputDecoration(
                      labelText: emailText,
                      labelStyle: TextStyle(color: labelColor),
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
                      prefixIcon: Icon(Icons.email, color: iconColor),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordCtrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontInverted,
                    ),
                    decoration: InputDecoration(
                      labelText: passwordText,
                      labelStyle: TextStyle(color: labelColor),
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: const Text('Log In'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => authService.googleSignIn(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/Google.png", width: 16, height: 16, key: const Key('google_logo')),
                            const SizedBox(width: 8),
                            const Text("Sign in with Google", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => authService.appleSignIn(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.apple, size: 16),
                            SizedBox(width: 8),
                            Text("Sign in with Apple", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
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
        ),
      ),
    );
  }
}