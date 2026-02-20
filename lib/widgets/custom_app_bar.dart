import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 40,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).colorScheme.primaryGradient,
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => context.go("/homePage"),
          child: SizedBox(
            width: 160,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              decoration: BoxDecoration(
                gradient: Theme.of(context).colorScheme.backgroundGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/Icon.png", height: 26),
                  const SizedBox(width: 2),
                  Image.asset("assets/Slogan.png", height: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
