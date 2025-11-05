import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Theme/theme.dart';

class ThemeManager with ChangeNotifier{
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme(){
    if(_themeData == lightMode){
      themeData = darkMode;
    } else{
      themeData = lightMode;
    }
  }
}