import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
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
          return const CircularProgressIndicator();
        }

        final totalWashers = snapshot.data![0];
        final idleWashers = snapshot.data![1];
        final totalDryers = snapshot.data![2];
        final idleDryers = snapshot.data![3];

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
                height: 45,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                child: Text(
                  'Availability',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontSecondary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$idleWashers/$totalWashers Washers',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontSecondary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.local_laundry_service,
                              color: Colors.blue,
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 2, color: Colors.blue),
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$idleDryers/$totalDryers Dryers',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontSecondary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.local_laundry_service,
                              color: Colors.blue,
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}