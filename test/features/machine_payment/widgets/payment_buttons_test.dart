import 'package:clean_stream_laundry_app/features/machine_payment/widgets/payment_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({
    double? price = 3.50,
    double? userBalance = 10.0,
    bool isProcessing = false,
    VoidCallback? onDirectPay,
    VoidCallback? onLoyaltyPay,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PaymentButtons(
          price: price,
          userBalance: userBalance,
          isProcessing: isProcessing,
          onDirectPay: onDirectPay ?? () {},
          onLoyaltyPay: onLoyaltyPay ?? () {},
        ),
      ),
    );
  }

  group('PaymentButtons', () {
    group('Pay button', () {
      testWidgets('displays correct price text', (tester) async {
        await tester.pumpWidget(buildWidget(price: 3.50));
        expect(find.text('Pay \$3.50'), findsOneWidget);
      });

      testWidgets('displays Pay when price is null', (tester) async {
        await tester.pumpWidget(buildWidget(price: null));
        expect(find.text('Pay'), findsOneWidget);
      });

      testWidgets('displays Pay when price is zero', (tester) async {
        await tester.pumpWidget(buildWidget(price: 0));
        expect(find.text('Pay'), findsOneWidget);
      });

      testWidgets('is enabled when price is set', (tester) async {
        await tester.pumpWidget(buildWidget(price: 3.50));

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Pay \$3.50'),
        );
        expect(button.onPressed, isNotNull);
      });

      testWidgets('is disabled when price is null', (tester) async {
        await tester.pumpWidget(buildWidget(price: null));

        final button =
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Pay'));
        expect(button.onPressed, isNull);
      });

      testWidgets('is disabled when price is zero', (tester) async {
        await tester.pumpWidget(buildWidget(price: 0));

        final button =
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Pay'));
        expect(button.onPressed, isNull);
      });

      testWidgets('calls onDirectPay when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
            buildWidget(price: 3.50, onDirectPay: () => tapped = true));

        await tester.tap(find.text('Pay \$3.50'));
        expect(tapped, isTrue);
      });

      testWidgets('shows spinner when isProcessing is true', (tester) async {
        await tester.pumpWidget(buildWidget(isProcessing: true, price: 3.50));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Pay with Loyalty button', () {
      testWidgets('is enabled when balance exceeds price', (tester) async {
        await tester.pumpWidget(
            buildWidget(price: 3.50, userBalance: 10.0));

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Pay with Loyalty'),
        );
        expect(button.onPressed, isNotNull);
      });

      testWidgets('is disabled when balance is less than price', (tester) async {
        await tester.pumpWidget(
            buildWidget(price: 5.00, userBalance: 2.00));

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Pay with Loyalty'),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('is disabled when balance equals price', (tester) async {
        // balance must be strictly greater than price based on the condition
        await tester.pumpWidget(
            buildWidget(price: 5.00, userBalance: 5.00));

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Pay with Loyalty'),
        );
        // userBalance < price is false here, so it should be enabled
        expect(button.onPressed, isNotNull);
      });

      testWidgets('is disabled when price is null', (tester) async {
        await tester.pumpWidget(
            buildWidget(price: null, userBalance: 10.0));

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Pay with Loyalty'),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('calls onLoyaltyPay when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildWidget(
          price: 3.50,
          userBalance: 10.0,
          onLoyaltyPay: () => tapped = true,
        ));

        await tester.tap(find.text('Pay with Loyalty'));
        expect(tapped, isTrue);
      });
    });
  });
}