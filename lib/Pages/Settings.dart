import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Logic/Authentication/AuthSystem.dart';

class Settings extends StatefulWidget {
  late final AuthSystem _auth;

  Settings({super.key,required AuthSystem auth}){
    this._auth = auth;
  }

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return BasePage(body: Center(child:ElevatedButton(onPressed:(){
      widget._auth.logout();
      context.go('/login');
      }, child: Text("Sign Out"),
    style:ElevatedButton.styleFrom(backgroundColor:Colors.blue,foregroundColor:Colors.white)))
    );
  }
}
