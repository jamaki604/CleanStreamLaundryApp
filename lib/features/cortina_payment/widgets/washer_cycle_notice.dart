import 'package:flutter/material.dart';

class WasherCycleNotice extends StatelessWidget {
  final String? sizeLabel;

  const WasherCycleNotice({super.key, required this.sizeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 32, color: Color(0xFF2073A9)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sizeLabel != null)
                  Text(
                    sizeLabel!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                const Text(
                  'After payment, select the cycle on the washer.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
