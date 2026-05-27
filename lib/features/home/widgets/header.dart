import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final HomePageController controller;
  final VoidCallback onAddFunds;

  const Header({super.key, required this.controller, required this.onAddFunds});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final username = controller.username?.trim();
    final balance = controller.balance?["balance"];
    final formattedBalance = balance is num
        ? '\$${balance.toStringAsFixed(2)}'
        : 'Loading...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          username == null || username.isEmpty
              ? 'Welcome!'
              : 'Welcome, $username',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 23,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 5,
          shadowColor: Colors.black.withValues(alpha: 0.20),
          surfaceTintColor: Colors.transparent,
          color: colorScheme.cardPrimary,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet balance',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.fontSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formattedBalance,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  key: const ValueKey('home-add-funds-button'),
                  onPressed: onAddFunds,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text(
                    'Add funds',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
