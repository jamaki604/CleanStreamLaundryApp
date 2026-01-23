import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );
  StreamSubscription? _linkSub;
  final profileService = GetIt.instance<ProfileService>();
  final authService = GetIt.instance<AuthService>();
  final AppLinks _appLinks = AppLinks();

  String currentName = '';
  String currentEmail = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri == null) return;

      if (uri.scheme == 'clean-stream' && uri.host == 'change-email') {
        await _linkSub?.cancel();
        _linkSub = null;
        try {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go("/email-verification");
          });
        } catch (e) {
          print("Deep link handling error: $e");
        }
      }
    });
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final userId = await authService.getCurrentUserId;

      if (userId == null) {
        if (mounted) {
          _showErrorDialog(
            'Unable to load user data. Please try logging in again.',
          );
          context.go('/login'); // or wherever your login page is
        }
        return;
      }

      final username = await profileService.getUserNameById(userId);
      final email = await authService.getCurrentUserEmail();

      if (!mounted) return;

      if (username == null || email == null) {
        _showErrorDialog(
          'Unable to load profile information. Some data may be missing.',
        );
      }

      setState(() {
        currentName = username ?? '';
        currentEmail = email ?? '';
        _nameController.text = currentName;
        _emailController.text = currentEmail;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to load profile data: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _linkSub?.cancel();
    super.dispose();
  }

  void _onSavePressed() async {
    if (_isSaving) return; // Prevent double-tap

    final confirmed = await _confirmationWindow();
    if (!confirmed) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      // Track which operations succeed
      bool emailUpdated = false;
      bool nameUpdated = false;
      String errorMessage = '';

      // Update email
      try {
        authService.updateEmail(email);
        emailUpdated = true;
      } catch (e) {
        errorMessage += 'Failed to update email. ';
      }

      // Update name
      try {
        await profileService.updateName(name);
        nameUpdated = true;
      } catch (e) {
        errorMessage += 'Failed to update name. ';
      }

      if (!mounted) return;

      if (emailUpdated && nameUpdated) {
        // Full success
        statusDialog(
          context,
          title: "Information Updated",
          message: "Your information has successfully been updated.",
          isSuccess: true,
        );
        // Update current values
        setState(() {
          currentName = name;
          currentEmail = email;
        });
      } else if (emailUpdated || nameUpdated) {
        // Partial success
        statusDialog(
          context,
          title: "Partially Updated",
          message: errorMessage.trim() + " Please try again.",
          isSuccess: false,
        );
      } else {
        // Complete failure
        statusDialog(
          context,
          title: "Update Failed",
          message: "Unable to update your information. Please try again later.",
          isSuccess: false,
        );
      }
    } catch (e) {
      if (mounted) {
        statusDialog(
          context,
          title: "Error",
          message: "An unexpected error occurred: ${e.toString()}",
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: TextStyle(color: Theme.of(context).colorScheme.fontSecondary),
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.fontSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go("/settings");
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Current Name Display
                    if (currentName.isNotEmpty)
                      Text(
                        'Current Name: $currentName',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.fontSecondary,
                        ),
                      ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _nameController,
                      enabled: !_isSaving,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontSecondary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
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
                        prefixIcon: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Current Email Display
                    if (currentEmail.isNotEmpty)
                      Text(
                        'Current Email: $currentEmail',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.fontSecondary,
                        ),
                      ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSaving,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontSecondary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
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
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!value.trim().contains("@")) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 34),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          onPressed: _isSaving ? null : _onSavePressed,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
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

  Future<bool> _confirmationWindow() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Confirm Changes',
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontSecondary,
              ),
            ),
            content: Text(
              'Are you sure you want to change your information?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes, Save'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
