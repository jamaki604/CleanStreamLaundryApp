import 'package:flutter/cupertino.dart';



class MapMarker extends StatelessWidget{
  const MapMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: CupertinoColors.transparent,
      ),
      child: Image.asset("assets/Icon.png", height: 20, width: 20,key: const Key('app_Icon'),),
    );
  }
}