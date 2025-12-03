import 'package:clean_stream_laundry_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group("Custom App Bar Tests", () {

    test('CustomAppBar instantiates correctly', () {
      const customAppBar = CustomAppBar();
      expect(customAppBar, isA<CustomAppBar>());
    });

    test('CustomAppBar implements PreferredSizeWidget', () {
      const customAppBar = CustomAppBar();
      expect(customAppBar is PreferredSizeWidget, true);
    });

    testWidgets('CustomAppBar builds an AppBar widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('CustomAppBar uses theme primary color', (tester) async {
      const testColor = Colors.green;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(primary: testColor),
          ),
          home: Scaffold(
            appBar: const CustomAppBar(),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, testColor);
    });

    testWidgets('CustomAppBar renders correctly inside Scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(),
            body: const Text('Testing'),
          ),
        ),
      );

      expect(find.text('Testing'), findsOneWidget);
    });
  });
}
