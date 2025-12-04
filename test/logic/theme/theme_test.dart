import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';

void main() {
  group("ColorScheme extension tests", () {
    test("Light mode: extension getters return correct values", () {
      final scheme = lightMode.colorScheme;

      expect(scheme.modeChangerText, "Dark Mode");
      expect(scheme.fontPrimary, Colors.white);
      expect(scheme.fontInverted, Colors.black);
      expect(scheme.fontSecondary, Colors.black87);
      expect(scheme.cardPrimary, Colors.white);
      expect(scheme.cardSecondary, Colors.white);
    });

    test("Dark mode: extension getters return correct values", () {
      final scheme = darkMode.colorScheme;

      expect(scheme.modeChangerText, "Light Mode");
      expect(scheme.fontPrimary, Colors.black);
      expect(scheme.fontInverted, Colors.white);
      expect(scheme.fontSecondary, Colors.grey);
      expect(scheme.cardPrimary, const Color(0xFFCFCFCD));
      expect(scheme.cardSecondary, const Color(0xFF2073A9));
    });
  });
}
