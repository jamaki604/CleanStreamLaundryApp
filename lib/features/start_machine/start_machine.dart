import 'controller.dart';
import 'widgets/qr_button.dart';
import 'widgets/searching_dialog.dart';
import 'widgets/tap_card.dart';
import 'package:clean_stream_laundry_app/services/kisi/door_unlocker.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/widgets/section_banner.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartPage extends StatefulWidget {
  final DoorUnlocker? doorUnlocker;

  const StartPage({super.key, this.doorUnlocker});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late final StartPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StartPageController(doorUnlocker: widget.doorUnlocker);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onUnlockPressed() async {
    if (!_controller.hasSufficientBalance) {
      _showLowBalanceDialog();
      return;
    }
    await _processUnlocking();
  }

  Future<void> _processUnlocking() async {
    showSearchingDialog(context, _controller.cancelUnlock);

    final success = await _controller.unlockDoor();

    if (!mounted) return;
    if (_controller.cancelSearch) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    statusDialog(
      context,
      title: success ? 'Door Unlocked!' : 'No Nearby Doors Found',
      message: success
          ? 'The nearest door has been unlocked successfully'
          : "We couldn't detect any nearby doors",
      isSuccess: success,
    );
  }

  void _showLowBalanceDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Low Balance'),
        content: Text(
          'You need at least ${minimumBalance.toStringAsFixed(2)} to unlock a door',
        ),
        icon: const Icon(Icons.error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/startPage');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Payment Options'),
                const TapToPayCard(),
                const SizedBox(height: 10),
                SizedBox(
                  height: 160,
                  child: QRButton(
                    headLineText: 'Scan QR code',
                    descriptionText: 'Scan QR code on the machine',
                    icon: Icons.qr_code_scanner,
                    onPressed: () => context.go('/scanner'),
                  ),
                ),
                const SizedBox(height: 10),
                const SectionHeader(title: 'After Hours'),
                SizedBox(
                  height: 160,
                  child: QRButton(
                    headLineText: 'Unlock Door',
                    descriptionText: 'Unlock doors after hours',
                    icon: Icons.lock_open_rounded,
                    onPressed: _onUnlockPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}