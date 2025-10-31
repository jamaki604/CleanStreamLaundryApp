import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    background: Colors.white,
    primary: Color(0xFF2073A9),
    secondary: Color(0xFFf3c404),
    tertiary: Colors.indigo[900],
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
    colorScheme: ColorScheme.light(
      brightness: Brightness.dark,
      background: Colors.grey.shade900,
      primary: Color(0xFF2073A9),
      secondary: Color(0xFFf3c404),
      tertiary: Colors.deepPurple,
    )
);

extension ModeChangerText on ColorScheme {
  String get modeChangerText {
    return brightness == Brightness.dark
        ? "Change to Light Mode"
        : "Change to Dark Mode";
  }

  Color get fontPrimary {
    return brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color get fontSecondary {
    return brightness == Brightness.dark
        ? Colors.grey
        : Colors.grey;
  }

  Color get cardPrimary {
    return brightness == Brightness.dark
        ? Color(0xFFf3c404)
        : Colors.white;
  }

  Color get cardSecondary {
    return brightness == Brightness.dark
        ? Color(0xFF2073A9)
        : Colors.white;
  }
}
