import 'package:clean_stream_laundry_app/features/edit_profile/widgets/name_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({
    TextEditingController? controller,
    bool enabled = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          child: NameFormField(
            controller: controller ?? TextEditingController(),
            enabled: enabled,
          ),
        ),
      ),
    );
  }

  group('NameFormField', () {
    group('Rendering', () {
      testWidgets('displays label text', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('New Full Name'), findsOneWidget);
      });

      testWidgets('displays hint text', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Enter your full name'), findsOneWidget);
      });

      testWidgets('displays person outline prefix icon', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });

      testWidgets('is enabled by default', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(buildWidget(controller: controller));

        await tester.enterText(find.byType(TextFormField), 'Test');

        expect(controller.text, 'Test');
      });

      testWidgets('is disabled when enabled is false', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildWidget(controller: controller, enabled: false),
        );

        final field = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(field.enabled, isFalse);
      });
    });

    group('Input formatters', () {
      testWidgets('enforces 36 character limit', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(buildWidget(controller: controller));

        await tester.enterText(
          find.byType(TextFormField),
          'A' * 50,
        );
        await tester.pump();

        expect(controller.text.length, lessThanOrEqualTo(36));
      });

      testWidgets('strips special characters', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(buildWidget(controller: controller));

        await tester.enterText(find.byType(TextFormField), 'Test@#\$%');
        await tester.pump();

        expect(controller.text, 'Test');
      });

      testWidgets('allows letters, numbers, and spaces', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(buildWidget(controller: controller));

        await tester.enterText(find.byType(TextFormField), 'John Doe 123');
        await tester.pump();

        expect(controller.text, 'John Doe 123');
      });
    });

    group('Validation', () {
      testWidgets('shows error for empty value', (tester) async {
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: NameFormField(
                  controller: TextEditingController(text: ''),
                  enabled: true,
                ),
              ),
            ),
          ),
        );

        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Name cannot be empty'), findsOneWidget);
      });

      testWidgets('shows error for whitespace-only value', (tester) async {
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: NameFormField(
                  controller: TextEditingController(text: '   '),
                  enabled: true,
                ),
              ),
            ),
          ),
        );

        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Name cannot be empty'), findsOneWidget);
      });

      testWidgets('passes validation for non-empty value', (tester) async {
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: NameFormField(
                  controller: TextEditingController(text: 'John Doe'),
                  enabled: true,
                ),
              ),
            ),
          ),
        );

        final isValid = formKey.currentState!.validate();

        expect(isValid, isTrue);
        expect(find.text('Name cannot be empty'), findsNothing);
      });
    });
  });
}