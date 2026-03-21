import 'package:clean_stream_laundry_app/features/machine_payment/widgets/amount_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({
    String? machineName = 'Washer01',
    double? price = 3.50,
    bool paymentCompleted = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AmountCard(
          machineName: machineName,
          price: price,
          paymentCompleted: paymentCompleted,
        ),
      ),
    );
  }

  group('AmountCard', () {
    testWidgets('displays machine name', (tester) async {
      await tester.pumpWidget(buildWidget(machineName: 'Washer01'));
      expect(find.text('Machine Washer01'), findsOneWidget);
    });

    testWidgets('displays Amount Due when payment not completed', (tester) async {
      await tester.pumpWidget(buildWidget(paymentCompleted: false));
      expect(find.text('Amount Due'), findsOneWidget);
    });

    testWidgets('displays Payment Complete when payment is completed',
            (tester) async {
          await tester.pumpWidget(buildWidget(paymentCompleted: true));
          expect(find.text('Payment Complete'), findsOneWidget);
        });

    testWidgets('displays formatted price', (tester) async {
      await tester.pumpWidget(buildWidget(price: 3.50));
      expect(find.text('\$3.50'), findsOneWidget);
    });

    testWidgets('displays 0.00 when price is null', (tester) async {
      await tester.pumpWidget(buildWidget(price: null));
      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('displays laundry service icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.local_laundry_service), findsOneWidget);
    });
  });
}