import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreditCard extends StatelessWidget {
  final String? username;

  const CreditCard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final displayName = (username == null || username!.isEmpty)
        ? 'John Doe'
        : username!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: AspectRatio(
            aspectRatio: 1.58,
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Theme.of(context).colorScheme.cardPrimary,
              elevation: 10,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  return Stack(
                    children: [
                      Positioned(
                        top: height * 0.09,
                        left: width * 0.08,
                        child: Image.asset(
                          "assets/Slogan.png",
                          width: width * 0.48,
                          key: const Key("slogan"),
                        ),
                      ),
                      Positioned(
                        top: height * 0.05,
                        right: width * 0.06,
                        child: Image.asset(
                          "assets/Icon.png",
                          width: width * 0.22,
                          key: const Key("icon"),
                        ),
                      ),
                      Positioned(
                        left: width * 0.08,
                        top: height * 0.36,
                        child: SvgPicture.asset(
                          "assets/CardChip.svg",
                          width: width * 0.14,
                          key: const Key("cardChip"),
                        ),
                      ),
                      Positioned(
                        left: width * 0.08,
                        right: width * 0.08,
                        top: height * 0.57,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "1234   5678   9012   3456",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.fontInverted,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: width * 0.08,
                        right: width * 0.07,
                        bottom: height * 0.12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  displayName,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Image.asset(
                              "assets/Mastercard.png",
                              width: width * 0.16,
                              key: const Key("mastercard"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
