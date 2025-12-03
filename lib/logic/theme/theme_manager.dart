import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/middleware/storage_service.dart';

class ThemeManager with ChangeNotifier{
  final storage = GetIt.instance<StorageService>();
  ThemeData _themeData = lightMode;

  ThemeManager() {
    _initTheme();
  }

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() async{
    if(_themeData == lightMode){
      themeData = darkMode;
      await storage.setValue("themeData","darkMode");
    } else{
      themeData = lightMode;
      await storage.setValue("themeData","lightMode");
    }

    notifyListeners();
  }


  Future<void> _initTheme() async {
    await storage.init();
    final savedTheme = await storage.getValue("themeData");

    if (savedTheme == "darkMode") {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }

    notifyListeners();
  }

}