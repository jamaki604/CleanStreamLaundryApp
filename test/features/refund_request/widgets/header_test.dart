import 'package:clean_stream_laundry_app/features/refund_request/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(
      home: Scaffold(body: Header()),
    );
  }

  group('Header', () {
    testWidgets('displays receipt_long_rounded icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('displays Submit a Refund Request title', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Submit a Refund Request'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.text(
          'Select a transaction and describe your issue. '
              'Our team will review it shortly.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('title has bold font weight', (tester) async {
      await tester.pumpWidget(buildWidget());
      final text = tester.widget<Text>(find.text('Submit a Refund Request'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renders inside a Row', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(Row), findsOneWidget);
    });
  });
}