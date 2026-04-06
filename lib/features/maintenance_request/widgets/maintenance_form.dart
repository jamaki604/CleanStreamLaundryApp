import '../controller.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:clean_stream_laundry_app/features/maintenance_request/widgets/transactions_search_sheet.dart';
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
              'Select a Transaction',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.fontInverted,
              ),
            ),
            const SizedBox(height: 8),

            controller.isFetchingTransactions
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
              onTap: () async {
                final selected =
                await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => TransactionSearchSheet(
                    transactions: controller.recentTransactions,
                  ),
                );
                if (selected != null) {
                  controller.selectTransaction(selected);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: _inputDecoration(context).copyWith(
                    hintText: 'Select a transaction',
                    hintStyle:
                    TextStyle(color: colorScheme.fontSecondary),
                  ),
                  controller: TextEditingController(
                    text: controller.selectedTransaction,
                  ),
                  style: TextStyle(color: colorScheme.fontInverted),
                ),
              ),
            ),

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
                hintText: 'Describe the issue with your transaction...',
                hintStyle: TextStyle(color: colorScheme.fontSecondary),
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