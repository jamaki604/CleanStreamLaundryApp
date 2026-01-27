import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/logic/parsing/password_parser.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _passwordConfirmCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  var passwordText = "Password";
  var confirmPasswordText = "Confirm Password";
  var iconColor = Colors.blue;
  var enabledBorderColor = Colors.grey;
  var focusedBorderColor = Colors.blue;
  var borderColor = Colors.blue;
  var labelColor = Colors.blue;
  bool _isLoading = false;
  final authService = GetIt.instance<AuthService>();
  final profileService = GetIt.instance<ProfileService>();

  final _focusNode = FocusNode();

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _changeColorsToRed(String reason) {
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

  void _changeColorsToDefault() {
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
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _passwordConfirmCtrl.text;

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
      final authResponse = await authService.signUp(email, password, name);
      if (authResponse == AuthenticationResponses.success) {
        _showMessage('Account created successfully.');
        context.go('/email-verification');
      } else if (authResponse == AuthenticationResponses.noDigit) {
        _changeColorsToRed('Please include a digit');
      } else if (authResponse == AuthenticationResponses.lessThanMinLength) {
        _changeColorsToRed("Password length is too short");
      } else if (authResponse == AuthenticationResponses.noSpecialCharacter) {
        _changeColorsToRed("Please include a special character");
      } else if (authResponse == AuthenticationResponses.noUppercase) {
        _changeColorsToRed("Please include an uppercase letter");
      } else if (authResponse ==
          AuthenticationResponses.invalidSpecialCharacter) {
        _changeColorsToRed("Please use a different special character");
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: kIsWeb,
        onKeyEvent: (keyEvent) {
          if (keyEvent is KeyDownEvent &&
              keyEvent.logicalKey == LogicalKeyboardKey.enter) {
            _handleSignUp();
          }
        },
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(Colors.blue),
          ),
          child: Scrollbar(
            controller: _scrollCtrl,
            thumbVisibility: true,
            interactive: true,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/Slogan.png", height: 150, width: 250),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      "Enter your info to create your account.\n After submitting, you will receive a confirmation email.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameCtrl,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(36)
                    ],
                    maxLength: 36,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontInverted,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.blue),

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.fontSecondary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _emailCtrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontInverted,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.blue),

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.fontSecondary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _passwordCtrl,
                    builder: (context, value, _) {
                      final requirementText = PasswordParser.process(
                        value.text,
                      );

                      if (requirementText == null) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(
                                requirementText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),

                  TextField(
                    controller: _passwordCtrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontInverted,
                    ),
                    decoration: InputDecoration(
                      labelText: passwordText,
                      labelStyle: TextStyle(color: labelColor),

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.fontSecondary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.lock, color: iconColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                    onChanged: (_) {
                      if (iconColor == Colors.red) {
                        _changeColorsToDefault();
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _passwordConfirmCtrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontInverted,
                    ),
                    decoration: InputDecoration(
                      labelText: confirmPasswordText,
                      labelStyle: TextStyle(color: labelColor),

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.fontSecondary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.lock, color: iconColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    onChanged: (value) {
                      if ((_passwordCtrl.text.trim() !=
                          _passwordConfirmCtrl.text.trim())) {
                        if (iconColor != Colors.red) {
                          _changeColorsToRed("Passwords don't match");
                        }
                      } else {
                        _changeColorsToDefault();
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Create Account'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
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
        ),
      ),
    );
  }
}
