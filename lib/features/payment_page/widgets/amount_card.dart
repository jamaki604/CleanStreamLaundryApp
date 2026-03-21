import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/material.dart';

class AmountCard extends StatelessWidget {
  final String? machineName;
  final double? price;
  final bool paymentCompleted;

  const AmountCard({
    super.key,
    required this.machineName,
    required this.price,
    required this.paymentCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.greyCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_laundry_service,
            size: 80,
            color: Color(0xFF2073A9),
          ),
          const SizedBox(height: 20),
          Text(
            'Machine $machineName',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            paymentCompleted ? 'Payment Complete' : 'Amount Due',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            '\$${price?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}