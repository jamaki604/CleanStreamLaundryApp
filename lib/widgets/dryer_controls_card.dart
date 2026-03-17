import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';

class DryerControlsCard extends StatefulWidget {
  final void Function(double price, int minutes) onChanged;

  const DryerControlsCard({super.key, required this.onChanged});

  @override
  State<DryerControlsCard> createState() => _DryerControlsCardState();
}

class _DryerControlsCardState extends State<DryerControlsCard> {
  int _selectedMinutes = 30;

  double get _calculatedPrice => (_selectedMinutes / 5) * 0.25;

  @override
  void initState() {
    super.initState();
    // Notify parent of the initial default values after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_calculatedPrice, _selectedMinutes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: Theme.of(context).colorScheme.greyCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text(
              'Set Dry Time',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            Text(
              '$_selectedMinutes min',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2073A9),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '\$0.25 per 5 minutes',
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),

            const SizedBox(height: 8),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF2073A9),
                inactiveTrackColor: const Color(0xFF2073A9).withOpacity(0.2),
                thumbColor: const Color(0xFF2073A9),
                overlayColor: const Color(0xFF2073A9).withOpacity(0.12),
                trackHeight: 4,
              ),
              child: Slider(
                value: _selectedMinutes.toDouble(),
                min: 5,
                max: 90,
                divisions: 17,
                onChanged: (value) {
                  final snapped = (value / 5).round() * 5;
                  setState(() => _selectedMinutes = snapped);
                  widget.onChanged(_calculatedPrice, snapped);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5 min',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  Text(
                    '90 min',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
