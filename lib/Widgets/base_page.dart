import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Widgets/custom_app_bar.dart';
import 'package:clean_stream_laundry_app/Widgets/navigation_bar.dart';

class BasePage extends StatelessWidget {
  final Widget body;

  const BasePage({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(),
      body: body,
      bottomNavigationBar: NavBar(),
    );

  }
}