import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/material.dart';

class TapToPayCard extends StatelessWidget {
  const TapToPayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 3),
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tap To Pay',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontInverted,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tap phone to machine to pay',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Icon(Icons.tap_and_play, color: Colors.blue, size: 40),
        ],
      ),
    );
  }
}