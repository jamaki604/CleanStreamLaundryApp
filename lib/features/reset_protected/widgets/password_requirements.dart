import 'package:clean_stream_laundry_app/logic/parsing/password_parser.dart';
import 'package:flutter/material.dart';

class PasswordRequirementsHint extends StatelessWidget {
  final TextEditingController controller;

  const PasswordRequirementsHint({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final requirement = PasswordParser.process(value.text);

        if (requirement == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            requirement,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}