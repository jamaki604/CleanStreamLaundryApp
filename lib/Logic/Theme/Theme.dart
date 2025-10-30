import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    background: Colors.white,
    primary: Colors.black,
    tertiary: Colors.indigo[900],
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
    colorScheme: ColorScheme.light(
      brightness: Brightness.dark,
      background: Colors.grey.shade900,
      primary: Colors.white,
      tertiary: Colors.deepPurple,
    )
);

extension ModeChangerText on ColorScheme {
  String get modeChangerText {
    return brightness == Brightness.dark
        ? "Change to Light Mode"
        : "Change to Dark Mode";
  }
}
