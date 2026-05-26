import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import '../controller.dart';
import 'credit_card.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final LoyaltyController controller;
  final VoidCallback onInfoTap;

  const Header({super.key, required this.controller, required this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreditCard(username: controller.userName ?? 'John Doe'),
        const SizedBox(height: 17),
        Text(
          'Loyalty Balance: \$${controller.userBalance?.toStringAsFixed(2) ?? '0.00'}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.fontSecondary,
          ),
        ),
        Text(
          'Paid \$${controller.paidBalance?.toStringAsFixed(2) ?? '0.00'} | Promo \$${controller.promoBalance?.toStringAsFixed(2) ?? '0.00'}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.fontSecondary,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${(20 - (controller.userReward ?? 0)).toStringAsFixed(2)} until next reward',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.fontSecondary,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onInfoTap,
              icon: const Icon(Icons.info_outline),
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }
}
