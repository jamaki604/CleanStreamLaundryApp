import 'package:clean_stream_laundry_app/features/machine_payment/widgets/washer_controls_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late double? receivedCost;

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: WasherControlsCard(
          onCycleChanged: (cost) => receivedCost = cost,
        ),
      ),
    );
  }

  setUp(() {
    receivedCost = null;
  });

  testWidgets('renders all four washer cycle buttons', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Hot Heavy'), findsOneWidget);
    expect(find.text('Hot Normal'), findsOneWidget);
    expect(find.text('Cold Heavy'), findsOneWidget);
    expect(find.text('Cold Normal'), findsOneWidget);
  });

  testWidgets('selecting Hot Heavy updates state and cost', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Hot Heavy'));
    await tester.pump();

    expect(receivedCost, 0.5);

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Hot Heavy'));
    expect((button.style?.backgroundColor?.resolve({})) , Colors.green);
  });

  testWidgets('selecting Hot Normal updates state and cost', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Hot Normal'));
    await tester.pump();

    expect(receivedCost, 0.25);

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Hot Normal'));
    expect((button.style?.backgroundColor?.resolve({})), Colors.green);
  });

  testWidgets('selecting Cold Heavy updates state and cost', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Cold Heavy'));
    await tester.pump();

    expect(receivedCost, 0.25);

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Cold Heavy'));
    expect((button.style?.backgroundColor?.resolve({})), Colors.green);
  });

  testWidgets('selecting Cold Normal updates state and cost', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Cold Normal'));
    await tester.pump();

    expect(receivedCost, 0);

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Cold Normal'));
    expect((button.style?.backgroundColor?.resolve({})), Colors.green);
  });

  testWidgets('only one button is selected at a time', (tester) async {
    await tester.pumpWidget(createTestWidget());

    // Select Hot Heavy
    await tester.tap(find.text('Hot Heavy'));
    await tester.pump();

    ElevatedButton hotHeavy = tester.widget(find.widgetWithText(ElevatedButton, 'Hot Heavy'));
    ElevatedButton hotNormal = tester.widget(find.widgetWithText(ElevatedButton, 'Hot Normal'));

    expect(hotHeavy.style?.backgroundColor?.resolve({}), Colors.green);
    expect(hotNormal.style?.backgroundColor?.resolve({}), isNot(Colors.green));

    // Select Hot Normal
    await tester.tap(find.text('Hot Normal'));
    await tester.pump();

    hotHeavy = tester.widget(find.widgetWithText(ElevatedButton, 'Hot Heavy'));
    hotNormal = tester.widget(find.widgetWithText(ElevatedButton, 'Hot Normal'));

    expect(hotHeavy.style?.backgroundColor?.resolve({}), isNot(Colors.green));
    expect(hotNormal.style?.backgroundColor?.resolve({}), Colors.green);
  });

  testWidgets('callback fires exactly once per tap', (tester) async {
    int callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WasherControlsCard(
            onCycleChanged: (_) => callCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Hot Heavy'));
    await tester.pump();

    expect(callCount, 1);

    await tester.tap(find.text('Cold Normal'));
    await tester.pump();

    expect(callCount, 2);
  });
}