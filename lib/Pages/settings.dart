import 'package:clean_stream_laundry_app/Components/base_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Logic/Services/auth_service.dart';
import '../Logic/Theme/theme.dart';
import '../Logic/Theme/theme_manager.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  late final AuthSystem _auth;

  Settings({super.key,required AuthSystem auth}){
    _auth = auth;
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
                Text(
                  "Settings \n",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.fontSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),


                ElevatedButton(
                  onPressed: () {
                    widget._auth.logout();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Sign Out"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    themeManager.toggleTheme();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(Theme.of(context).colorScheme.modeChangerText),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}