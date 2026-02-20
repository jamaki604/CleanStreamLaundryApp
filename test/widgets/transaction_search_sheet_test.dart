import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/widgets/transactions_search_sheet.dart';

void main() {
  const transactions = [
    '01/10/2026 - Coffee - \$5.00',
    '02/14/2026 - Dinner - \$45.00',
    '03/01/2026 - Books - \$30.00',
  ];

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const TransactionSearchSheet(
                  transactions: transactions,
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('TransactionSearchSheet Widget Tests', () {
    testWidgets('renders all transactions initially',
            (WidgetTester tester) async {
          await tester.pumpWidget(buildTestWidget());

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.text(transactions[0]), findsOneWidget);
          expect(find.text(transactions[1]), findsOneWidget);
          expect(find.text(transactions[2]), findsOneWidget);
        });

    testWidgets('filters transactions based on search input',
            (WidgetTester tester) async {
          await tester.pumpWidget(buildTestWidget());

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), '02/14');
          await tester.pumpAndSettle();

          expect(find.text(transactions[1]), findsOneWidget);
          expect(find.text(transactions[0]), findsNothing);
          expect(find.text(transactions[2]), findsNothing);
        });

    testWidgets('is case insensitive',
            (WidgetTester tester) async {
          await tester.pumpWidget(buildTestWidget());

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'coffee');
          await tester.pumpAndSettle();

          expect(find.text(transactions[0]), findsOneWidget);
        });

    testWidgets('returns selected transaction when tapped',
            (WidgetTester tester) async {
          String? selected;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      selected = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) => const TransactionSearchSheet(
                          transactions: transactions,
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          await tester.tap(find.text(transactions[1]));
          await tester.pumpAndSettle();

          expect(selected, transactions[1]);
        });
  });
}
