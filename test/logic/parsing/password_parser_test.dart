import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/logic/parsing/password_parser.dart';

void main() {
  group('PasswordParser.process', () {
    test('returns all requirements when password is empty', () {
      final result = PasswordParser.process("");

      expect(result, contains("Have 8 character length"));
      expect(result, contains("Include special character"));
      expect(result, contains("Include a digit"));
      expect(result, contains("Include an uppercase letter"));
    });

    test('returns missing length requirement', () {
      final result = PasswordParser.process("Ab1!");

      expect(result, contains("Have 8 character length"));
      expect(result, isNot(contains("Include special character")));
      expect(result, isNot(contains("Include a digit")));
      expect(result, isNot(contains("Include an uppercase letter")));
    });

    test('returns missing special character requirement', () {
      final result = PasswordParser.process("Abc12345");

      expect(result, contains("Include special character"));
      expect(result, isNot(contains("Have 8 character length")));
      expect(result, isNot(contains("Include a digit")));
      expect(result, isNot(contains("Include an uppercase letter")));
    });

    test('returns missing digit requirement', () {
      final result = PasswordParser.process("Abcdefg!");

      expect(result, contains("Include a digit"));
      expect(result, isNot(contains("Have 8 character length")));
      expect(result, isNot(contains("Include special character")));
      expect(result, isNot(contains("Include an uppercase letter")));
    });

    test('returns missing uppercase requirement', () {
      final result = PasswordParser.process("abc1234!");

      expect(result, contains("Include an uppercase letter"));
      expect(result, isNot(contains("Have 8 character length")));
      expect(result, isNot(contains("Include special character")));
      expect(result, isNot(contains("Include a digit")));
    });

    test('returns multiple missing requirements', () {
      final result = PasswordParser.process("abc");

      expect(result, contains("Have 8 character length"));
      expect(result, contains("Include special character"));
      expect(result, contains("Include a digit"));
      expect(result, contains("Include an uppercase letter"));
    });

    test('returns null when all requirements are met', () {
      final result = PasswordParser.process("Abc1234!");

      expect(result, isNull);
    });

    test('handles long valid passwords', () {
      final result = PasswordParser.process("SuperStrongPassword123!");

      expect(result, isNull);
    });

    test('handles special characters at edges', () {
      final result = PasswordParser.process("!Abc1234");

      expect(result, isNull);
    });
  });
}