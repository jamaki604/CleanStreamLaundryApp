import 'package:clean_stream_laundry_app/Components/large_button.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Theme/theme.dart';
import 'package:go_router/go_router.dart';
import '../Components/base_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
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
                      Icon(
                        Icons.tap_and_play,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: LargeButton(
                  headLineText: "Scan QR code",
                  descripitionText: "Scan QR code on the machine",
                  icon: Icons.qr_code_scanner,
                  onPressed: () {
                    context.go("/scanner");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
