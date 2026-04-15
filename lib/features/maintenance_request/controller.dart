import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaintenanceController extends ChangeNotifier {
  final EdgeFunctionService edgeFunctionService;
  final ProfileService profileService;
  final AuthService authService;

  MaintenanceController({
    EdgeFunctionService? edgeFunctionService,
    ProfileService? profileService,
    AuthService? authService,
  })  : edgeFunctionService =
      edgeFunctionService ?? GetIt.instance<EdgeFunctionService>(),
        profileService = profileService ?? GetIt.instance<ProfileService>(),
        authService = authService ?? GetIt.instance<AuthService>();

  final TextEditingController descriptionController = TextEditingController();

  final List<String> categories = const [
    'Washer/Dryer Maintenance',
    'App Maintenance',
    'Other',
  ];

  String? selectedCategory;
  File? selectedImage;

  bool attemptedSubmit = false;
  bool isLoading = false;

  Future<bool> _ensurePermissions() async {
    final camera = await Permission.camera.request();
    final photos = await Permission.photos.request();
    return camera.isGranted && photos.isGranted;
  }

  Future<void> pickImage(BuildContext context) async {
    if (!await _ensurePermissions()) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Library'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  bool get isFormValid =>
      selectedCategory != null && descriptionController.text.trim().isNotEmpty;

  void markAttemptedSubmit() {
    attemptedSubmit = true;
    notifyListeners();
  }

  Future<bool> submitMaintenance() async {
    final userId = authService.getCurrentUserId;
    if (userId == null) return false;

    isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;

      if (selectedImage != null) {
        print("Step 1: Image detected, starting upload...");

        // Use a more unique name to avoid conflicts
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode}.jpg';
        final path = 'requests/$fileName';

        // Attempt the upload
        await Supabase.instance.client.storage
            .from('maintenance-images')
            .upload(path, selectedImage!);

        print("Step 2: Upload successful, getting URL...");

        imageUrl = Supabase.instance.client.storage
            .from('maintenance-images')
            .getPublicUrl(path);

        print("Step 3: URL generated: $imageUrl");
      }

      print("Step 4: Calling Edge Function...");
      await edgeFunctionService.runEdgeFunction(
        name: 'maintenance-request',
        body: {
          'user_id': userId,
          'category': selectedCategory,
          'description': descriptionController.text,
          'image': imageUrl,
        },
      );

      print("Step 5: Submission Complete!");
      return true;
    } catch (e) {
      print("FATAL ERROR during submission: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void disposeController() {
    descriptionController.dispose();
  }
}