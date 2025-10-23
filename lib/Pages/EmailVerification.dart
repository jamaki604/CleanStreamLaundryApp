import 'package:clean_stream_laundry_app/Logic/Authentication/AuthenticationResponses.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';

class EmailVerificationPage extends StatefulWidget {
  late final AuthSystem _auth;

  EmailVerificationPage({super.key,required AuthSystem auth}){
    this._auth = auth;
  }

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Widget resendVerfication = const Text(
    'Resend Verfication',
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    )
  );

  bool resent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              const Text(
                'Please verify your email address',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                'Check your inbox and click the verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  if(resent == false) {
                    setState(() {
                      if(widget._auth.resendVerification() == AuthenticationResponses.success) {
                        resendVerfication = Icon(Icons.check_circle, size: 40,
                            color: Colors.green);
                        resent = true;
                      }else{
                        resendVerfication = Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Please resend verification again at another time.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }
                    });
                  }
                },
                child: resendVerfication,
                ),
            ],
          ),
        ),
      ),
    );
  }
}