import 'package:clean_stream_laundry_app/features/sign_up/widgets/password_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget(TextEditingController controller) {
    return MaterialApp(
      home: Scaffold(
        body: SignUpPasswordHint(controller: controller),
      ),
    );
  }

  group('SignUpPasswordHint tests', () {

    testWidgets('shows all requirements when password is empty', (tester) async {
      final controller = TextEditingController(text: '');

      await tester.pumpWidget(createWidget(controller));
      await tester.pumpAndSettle();

      expect(find.textContaining('Password must contain'), findsOneWidget);
      expect(find.textContaining('8 character length'), findsOneWidget);
      expect(find.textContaining('special character'), findsOneWidget);
      expect(find.textContaining('digit'), findsOneWidget);
      expect(find.textContaining('uppercase letter'), findsOneWidget);
    });

    testWidgets('shows only missing requirements', (tester) async {
      final controller = TextEditingController(text: 'abcdefg');

      await tester.pumpWidget(createWidget(controller));
      await tester.pumpAndSettle();

      expect(find.textContaining('8 character length'), findsOneWidget);
      expect(find.textContaining('special character'), findsOneWidget);
      expect(find.textContaining('digit'), findsOneWidget);
      expect(find.textContaining('uppercase letter'), findsOneWidget);
    });

    testWidgets('partially valid password shows only remaining rules',
            (tester) async {
          final controller = TextEditingController(text: 'Validpass');

          await tester.pumpWidget(createWidget(controller));
          await tester.pumpAndSettle();

          expect(find.textContaining('digit'), findsOneWidget);
          expect(find.textContaining('special character'), findsOneWidget);

          expect(find.textContaining('uppercase letter'), findsNothing);
          expect(find.textContaining('8 character length'), findsNothing);
        });
  });
}