import 'package:clean_stream_laundry_app/features/start_machine/widgets/tap_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TapToPayCard', () {
    Widget buildWidget() =>
        const MaterialApp(home: Scaffold(body: TapToPayCard()));

    testWidgets('displays Tap to Pay heading', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Tap to Pay'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.text('Pay at the machine reader with your mobile wallet.'),
        findsOneWidget,
      );
    });

    testWidgets('displays tap_and_play icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.tap_and_play), findsOneWidget);
    });

    testWidgets('invokes onTap when pressed', (tester) async {
      var didTap = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TapToPayCard(onTap: () => didTap = true)),
        ),
      );

      await tester.tap(find.text('Tap to Pay'));

      expect(didTap, isTrue);
    });
  });
}
