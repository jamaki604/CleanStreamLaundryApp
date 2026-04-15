import 'package:clean_stream_laundry_app/features/maintenance_request/controller.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class LocationSelector extends StatelessWidget {
  final MaintenanceController controller;

  const LocationSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.fontSecondary, width: 1.5),
        color: colorScheme.surface,
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _showLocationPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  controller.selectedLocation ?? 'Select Location',
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.selectedLocation == null
                        ? colorScheme.fontSecondary
                        : colorScheme.fontInverted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: controller.locations.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          if (index == 0) {
            return ListTile(
              title: const Text(
                'No Applicable Location',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
              onTap: () {
                controller.selectLocation('No Applicable Location');
                Navigator.pop(context);
              },
            );
          }
          final item = controller.locations[index - 1];
          final String address = item is String ? item : item['Address'];

          return ListTile(
            title: Text(address),
            onTap: () {
              controller.selectLocation(address);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}