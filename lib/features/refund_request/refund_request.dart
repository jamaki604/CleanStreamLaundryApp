import 'controller.dart';
import 'widgets/disclaimer_card.dart';
import 'widgets/refund_form.dart';
import 'widgets/header.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RefundPage extends StatefulWidget {
  const RefundPage({super.key});

  @override
  State<RefundPage> createState() => RefundPageState();
}

class RefundPageState extends State<RefundPage> {
  late final RefundController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = RefundController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.descriptionController.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.fetchTransactions();
  }

  @override
  void dispose() {
    _controller.disposeController();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmitPressed() async {
    _controller.markAttemptedSubmit();
    if (!_controller.isFormValid) return;
    await _handleRefund();
  }

  Future<void> _handleRefund() async {
    try {
      final success = await _controller.submitRefund();
      if (!mounted) return;

      if (!success) return;

      _showRefundDialog();
    } catch (e) {
      if (!mounted) return;
    }
  }

  void _showRefundDialog() {
    statusDialog(
      context,
      title: 'Success',
      message: 'Your refund request has been submitted',
      isSuccess: true,
    ).then((_) {
      if (mounted) context.go('/settings');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        title: const Text('Request Refund',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: colorScheme.primaryGradient,
          ),
        ),
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: kIsWeb,
        onKeyEvent: (keyEvent) {
          if (keyEvent is KeyDownEvent &&
              keyEvent.logicalKey == LogicalKeyboardKey.enter) {
            _handleRefund();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: 28),
              RefundForm(controller: _controller),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _controller.isLoading ? null : _onSubmitPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _controller.isFormValid
                        ? colorScheme.primary
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: _controller.isFormValid ? 2 : 0,
                  ),
                  child: _controller.isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Submit Refund Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const DisclaimerCard(),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}