import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/material.dart';

class LocationSelector extends StatelessWidget {
  final HomePageController controller;
  final VoidCallback onGetDirections;

  const LocationSelector({
    super.key,
    required this.controller,
    required this.onGetDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        color: Theme.of(context).colorScheme.cardSecondary,
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _showLocationPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  controller.selectedName ?? 'Select Location',
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.selectedName == null
                        ? Colors.grey
                        : Theme.of(context).colorScheme.fontInverted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onGetDirections,
            icon: Icon(
              Icons.navigation,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
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
        itemCount: controller.locations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final item = controller.locations[index];
          return ListTile(
            title: Text(
              item['Address'],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.fontInverted,
              ),
            ),
            onTap: () {
              controller.selectLocation(item['Address']);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}