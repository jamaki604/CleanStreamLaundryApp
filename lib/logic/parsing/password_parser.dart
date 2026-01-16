class PasswordParser {
  static String? process(String value) {
    final List<String> missing = [];

    if (value.length < 8) {
      missing.add("• Have 8 character length");
    }

    final specialRegex = RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]');
    if (!specialRegex.hasMatch(value)) {
      missing.add("• Include special character");
    }

    final digitRegex = RegExp(r'\d');
    if (!digitRegex.hasMatch(value)) {
      missing.add("• Include a digit");
    }

    final uppercaseRegex = RegExp(r'[A-Z]');
    if (!uppercaseRegex.hasMatch(value)) {
      missing.add("• Include an uppercase letter");
    }

    if (missing.isEmpty) return null;

    return "Password must contain the following:\n${missing.join("\n")}";
  }
}