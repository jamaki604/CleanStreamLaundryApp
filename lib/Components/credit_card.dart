import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreditCard extends StatelessWidget {

  final String? username;

  const CreditCard({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 230),
      child: Card(
        color: Theme.of(context).colorScheme.cardPrimary,
        elevation: 10,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: 225,
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  left: 10,
                  child: Image.asset("assets/Slogan.png", width: 200, height: 135),
                ),
                Positioned(
                  top: -10,
                  right: 0,
                  child: Image.asset("assets/Icon.png", height: 85, width: 85),
                ),
                Positioned(
                  left: 15,
                  top: 65,
                  child: SvgPicture.asset("assets/CardChip.svg", width: 60, height: 45),
                ),
                Positioned(
                    left: -4,
                    right: 0,
                    top: 120,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "1234   5678   9012   3456",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    )
                ),
                Positioned(
                  left: 15,
                  right: 15,
                  top: 170,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (username == null || username!.isEmpty) ? 'John Doe' : username!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Image.asset(
                        "assets/Mastercard.png",
                        width: 60,
                        height: 35,
                      ),
                    ],
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