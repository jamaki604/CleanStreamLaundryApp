import 'package:clean_stream_laundry_app/widgets/qr_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Large Button Tests", () {
    test('Large Button instantiates correctly', () {
      const largeButton = QRButton(
        headLineText: "Test Headline",
        descriptionText: "Test Description",
        icon: Icons.shield,
      );
      expect(largeButton, isA<QRButton>());
    });

    testWidgets('Tests that the correct headline is found', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QRButton(
            headLineText: "Test Headline",
            descriptionText: "Test Description",
            icon: Icons.shield,
          ),
        ),
      );

      expect(find.text("Test Headline"), findsOneWidget);
    });

    testWidgets('Tests that the correct description is found', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QRButton(
            headLineText: "Test Headline",
            descriptionText: "Test Description",
            icon: Icons.shield,
          ),
        ),
      );

      expect(find.text("Test Description"), findsOneWidget);
    });

    testWidgets('Tests that the correct icon is found', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QRButton(
            headLineText: "Test Headline",
            descriptionText: "Test Description",
            icon: Icons.shield,
          ),
        ),
      );

      expect(find.byIcon(Icons.shield), findsOneWidget);
    });
  });
}
