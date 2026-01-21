import 'package:flutter/cupertino.dart';

class MapMarker extends StatelessWidget{
  const MapMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: CupertinoColors.activeBlue,
      ),
    );
  }
}