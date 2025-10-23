import 'package:clean_stream_laundry_app/Logic/Authentication/AuthenticationResponses.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';

class EmailVerificationPage extends StatefulWidget {
  final AuthSystem auth;

  const EmailVerificationPage({Key? key, required this.auth}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            children: [
              Icon(Icons.email, size: 40)
            ]
        )

    );
  }
}