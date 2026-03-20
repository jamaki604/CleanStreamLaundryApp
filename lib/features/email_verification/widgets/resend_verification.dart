import 'package:clean_stream_laundry_app/features/email_verification/controller.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/material.dart';

class ResendVerificationWidget extends StatefulWidget {
  final EmailVerificationController controller;
  final VoidCallback onStateChange;

  const ResendVerificationWidget({
    super.key,
    required this.controller,
    required this.onStateChange,
  });

  @override
  State<ResendVerificationWidget> createState() =>
      _ResendVerificationWidgetState();
}

class _ResendVerificationWidgetState extends State<ResendVerificationWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.controller.isLoading) {
      return const CircularProgressIndicator();
    }

    if (widget.controller.resent) {
      return const Icon(Icons.check_circle, size: 40, color: Colors.green);
    }

    if (widget.controller.lastResponse == AuthenticationResponses.failure) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.close, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please resend verification again at another time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.fontPrimary,
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: () async {
        await widget.controller.resendVerification();
        widget.onStateChange();
      },
      child: const Text(
        'Resend Verification',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}