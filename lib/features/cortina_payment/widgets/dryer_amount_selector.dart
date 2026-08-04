import 'package:flutter/material.dart';

class DryerAmountSelector extends StatelessWidget {
  final int amountCents;
  final int minimumCents;
  final int maximumCents;
  final int incrementCents;
  final ValueChanged<int> onChanged;

  const DryerAmountSelector({
    super.key,
    required this.amountCents,
    required this.minimumCents,
    required this.maximumCents,
    required this.incrementCents,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (amountCents ~/ 25) * 5;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'How much would you like to add?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Text(
            '\$${(amountCents / 100).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2073A9),
            ),
          ),
          Text('$minutes minutes', style: const TextStyle(fontSize: 18)),
          Slider(
            value: amountCents.toDouble(),
            min: minimumCents.toDouble(),
            max: maximumCents.toDouble(),
            divisions: (maximumCents - minimumCents) ~/ incrementCents,
            label: '\$${(amountCents / 100).toStringAsFixed(2)}',
            onChanged: (value) =>
                onChanged((value / incrementCents).round() * incrementCents),
          ),
          const Text('\$0.25 adds 5 minutes'),
        ],
      ),
    );
  }
}
