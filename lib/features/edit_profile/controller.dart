import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';

class EditProfileController extends ChangeNotifier {
  final authService = GetIt.instance<AuthService>();
  final profileService = GetIt.instance<ProfileService>();
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  StreamSubscription? authSub;

  String currentName = '';
  String currentEmail = '';

  bool isLoading = true;
  bool isSaving = false;

  bool get hasChanges =>
      nameController.text.trim() != currentName ||
          emailController.text.trim() != currentEmail;

  Future<void> init() async {
    await loadUserData();

    authSub = authService.onAuthChange.listen((_) {
      loadUserData();
    });
  }

  Future<void> disposeController() async {
    nameController.dispose();
    emailController.dispose();
    await authSub?.cancel();
  }

  Future<void> loadUserData() async {
    try {
      final userId = await authService.getCurrentUserId;

      if (userId == null) {
        throw Exception("User not found");
      }

      final username = await profileService.getUserNameById(userId);
      final email = await authService.getCurrentUserEmail();

      currentName = username ?? '';
      currentEmail = email ?? '';

      nameController.text = currentName;
      emailController.text = currentEmail;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveChanges() async {
    if (isSaving) return false;

    if (!hasChanges) {
      throw Exception("No changes made");
    }

    final newName = nameController.text.trim();
    final newEmail = emailController.text.trim();

    final nameChanged = newName != currentName;
    final emailChanged = newEmail != currentEmail;

    isSaving = true;
    notifyListeners();

    try {
      await authService.updateUserAttributes(
        email: emailChanged ? newEmail : null,
        data: nameChanged ? {'full_name': newName} : null,
      );

      currentName = newName;
      currentEmail = newEmail;

      return emailChanged;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    final userId = await authService.getCurrentUserId;

    final response = await edgeFunctionService.runEdgeFunction(
      name: "delete-account",
      body: {"user_id": userId},
    );

    if (response?.status == 200) {
      await authService.logout();
      return true;
    }

    return false;
  }
}