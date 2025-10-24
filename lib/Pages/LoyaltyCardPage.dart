import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/LoyaltyCard.dart';

class LoyaltyCardPage extends StatefulWidget {
  const LoyaltyCardPage({super.key});

  @override
  State<LoyaltyCardPage> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<LoyaltyCardPage> {
  void _addMoney() {
    setState(() {
      LoyaltyCard.addMoney(5.0);
    });
  }

  void _subtractMoney() {
    setState(() {
      LoyaltyCard.subtractMoney(5.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Loyalty Card Balance',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${LoyaltyCard.balance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, color: Colors.green),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _addMoney,
                          icon: const Icon(Icons.add),
                          label: const Text('Add \$5'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _subtractMoney,
                          icon: const Icon(Icons.remove),
                          label: const Text('Subtract \$5'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}