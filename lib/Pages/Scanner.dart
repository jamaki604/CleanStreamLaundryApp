import 'package:flutter/material.dart';
import 'HomePage.dart';

class Scanner extends StatelessWidget {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Stream Laundry Solutions',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}