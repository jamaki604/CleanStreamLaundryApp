import 'package:clean_stream_laundry_app/Components/LargeButton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Components/BasePage.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),

          LargeButton(
            headLineText: "Tap to Pay",
            descripitionText: "Tap phone to machine to pay",
            icon: Icons.tap_and_play,
            onPressed: () {

            },
          ),
          const SizedBox(height: 50),
          LargeButton(
              headLineText: "Scan QR code",
              descripitionText: "Scan QR code on the machine",
              icon: Icons.qr_code_scanner,
              onPressed: () {
                context.go("/scanner");
              }
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
