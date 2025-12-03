import 'package:clean_stream_laundry_app/widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {

  Widget wrapWithRouter(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => child,
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group("Credit Card tests", () {

    test('Credit Card instantiates correctly', () {
      const creditCardPage = CreditCard(username: "Test Username");
      expect(creditCardPage, isA<CreditCard>());
    });

    test('Test that username appears on the screen', () {
      const creditCardPage = CreditCard(username: "Test Username");
      expect(creditCardPage, isA<CreditCard>());
    });

    testWidgets('renders the username correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(CreditCard(username: "Test Username")),
      );

      expect(find.text("Test Username"), findsOneWidget);
    });

    testWidgets('renders the slogan image', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(CreditCard(username: "Test Username")),
      );

      expect(find.byKey(Key('slogan')), findsOneWidget);;
    });

    testWidgets('renders the Icon image', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(CreditCard(username: "Test Username")),
      );

      expect(find.byKey(Key('icon')), findsOneWidget);;
    });

    testWidgets('renders the cardChip image', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(CreditCard(username: "Test Username")),
      );

      expect(find.byKey(Key('cardChip')), findsOneWidget);;
    });

    testWidgets('renders the mastercard image', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(CreditCard(username: "Test Username")),
      );

      expect(find.byKey(Key('mastercard')), findsOneWidget);;
    });

    testWidgets('card number is rendered correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(CreditCard(username: "Test Username")),
      );

      expect(find.text("1234   5678   9012   3456"), findsOneWidget);
    });

    testWidgets('falls back to John Doe when username is null', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(const CreditCard(username: null)),
      );

      expect(find.text("John Doe"), findsOneWidget);
    });

    testWidgets('falls back to John Doe when username is empty', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(const CreditCard(username: "")),
      );

      expect(find.text("John Doe"), findsOneWidget);
    });


  });
}
