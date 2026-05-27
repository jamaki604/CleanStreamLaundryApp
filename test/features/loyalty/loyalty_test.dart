import 'package:clean_stream_laundry_app/features/loyalty/loyalty.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:clean_stream_laundry_app/features/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/features/loyalty/widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockLoyaltyController mockController;

  setUpAll(() {
    registerFallbackValue((_) {});
  });

  setUp(() async {
    mockController = MockLoyaltyController();

    await GetIt.instance.reset();
    when(() => mockController.isLoading).thenReturn(false);
    when(() => mockController.errorMessage).thenReturn(null);
    when(() => mockController.userName).thenReturn('Test User');
    when(() => mockController.userBalance).thenReturn(25.50);
    when(() => mockController.userReward).thenReturn(0.0);
    when(() => mockController.recentTransactions).thenReturn([]);
    when(() => mockController.showPastTransactions).thenReturn(false);
    when(() => mockController.initialize()).thenAnswer((_) async {});
    when(() => mockController.fetchTransactions()).thenAnswer((_) async {});
    when(() => mockController.toggleTransactionView()).thenAnswer((_) async {});
    when(() => mockController.addListener(any())).thenReturn(null);
    when(() => mockController.removeListener(any())).thenReturn(null);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidget({bool openLoadCardOnStart = false}) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => LoyaltyPage(
              controller: mockController,
              openLoadCardOnStart: openLoadCardOnStart,
            ),
          ),
          GoRoute(
            path: '/scanner',
            builder: (_, _) => const Scaffold(body: Text('Scanner')),
          ),
          GoRoute(
            path: '/login',
            builder: (_, _) => const Scaffold(body: Text('Login')),
          ),
        ],
      ),
    );
  }

  Future<void> openLoadCardDialog(WidgetTester tester) async {
    await tester.tap(find.text('Load card'));
    await tester.pumpAndSettle();
  }

  Future<void> acceptLoyaltyTerms(WidgetTester tester) async {
    await tester.tap(find.text('I agree to the Loyalty Card Terms.'));
    await tester.pumpAndSettle();
  }

  Future<void> tapPay(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Pay'));
    await tester.pumpAndSettle();
  }

  group('Initialization', () {
    testWidgets('calls initialize on viewModel during initState', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      verify(() => mockController.initialize()).called(1);
    });

    testWidgets('adds listener to viewModel', (tester) async {
      await tester.pumpWidget(createWidget());
      verify(() => mockController.addListener(any())).called(1);
    });

    testWidgets('removes listener on dispose', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      verify(() => mockController.removeListener(any())).called(1);
    });

    testWidgets('displays BasePage when not loading', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.byType(BasePage), findsOneWidget);
    });
  });

  group('Content display', () {
    testWidgets('displays CreditCard with correct username', (tester) async {
      when(() => mockController.userName).thenReturn('Jane Doe');
      await tester.pumpWidget(createWidget());
      await tester.pump();

      final card = tester.widget<CreditCard>(find.byType(CreditCard));
      expect(card.username, 'Jane Doe');
    });

    testWidgets('displays default username when userName is null', (
      tester,
    ) async {
      when(() => mockController.userName).thenReturn(null);
      await tester.pumpWidget(createWidget());
      await tester.pump();

      final card = tester.widget<CreditCard>(find.byType(CreditCard));
      expect(card.username, 'John Doe');
    });

    testWidgets('displays correct balance with two decimal places', (
      tester,
    ) async {
      when(() => mockController.userBalance).thenReturn(42.75);
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Loyalty Balance: \$42.75'), findsOneWidget);
    });

    testWidgets('displays default balance when userBalance is null', (
      tester,
    ) async {
      when(() => mockController.userBalance).thenReturn(null);
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Loyalty Balance: \$0.00'), findsOneWidget);
    });

    testWidgets('displays Load card button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.text('Load card'), findsOneWidget);
    });

    testWidgets('opens load card dialog from route trigger', (tester) async {
      await tester.pumpWidget(createWidget(openLoadCardOnStart: true));
      await tester.pumpAndSettle();

      expect(find.text('Load Loyalty Card'), findsOneWidget);
    });

    testWidgets('displays info button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays zero balance correctly', (tester) async {
      when(() => mockController.userBalance).thenReturn(0.0);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.text('Loyalty Balance: \$0.00'), findsOneWidget);
    });

    testWidgets('displays large balance correctly', (tester) async {
      when(() => mockController.userBalance).thenReturn(9999.99);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.text('Loyalty Balance: \$9999.99'), findsOneWidget);
    });
  });

  group('Transactions', () {
    testWidgets('shows No transactions found when list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.text('No transactions found.'), findsOneWidget);
      expect(find.text('Transactions'), findsNothing);
    });

    testWidgets('shows transaction header when transactions exist', (
      tester,
    ) async {
      when(
        () => mockController.recentTransactions,
      ).thenReturn(['Test transaction']);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('shows Show More when showPastTransactions is false', (
      tester,
    ) async {
      when(
        () => mockController.recentTransactions,
      ).thenReturn(['Test transaction']);
      when(() => mockController.showPastTransactions).thenReturn(false);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.text('Show More'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('shows Show Less when showPastTransactions is true', (
      tester,
    ) async {
      when(
        () => mockController.recentTransactions,
      ).thenReturn(['Test transaction']);
      when(() => mockController.showPastTransactions).thenReturn(true);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.text('Show Less'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('calls toggleTransactionView when Show More tapped', (
      tester,
    ) async {
      when(
        () => mockController.recentTransactions,
      ).thenReturn(['Test transaction']);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.tap(find.text('Show More'));
      await tester.pump();
      verify(() => mockController.toggleTransactionView()).called(1);
    });

    testWidgets('calls toggleTransactionView when Show Less tapped', (
      tester,
    ) async {
      when(
        () => mockController.recentTransactions,
      ).thenReturn(['Test transaction']);
      when(() => mockController.showPastTransactions).thenReturn(true);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.tap(find.text('Show Less'));
      await tester.pump();
      verify(() => mockController.toggleTransactionView()).called(1);
    });

    testWidgets('displays transaction cards with receipt icon', (tester) async {
      when(
        () => mockController.recentTransactions,
      ).thenReturn(['Test transaction']);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      expect(find.byType(Card, skipOffstage: false), findsWidgets);
      expect(
        find.byIcon(Icons.receipt_long, skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  group('Error handling', () {
    testWidgets('shows error dialog when errorMessage is set', (tester) async {
      when(() => mockController.errorMessage).thenReturn('Test error message');
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets(
      'navigates to /scanner when error is "Failed to fetch balance"',
      (tester) async {
        when(
          () => mockController.errorMessage,
        ).thenReturn('Failed to fetch balance');
        await tester.pumpWidget(createWidget());
        await tester.pump();
        await tester.pump();

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.text('Scanner'), findsOneWidget);
      },
    );

    testWidgets('navigates to /login for other errors', (tester) async {
      when(() => mockController.errorMessage).thenReturn('User not known');
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('displays only one error dialog', (tester) async {
      when(
        () => mockController.errorMessage,
      ).thenReturn('Something went wrong');
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('Reward info dialog', () {
    testWidgets('opens reward info dialog when info button tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      expect(find.text('Rewards program'), findsOneWidget);
      expect(
        find.text(
          'For every \$20 you spend, you get an extra \$5 automatically added to your loyalty balance.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('closes reward info dialog when Got it tapped', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Rewards program'), findsNothing);
    });
  });

  group('Payment handling', () {
    testWidgets('calls loadCard with correct amount on Pay tap', (
      tester,
    ) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);
      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      verify(() => mockController.loadCard(1.0)).called(1);
    });

    testWidgets('shows success dialog on successful payment', (tester) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);
      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(
        find.text(
          'Thank you! Your payment of \$1.00 was processed successfully.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls fetchTransactions after successful payment', (
      tester,
    ) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);
      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      verify(() => mockController.fetchTransactions()).called(1);
    });

    testWidgets('shows canceled dialog when payment is canceled', (
      tester,
    ) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.canceled);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);
      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      expect(find.text('Payment Canceled'), findsOneWidget);
      expect(find.text('Payment of \$1.00 was canceled.'), findsOneWidget);
    });

    testWidgets('shows failed dialog when payment fails', (tester) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.failed);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);
      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      expect(find.text('Payment Failed'), findsOneWidget);
      expect(
        find.text(
          'An error occurred while processing your payment. Please try again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not call fetchTransactions on failed payment', (
      tester,
    ) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.failed);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);
      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      verifyNever(() => mockController.fetchTransactions());
    });

    testWidgets('does not call fetchTransactions on canceled payment', (
      tester,
    ) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.canceled);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);
      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      verifyNever(() => mockController.fetchTransactions());
    });

    testWidgets('handles custom amount payment', (tester) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);

      await tester.tap(find.text('\$25'));
      await tester.pumpAndSettle();

      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      verify(() => mockController.loadCard(25.0)).called(1);
    });

    testWidgets('closes success dialog when Done tapped', (tester) async {
      when(
        () => mockController.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await openLoadCardDialog(tester);
      await acceptLoyaltyTerms(tester);
      await tapPay(tester);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Payment Successful!'), findsNothing);
    });
  });
}
