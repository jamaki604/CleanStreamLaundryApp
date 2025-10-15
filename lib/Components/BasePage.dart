import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Components/AppBar.dart';
import 'package:clean_stream_laundry_app/Components/NavBar.dart';

class BasePage extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const BasePage({
    super.key,
    required this.body,
    required this.currentIndex
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: body,
      bottomNavigationBar: NavBar(currentIndex: currentIndex),
    );
  }
}