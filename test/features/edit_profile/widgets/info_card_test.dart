import 'package:clean_stream_laundry_app/features/edit_profile/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({required String label, required String value}) {
    return MaterialApp(
      home: Scaffold(
        body: InfoCard(label: label, value: value),
      ),
    );
  }

  group('InfoCard', () {
    testWidgets('displays the label', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'Current', value: 'John Doe'));

      expect(find.text('Current'), findsOneWidget);
    });

    testWidgets('displays the value', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'Current', value: 'John Doe'));

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays both label and value together', (tester) async {
      await tester.pumpWidget(
        buildWidget(label: 'Email Address', value: 'test@example.com'),
      );

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('renders inside a Row', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'Current', value: 'Jane'));

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('handles empty value gracefully', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'Current', value: ''));

      expect(find.text('Current'), findsOneWidget);
    });
  });
}