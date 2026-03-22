import 'package:clean_stream_laundry_app/features/reset_protected/widgets/password_requirements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget(TextEditingController controller) {
    return MaterialApp(
      home: Scaffold(
        body: PasswordRequirementsHint(controller: controller),
      ),
    );
  }

  group('PasswordRequirementsHint', () {
    testWidgets('renders nothing when password meets all requirements',
            (tester) async {
          final controller = TextEditingController(text: 'StrongPass1!');
          await tester.pumpWidget(buildWidget(controller));

          expect(find.byType(Container), findsNothing);
        });

    testWidgets('shows hint text when password is too weak', (tester) async {
      final controller = TextEditingController(text: 'weak');
      await tester.pumpWidget(buildWidget(controller));

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('hint disappears when password becomes strong', (tester) async {
      final controller = TextEditingController(text: 'weak');
      await tester.pumpWidget(buildWidget(controller));

      expect(find.byType(Container), findsOneWidget);

      controller.text = 'StrongPass1!';
      await tester.pump();

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('uses ValueListenableBuilder to react to text changes',
            (tester) async {
          final controller = TextEditingController(text: '');
          await tester.pumpWidget(buildWidget(controller));

          expect(find.byType(ValueListenableBuilder<TextEditingValue>),
              findsOneWidget);
        });

    testWidgets('hint text has centred alignment', (tester) async {
      final controller = TextEditingController(text: 'weak');
      await tester.pumpWidget(buildWidget(controller));

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.textAlign == TextAlign.center)
          .toList();

      expect(texts, isNotEmpty);
    });
  });
}