import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Components/CustomAppBar.dart';
import 'package:clean_stream_laundry_app/Components/NavBar.dart';

class BasePage extends StatelessWidget {
  final Widget body;

  const BasePage({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: body,
      bottomNavigationBar: NavBar(),
    );
  }
}