import 'package:clean_stream_laundry_app/features/refund_request/widgets/disclaimer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget() {
    return const MaterialApp(
      home: Scaffold(body: DisclaimerCard()),
    );
  }

  group('RefundDisclaimerCard', () {
    testWidgets('displays info icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('displays review period text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.textContaining(
            'Refund requests are reviewed within 3–5 business days.'),
        findsOneWidget,
      );
    });

    testWidgets('displays loyalty card refund text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.textContaining(
            'Approved refunds will be returned to your loyalty card balance.'),
        findsOneWidget,
      );
    });

    testWidgets('displays denial policy text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(
        find.textContaining(
            'We reserve the right to deny requests that do not meet our refund policy criteria.'),
        findsOneWidget,
      );
    });

    testWidgets('has yellow background container', (tester) async {
      await tester.pumpWidget(buildWidget());

      final container = tester.widget<Container>(
        find
            .ancestor(
          of: find.byIcon(Icons.info_outline_rounded),
          matching: find.byType(Container),
        )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFFFDE7).withOpacity(0.8));
      expect(decoration.borderRadius, BorderRadius.circular(14));
    });
  });
}