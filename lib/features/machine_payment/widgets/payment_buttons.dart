import 'package:flutter/material.dart';

class PaymentButtons extends StatelessWidget {
  final double? price;
  final double? userBalance;
  final bool isProcessing;
  final VoidCallback onDirectPay;
  final VoidCallback onLoyaltyPay;

  const PaymentButtons({
    super.key,
    required this.price,
    required this.userBalance,
    required this.isProcessing,
    required this.onDirectPay,
    required this.onLoyaltyPay,
  });

  bool get _disabled => isProcessing || price == null || price == 0;
  bool get _loyaltyDisabled =>
      _disabled || (userBalance ?? 0) < (price ?? 0);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _disabled ? null : onDirectPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: _disabled ? Colors.grey : Colors.blue[700],
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isProcessing
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Text(
              price != null && price! > 0
                  ? 'Pay \$${price!.toStringAsFixed(2)}'
                  : 'Pay',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _loyaltyDisabled ? null : onLoyaltyPay,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _loyaltyDisabled ? Colors.grey : Colors.green[700],
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Pay with Loyalty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}