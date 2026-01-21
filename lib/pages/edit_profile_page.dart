import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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
  final profileService = GetIt.instance<ProfileService>();
  final authService = GetIt.instance<AuthService>();

  // Placeholder variables for current name and email
  String currentName = '';
  String currentEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userId = await authService.getCurrentUserId;
    final username = await profileService.getUserNameById(userId!);
    final email = await authService.getCurrentUserEmail();

    setState(() {
      currentName = username!; // placeholder
      currentEmail = email!; // placeholder
      _nameController.text = currentName;
      _emailController.text = currentEmail;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSavePressed() async {
    final confirmed = await _confirmationWindow();
    if (!confirmed) return;

    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      authService.updateEmail(email);
      profileService.updateName(name);
      statusDialog(
        context,
        title: "Information Updated",
        message: "Your information has successfully been updated.",
        isSuccess: true,
      );
    } else {
      return;
    }
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
      body: Padding(
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _onSavePressed,
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white, fontSize: 18),
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
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true), // Confirm
                child: const Text('Yes, Save'),
              ),
            ],
          ),
        ) ??
        false; // In case the dialog is dismissed without pressing a button
  }
}
