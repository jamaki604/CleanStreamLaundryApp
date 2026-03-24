import 'package:clean_stream_laundry_app/features/monthly_report/widgets/month_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, double> buildData({
    double directWasher = 0,
    double loyaltyWasher = 0,
    double directDryer = 0,
    double loyaltyDryer = 0,
    double loyaltyCard = 0,
  }) =>
      {
        'directWasher': directWasher,
        'loyaltyWasher': loyaltyWasher,
        'directDryer': directDryer,
        'loyaltyDryer': loyaltyDryer,
        'loyaltyCard': loyaltyCard,
        'Rewards': 0.0,
      };

  Widget buildWidget({
    String month = 'Jan 2025',
    Map<String, double>? data,
    Color cardBackgroundColor = Colors.white,
    Color cardTextColor = Colors.black,
    Color primaryColor = Colors.blue,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MonthCard(
          month: month,
          data: data ?? buildData(),
          cardBackgroundColor: cardBackgroundColor,
          cardTextColor: cardTextColor,
          primaryColor: primaryColor,
        ),
      ),
    );
  }

  group('MonthReportCard', () {
    group('Rendering', () {
      testWidgets('displays month label', (tester) async {
        await tester.pumpWidget(buildWidget(month: 'Mar 2025'));
        expect(find.text('Mar 2025'), findsOneWidget);
      });

      testWidgets('displays total as sum of direct + loyalty card amounts',
              (tester) async {
            await tester.pumpWidget(buildWidget(
              data: buildData(
                directWasher: 2.50,
                directDryer: 1.75,
                loyaltyCard: 10.00,
              ),
            ));
            expect(find.text('\$14.25'), findsOneWidget);
          });

      testWidgets('displays all five category labels', (tester) async {
        await tester.pumpWidget(buildWidget(data: buildData()));

        expect(find.text('Direct Washer Payments'), findsOneWidget);
        expect(find.text('Loyalty Washer Payments'), findsOneWidget);
        expect(find.text('Direct Dryer Payments'), findsOneWidget);
        expect(find.text('Loyalty Dryer Payments'), findsOneWidget);
        expect(find.text('Loyalty Card Loads'), findsOneWidget);
      });

      testWidgets('displays correct amounts for each category', (tester) async {
        await tester.pumpWidget(buildWidget(
          data: buildData(
            directWasher: 2.50,
            loyaltyWasher: 1.00,
            directDryer: 1.75,
            loyaltyDryer: 0.50,
            loyaltyCard: 5.00,
          ),
        ));

        expect(find.text('\$2.50'), findsWidgets);
        expect(find.text('\$1.00'), findsWidgets);
        expect(find.text('\$1.75'), findsWidgets);
        expect(find.text('\$0.50'), findsWidgets);
        expect(find.text('\$5.00'), findsWidgets);
      });

      testWidgets('displays divider', (tester) async {
        await tester.pumpWidget(buildWidget());
        expect(find.byType(Divider), findsOneWidget);
      });

      testWidgets('card has bottom margin of 16', (tester) async {
        await tester.pumpWidget(buildWidget());
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.margin, const EdgeInsets.only(bottom: 16));
      });

      testWidgets('shows zero for empty categories', (tester) async {
        await tester.pumpWidget(buildWidget(
          data: buildData(directWasher: 5.00),
        ));
        expect(find.text('\$0.00'), findsWidgets);
      });
    });
  });
}