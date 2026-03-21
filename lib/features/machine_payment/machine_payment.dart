import 'controller.dart';
import 'widgets/amount_card.dart';
import 'widgets/back_to_home.dart';
import 'widgets/payment_buttons.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'widgets/dryer_controls_card.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'widgets/washer_controls_card.dart';
import 'package:flutter/material.dart';

class MachinePayment extends StatefulWidget {
  final String machineId;

  const MachinePayment({super.key, required this.machineId});

  @override
  State<MachinePayment> createState() => _MachinePaymentState();
}

class _MachinePaymentState extends State<MachinePayment> {
  late final PaymentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentController(machineId: widget.machineId);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDirectPay() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final outcome = await _controller.processDirectPayment();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    switch (outcome) {
      case PaymentOutcome.success:
        statusDialog(
          context,
          title: 'Payment Processed! Machine Ready!',
          message: 'Machine ${_controller.machineName} is now active.',
          isSuccess: true,
        );
        break;
      case PaymentOutcome.machineError:
        statusDialog(
          context,
          title: 'Machine Error',
          message: 'Payment succeeded but machine did not wake up.',
          isSuccess: false,
        );
        break;
      case PaymentOutcome.failed:
      case PaymentOutcome.canceled:
        statusDialog(
          context,
          title: 'Payment Failed',
          message: 'Your payment could not be processed.',
          isSuccess: false,
        );
        break;
    }
  }

  Future<void> _onLoyaltyPay() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final outcome = await _controller.processLoyaltyPayment();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    switch (outcome) {
      case PaymentOutcome.success:
        statusDialog(
          context,
          title: 'Machine Ready!',
          message: 'Machine ${_controller.machineName} is now active.',
          isSuccess: true,
        );
        statusDialog(
          context,
          title: 'Payment Successful!',
          message:
          'Thank you! \$${_controller.price?.toStringAsFixed(2)} was taken from your Loyalty Card.',
          isSuccess: true,
        );
        break;
      case PaymentOutcome.machineError:
        statusDialog(
          context,
          title: 'Machine Error',
          message:
          'Machine did not respond. Your balance has not been charged. Please contact support.',
          isSuccess: false,
        );
        break;
      case PaymentOutcome.failed:
      case PaymentOutcome.canceled:
        statusDialog(
          context,
          title: 'Payment Failed',
          message: 'Your payment could not be processed.',
          isSuccess: false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AmountCard(
                    machineName: _controller.machineName,
                    price: _controller.price,
                    paymentCompleted: _controller.paymentCompleted,
                  ),
                  const SizedBox(height: 20),
                  if (_controller.isDryer)
                    DryerControlsCard(
                      onChanged: _controller.onDryerChanged,
                    )
                  else
                    WasherControlsCard(
                      onCycleChanged: _controller.onWasherCycleChanged,
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _controller.paymentCompleted
                ? const BackToHome()
                : PaymentButtons(
              price: _controller.price,
              userBalance: _controller.userBalance,
              isProcessing: false,
              onDirectPay: _onDirectPay,
              onLoyaltyPay: _onLoyaltyPay,
            ),
          ),
        ],
      ),
    );
  }
}