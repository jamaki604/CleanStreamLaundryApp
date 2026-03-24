import 'package:flutter/material.dart';
import '../controller.dart';
import 'verification_error.dart';
import '../../../logic/enums/authentication_response_enum.dart';

class ResendVerificationWidget extends StatefulWidget {
  final ChangeEmailVerificationController controller;
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

    return InkWell(
      onTap: () async {
        await widget.controller.resendVerification();
        widget.onStateChange();
      },
      child: widget.controller.lastResponse == null
          ? const Text(
        'Resend Verification',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.blue, decoration: TextDecoration.underline),
      )
          : widget.controller.lastResponse == AuthenticationResponses.failure
          ? const VerificationError()
          : const SizedBox.shrink(),
    );
  }
}