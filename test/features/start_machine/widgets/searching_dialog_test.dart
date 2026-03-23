import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/features/start_machine/widgets/searching_dialog.dart';

void main() {

  testWidgets('showSearchingDialog displays dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showSearchingDialog(
                      context,
                          () {},
                    ),
                    child: const Text('Open Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Finding Nearby Doors...'), findsOneWidget);
      expect(
        find.text('Please wait while we search for the nearest door.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
    },
  );

  testWidgets('Cancel button sets cancelSearch and closes dialog',
        (WidgetTester tester) async {
      cancelSearch = false;
      bool cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showSearchingDialog(
                      context,
                          () {
                        cancelCalled = true;
                      },
                    ),
                    child: const Text('Open Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Cancel'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(cancelSearch, true);
      expect(cancelCalled, true);
      expect(find.byType(Dialog), findsNothing);
    },
  );
}