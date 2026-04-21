import 'package:flutter/material.dart';

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7).withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF9A825).withOpacity(0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Colors.black),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Refund requests are reviewed within 3–5 business days. '
                  'Approved refunds will be returned to your loyalty card balance. '
                  'We reserve the right to deny requests that do not meet our refund policy criteria.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}