import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/material.dart';

late bool cancelSearch = false;

void showSearchingDialog(BuildContext context) {
  cancelSearch = false;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              "Finding Nearby Doors...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(dialogContext).colorScheme.fontInverted,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Please wait while we search for the nearest door.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.fontInverted,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                cancelSearch = true;
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}