import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AvailabilityCard extends StatelessWidget {
  final HomePageController controller;

  const AvailabilityCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      key: ValueKey(controller.locationIDSelected),
      future: controller.getMachineCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 112,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final counts = snapshot.data ?? [0, 0, 0, 0];
        final totalWashers = counts[0];
        final idleWashers = counts[1];
        final totalDryers = counts[2];
        final idleDryers = counts[3];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(14),
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                child: Text(
                  'Availability',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final iconSize = constraints.maxWidth < 340 ? 26.0 : 32.0;

                  return ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 70),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MachineAvailabilityStat(
                            label: '$idleWashers/$totalWashers Washers',
                            iconSize: iconSize,
                          ),
                        ),
                        Container(width: 2, height: 70, color: Colors.blue),
                        Expanded(
                          child: _MachineAvailabilityStat(
                            label: '$idleDryers/$totalDryers Dryers',
                            iconSize: iconSize,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MachineAvailabilityStat extends StatelessWidget {
  final String label;
  final double iconSize;

  const _MachineAvailabilityStat({required this.label, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.local_laundry_service, color: Colors.blue, size: iconSize),
        ],
      ),
    );
  }
}
