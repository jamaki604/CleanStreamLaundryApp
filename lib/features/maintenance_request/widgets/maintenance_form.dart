import '../widgets/location_selector.dart';
import '../controller.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class MaintenanceForm extends StatelessWidget {
  final MaintenanceController controller;

  const MaintenanceForm({super.key, required this.controller});

  InputDecoration _inputDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.fontSecondary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.fontSecondary, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.fontInverted,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: controller.selectedCategory,
              decoration: _inputDecoration(context),
              dropdownColor: Theme.of(context).colorScheme.surface,
              iconEnabledColor: colorScheme.fontSecondary,
              style: TextStyle(color: colorScheme.fontInverted),
              hint: Text(
                'Select a category',
                style: TextStyle(color: colorScheme.fontSecondary),
              ),

              items: controller.categories
                  .map(
                    (cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ),
              )
                  .toList(),

              onChanged: (value) {
                controller.selectCategory(value!);
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Location',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.fontInverted,
              ),
            ),
            const SizedBox(height: 8),
            LocationSelector(controller: controller),

            const SizedBox(height: 24),

            Text(
              'Reason for Maintenance',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.fontInverted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.descriptionController,
              minLines: 4,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(color: colorScheme.fontInverted),
              decoration: _inputDecoration(context).copyWith(
                hintText: 'Describe the issue...',
                hintStyle: TextStyle(color: colorScheme.fontSecondary),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Attach a Photo (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.fontInverted,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => controller.pickImage(context),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.fontSecondary,
                      width: 1.5,
                    ),
                  ),
                  child: controller.selectedImage == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 40, color: colorScheme.fontSecondary),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to take or upload a photo',
                        style: TextStyle(color: colorScheme.fontSecondary),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      controller.selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),

            if (controller.attemptedSubmit && !controller.isFormValid)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Please fill in all fields',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}