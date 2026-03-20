import 'package:app_links/app_links.dart';
import 'package:clean_stream_laundry_app/features/email_verification/controller.dart';
import 'package:clean_stream_laundry_app/features/email_verification/widgets/resend_verification.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/material.dart';

class EmailVerificationPage extends StatefulWidget {
  final AppLinks appLinks;

  const EmailVerificationPage({super.key, required this.appLinks});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late final EmailVerificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmailVerificationController(
      appLinks: widget.appLinks,
      context: context,
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.email, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                'Please verify your email address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.fontInverted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Check your inbox and click the verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.fontSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ResendVerificationWidget(
                controller: _controller,
                onStateChange: _refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}