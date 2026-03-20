import 'package:clean_stream_laundry_app/features/edit_profile/widgets/danger_zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({
    bool isSaving = false,
    VoidCallback? onDeletePressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DangerZoneSection(
          isSaving: isSaving,
          onDeletePressed: onDeletePressed ?? () {},
        ),
      ),
    );
  }

  group('DangerZoneSection', () {
    group('Rendering', () {
      testWidgets('displays Danger Zone header', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Danger Zone'), findsOneWidget);
      });

      testWidgets('displays warning icon', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });

      testWidgets('displays Delete Account button text', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Delete Account'), findsOneWidget);
      });

      testWidgets('displays delete_outline icon in button', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('displays warning description text', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(
          find.textContaining('Once you delete your account'),
          findsOneWidget,
        );
      });
    });

    group('Idle state', () {
      testWidgets('delete button is enabled', (tester) async {
        await tester.pumpWidget(buildWidget());

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        expect(button.onPressed, isNotNull);
      });

      testWidgets('calls onDeletePressed when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          buildWidget(onDeletePressed: () => tapped = true),
        );

        await tester.tap(find.byType(OutlinedButton));

        expect(tapped, isTrue);
      });
    });

    group('Saving state', () {
      testWidgets('delete button is disabled while saving', (tester) async {
        await tester.pumpWidget(buildWidget(isSaving: true));

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('shows CircularProgressIndicator in button while saving',
              (tester) async {
            await tester.pumpWidget(buildWidget(isSaving: true));

            expect(find.byType(CircularProgressIndicator), findsOneWidget);
          });

      testWidgets('hides Delete Account text while saving', (tester) async {
        await tester.pumpWidget(buildWidget(isSaving: true));

        expect(find.text('Delete Account'), findsNothing);
      });

      testWidgets('does not call onDeletePressed when tapped while saving',
              (tester) async {
            var tapped = false;
            await tester.pumpWidget(
              buildWidget(isSaving: true, onDeletePressed: () => tapped = true),
            );

            await tester.tap(find.byType(OutlinedButton), warnIfMissed: false);

            expect(tapped, isFalse);
          });
    });
  });
}