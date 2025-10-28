import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //
      backgroundColor: Color(0xFF1D69A5),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}