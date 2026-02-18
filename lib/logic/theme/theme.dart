import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    surface: Colors.white,
    primary: Color(0xFF2073A9),
    secondary: Color(0xFFf3c404),
    tertiary: Colors.indigo[900],
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
    colorScheme: ColorScheme.light(
      brightness: Brightness.dark,
      surface: Colors.grey.shade900,
      primary: Color(0xFF2073A9),
      secondary: Color(0xFFf3c404),
      tertiary: Colors.deepPurple,
    )
);

extension ModeChangerText on ColorScheme {
  String get modeChangerText {
    return brightness == Brightness.dark
        ? "Light Mode"
        : "Dark Mode";
  }

  Color get fontPrimary {
    return brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
  }

  Color get fontInverted {
    return brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color get fontSecondary {
    return brightness == Brightness.dark
        ? Colors.grey
        : Colors.black87;
  }

  Color get cardPrimary {
    return brightness == Brightness.dark
        ? Color(0xFFCFCFCD)
        : Colors.white;
  }

  Color get cardSecondary {
    return brightness == Brightness.dark
        ? Color(0xFF2073A9)
        : Colors.white;
  }

  Color get greyCard{
    return brightness == Brightness.dark
        ? Color(0xFFCFCFCD)
        : Color(0xEECFCFCD);
  }
}

extension GradientScheme on ColorScheme {
  LinearGradient get primaryGradient {
    return brightness == Brightness.dark
        ? LinearGradient(
      colors: [
        Color(0xFF2073A9),
        Colors.deepPurple,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : LinearGradient(
      colors: [
        Color(0xFF2073A9),
        Color(0xFFf3c404),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient get backgroundGradient {
    return brightness == Brightness.dark
        ? LinearGradient(
      colors: [
        Colors.grey.shade900,
        Colors.black,
      ],
    )
        : LinearGradient(
      colors: [
        Colors.white,
        Color(0xFFE3F2FD),
      ],
    );
  }
}
