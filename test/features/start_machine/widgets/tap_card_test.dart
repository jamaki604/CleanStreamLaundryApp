import 'package:clean_stream_laundry_app/features/start_machine/widgets/tap_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TapToPayCard', () {
    Widget buildWidget() => const MaterialApp(
      home: Scaffold(body: TapToPayCard()),
    );

    testWidgets('displays Tap To Pay heading', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Tap To Pay'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Tap phone to machine to pay'), findsOneWidget);
    });

    testWidgets('displays tap_and_play icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.tap_and_play), findsOneWidget);
    });

    testWidgets('has blue border', (tester) async {
      await tester.pumpWidget(buildWidget());
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Tap To Pay'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border?;
      expect(border?.top.color, Colors.blue);
    });
  });
}