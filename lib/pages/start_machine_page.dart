import 'package:clean_stream_laundry_app/widgets/qr_button.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/widgets/section_banner.dart';
import 'package:clean_stream_laundry_app/services/kisi/door_unlocker.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';
import 'package:clean_stream_laundry_app/widgets/show_searching.dart';
import '../widgets/status_dialog_box.dart';

bool cancelSearch = false;
const double minimumBalance = 20.0;

class StartPage extends StatelessWidget {
  final viewModel = GetIt.instance<LoyaltyViewModel>();
  final DoorUnlocker doorUnlocker;

  StartPage({super.key, DoorUnlocker? doorUnlocker})
      : doorUnlocker = doorUnlocker ?? DoorUnlocker();

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
                const SectionHeader(title: "Payment Options"),
                Container(
                  height: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 3),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tap To Pay",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.fontInverted,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Tap phone to machine to pay",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.fontSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.tap_and_play,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 160,
                  child: QRButton(
                    headLineText: "Scan QR code",
                    descriptionText: "Scan QR code on the machine",
                    icon: Icons.qr_code_scanner,
                    onPressed: () {
                      context.go("/scanner");
                    },
                  ),
                ),

                const SizedBox(height: 10),
                const SectionHeader(title: "After Hours"),

                SizedBox(
                  height: 160,
                  child: QRButton(
                    headLineText: "Unlock Door",
                    descriptionText: "Unlock doors after hours",
                    icon: Icons.lock_open_rounded,
                    onPressed: () async {
                      if (viewModel.userBalance! < minimumBalance) {
                        _showLowBalanceDialog(context);
                      } else {
                        await _processUnlocking(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processUnlocking(BuildContext context) async {
    cancelSearch = false;

    showSearchingDialog(context);

    final success = await doorUnlocker.unlockNearestDoor();

    if (cancelSearch) {
      doorUnlocker.cancelUnlockingDoor();
      return;
    }

    if (context.mounted) Navigator.of(context).pop();

    if (!context.mounted) return;

    statusDialog(
      context,
      title: success ? "Door Unlocked!" : "No Nearby Doors Found",
      message: success
          ? "The nearest door has been unlocked successfully"
          : "We couldn't detect any nearby doors",
      isSuccess: success,
    );
  }
}

void _showLowBalanceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Error'),
        content: const Text('You need at least \$20 to unlock a door'),
        icon: const Icon(Icons.error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go("/start");
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}