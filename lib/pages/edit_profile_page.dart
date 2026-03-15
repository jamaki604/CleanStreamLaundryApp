import 'dart:async';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final StreamSubscription _authSub;

  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );
  final profileService = GetIt.instance<ProfileService>();
  final authService = GetIt.instance<AuthService>();
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();

  String currentName = '';
  String currentEmail = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _authSub = authService.onAuthChange.listen((_) {
      _loadUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          context.go('/login');
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
    _authSub.cancel();
    super.dispose();
  }

  void _onSavePressed() async {
    if (_isSaving) return;
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    final nameChanged = newName != currentName;
    final emailChanged = newEmail != currentEmail;

    if (!nameChanged && !emailChanged) {
      statusDialog(
        context,
        title: "No Changes",
        message: "You haven't changed anything.",
        isSuccess: false,
      );
      return;
    }

    final confirmed = await _confirmSaveChanges();
    if (!confirmed) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await authService.updateUserAttributes(
        email: emailChanged ? newEmail : null,
        data: nameChanged ? {'full_name': newName} : null,
      );

      if (!mounted) return;

      // EMAIL CHANGE
      if (emailChanged) {
        context.go('/change-email-verification');
        return;
      }

      // NAME ONLY
      setState(() {
        currentName = newName;
        currentEmail = newEmail;
      });

      statusDialog(
        context,
        title: "Profile Updated",
        message: "Your information has been updated successfully.",
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted) return;

      statusDialog(
        context,
        title: "Update Failed",
        message: e.toString(),
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Error',
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.fontSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).colorScheme.primaryGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go("/settings");
          },
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Section
                      _buildSectionHeader('Full Name'),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        label: 'Current',
                        value: currentName.isNotEmpty ? currentName : 'Not set',
                        icon: Icons.badge_outlined,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        enabled: !_isSaving,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(36),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9 ]'),
                          ),
                        ],
                        maxLength: 36,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontSecondary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'New Full Name',
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.fontSecondary.withValues(alpha: 0.5),
                          ),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                          ),
                          counterStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.fontSecondary.withValues(alpha: 0.6),
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
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
                              color: Theme.of(context).colorScheme.fontSecondary
                                  .withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
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

                      const SizedBox(height: 10),

                      // Email Section
                      _buildSectionHeader('Email Address'),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        label: 'Current',
                        value: currentEmail.isNotEmpty
                            ? currentEmail
                            : 'Not set',
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        enabled: !_isSaving,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontSecondary,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'New Email',
                          hintText: 'Enter your email address',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.fontSecondary.withValues(alpha: 0.5),
                          ),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
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
                              color: Theme.of(context).colorScheme.fontSecondary
                                  .withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
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

                      const SizedBox(height: 20),

                      // Save Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 30),

                      // Delete Account Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Danger Zone',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Once you delete your account, there is no going back. Any loyalty points will be permanently lost.',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontSecondary
                                    .withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: _isSaving ? null : _deleteAccount,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.red,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.delete_outline, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete Account',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.fontSecondary,
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.fontSecondary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.fontSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() async {
    bool confirm = await _confirmDeleteAccount();
    if (confirm) {
      String? userId = authService.getCurrentUserId;
      final response = await edgeFunctionService.runEdgeFunction(
        name: "delete-account",
        body: {"user_id": userId},
      );
      if (response!.status == 200) {
        statusDialog(
          context,
          title: "Account Deleted",
          message: "Your account has been deleted successfully.",
          isSuccess: true,
        );
        await authService.logout();
        context.go("/login");
      } else {
        statusDialog(
          context,
          title: "Error",
          message: "An error occurred, please try again later.",
          isSuccess: false,
        );
        return;
      }
    } else {
      return;
    }
  }

  Future<bool> _confirmDeleteAccount() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Delete Account?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to delete your account? Any money on your loyalty card will be lost. This action cannot be undone.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmSaveChanges() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Confirm Changes',
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to save these changes to your profile?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
