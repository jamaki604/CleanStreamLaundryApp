import 'package:clean_stream_laundry_app/Components/LargeButton.dart';
import 'package:flutter/material.dart';

class MachineAvailabilityButton extends StatefulWidget {
  final String headLineText;
  final String descripitionText;
  final IconData icon;
  final VoidCallback onPressed;

  const MachineAvailabilityButton({
    Key? key,
    required this.headLineText,
    required this.descripitionText,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  _MachineAvailabilityButtonState createState() =>
      _MachineAvailabilityButtonState();
}

class _MachineAvailabilityButtonState extends State<MachineAvailabilityButton> {


  @override
  Widget build(BuildContext context) {

    return LargeButton(
        headLineText: widget.headLineText,
        descripitionText: widget.descripitionText,
        icon: widget.icon,
        onPressed: widget.onPressed
    );
  }
}
