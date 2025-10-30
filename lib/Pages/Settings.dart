import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Logic/Authentication/AuthSystem.dart';
import '../Logic/Theme/Theme.dart';
import '../Logic/Theme/ThemeManager.dart';
import 'package:provider/provider.dart';

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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return BasePage(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget._auth.logout();
                    context.go('/login');
                  },
                  child: Text("Sign Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    themeManager.toggleTheme();
                  },
                  child: Text(Theme.of(context).colorScheme.modeChangerText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme
                        .of(context)
                        .colorScheme
                        .tertiary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}