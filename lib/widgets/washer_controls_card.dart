import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';

class WasherControlsCard extends StatefulWidget {
  const WasherControlsCard({super.key});

  @override
  State<WasherControlsCard> createState() => _WasherControlsCardState();
}

class _WasherControlsCardState extends State<WasherControlsCard> {
  String? selectedCycle = "Cold Normal";

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Theme.of(context).colorScheme.greyCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text(
              'Select Your Cycle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'Please make sure the selected cycle is the cycle on your machine',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _WasherButton(
                        label: "Hot Heavy",
                        selected: selectedCycle == "Hot Heavy",
                        onTap: () {
                          setState(() => selectedCycle = "Hot Heavy");
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _WasherButton(
                        label: "Hot Normal",
                        selected: selectedCycle == "Hot Normal",
                        onTap: () {
                          setState(() => selectedCycle = "Hot Normal");
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _WasherButton(
                        label: "Cold Heavy",
                        selected: selectedCycle == "Cold Heavy",
                        onTap: () {
                          setState(() => selectedCycle = "Cold Heavy");
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _WasherButton(
                        label: "Cold Normal",
                        selected: selectedCycle == "Cold Normal",
                        onTap: () {
                          setState(() => selectedCycle = "Cold Normal");
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WasherButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WasherButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: selected
            ? Colors.green
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}