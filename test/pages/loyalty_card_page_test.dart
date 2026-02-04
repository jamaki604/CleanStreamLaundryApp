import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';
import 'package:clean_stream_laundry_app/pages/loyalty_card_page.dart';
import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockLoyaltyViewModel mockViewModel;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue((_) {});
  });

  setUp(() {
    mockViewModel = MockLoyaltyViewModel();

    // Register mock in GetIt - ensure it's completely reset first
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoyaltyViewModel>()) {
      getIt.unregister<LoyaltyViewModel>();
    }
    getIt.registerSingleton<LoyaltyViewModel>(mockViewModel);

    // Setup default property values
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.errorMessage).thenReturn(null);
    when(() => mockViewModel.userName).thenReturn('Test User');
    when(() => mockViewModel.userBalance).thenReturn(25.50);
    when(() => mockViewModel.recentTransactions).thenReturn([]);
    when(() => mockViewModel.showPastTransactions).thenReturn(false);

    // Setup default method behaviors
    when(() => mockViewModel.initialize()).thenAnswer((_) async => {});
    when(() => mockViewModel.fetchTransactions()).thenAnswer((_) async => {});
    when(
      () => mockViewModel.toggleTransactionView(),
    ).thenAnswer((_) async => {});
    when(() => mockViewModel.addListener(any())).thenReturn(null);
    when(() => mockViewModel.removeListener(any())).thenReturn(null);
  });

  tearDown(() {
    // Properly unregister after each test
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoyaltyViewModel>()) {
      getIt.unregister<LoyaltyViewModel>();
    }
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => child),
          GoRoute(
            path: '/scanner',
            builder: (context, state) => const Scaffold(body: Text('Scanner')),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('Login')),
          ),
        ],
      ),
    );
  }

  group('LoyaltyPage Initialization', () {
    testWidgets('should call initialize on viewModel during initState', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));

      verify(() => mockViewModel.initialize()).called(1);
    });

    testWidgets('should add listener to viewModel', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));

      verify(() => mockViewModel.addListener(any())).called(1);
    });

    testWidgets('should display BasePage when not loading', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.byType(BasePage), findsOneWidget);
    });
  });

  group('Content Display', () {
    testWidgets('should display CreditCard with correct username', (
      tester,
    ) async {
      when(() => mockViewModel.userName).thenReturn('John Doe');

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.byType(CreditCard), findsOneWidget);
      final creditCard = tester.widget<CreditCard>(find.byType(CreditCard));
      expect(creditCard.username, equals('John Doe'));
    });

    testWidgets('should display default username when userName is null', (
      tester,
    ) async {
      when(() => mockViewModel.userName).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      final creditCard = tester.widget<CreditCard>(find.byType(CreditCard));
      expect(creditCard.username, equals('John Doe'));
    });

    testWidgets('should display correct balance with proper formatting', (
      tester,
    ) async {
      when(() => mockViewModel.userBalance).thenReturn(42.75);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Current Balance: \$42.75'), findsOneWidget);
    });

    testWidgets('should display balance with two decimal places', (
      tester,
    ) async {
      when(() => mockViewModel.userBalance).thenReturn(100.0);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Current Balance: \$100.00'), findsOneWidget);
    });

    testWidgets('should display default balance when userBalance is null', (
      tester,
    ) async {
      when(() => mockViewModel.userBalance).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Current Balance: \$0.00'), findsOneWidget);
    });

    testWidgets('should display Load card button with correct styling', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Load card'), findsOneWidget);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Load card'),
      );

      expect(button.onPressed, isNotNull);
    });

    testWidgets('should have scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('Transactions Display', () {
    testWidgets('should show "No transactions found" when list is empty', (
      tester,
    ) async {
      when(() => mockViewModel.recentTransactions).thenReturn([]);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('No transactions found.'), findsOneWidget);
      expect(find.text('Transactions'), findsNothing);
    });

    testWidgets('should display transaction header when transactions exist', (
      tester,
    ) async {
      when(
        () => mockViewModel.recentTransactions,
      ).thenReturn(['Transaction 1']);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('should display all transactions in list', (tester) async {
      when(() => mockViewModel.recentTransactions).thenReturn([
        'Loaded \$10.00 on 01/10/2025',
        'Used \$2.50 on 01/09/2025',
        'Loaded \$25.00 on 01/08/2025',
      ]);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Loaded \$10.00 on 01/10/2025'), findsOneWidget);
      expect(find.text('Used \$2.50 on 01/09/2025'), findsOneWidget);
      expect(find.text('Loaded \$25.00 on 01/08/2025'), findsOneWidget);
    });

    testWidgets(
      'should display Show More button when showPastTransactions is false',
      (tester) async {
        when(
          () => mockViewModel.recentTransactions,
        ).thenReturn(['Transaction 1']);
        when(() => mockViewModel.showPastTransactions).thenReturn(false);

        await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
        await tester.pump();

        expect(find.text('Show More'), findsOneWidget);
        expect(find.byIcon(Icons.expand_more), findsOneWidget);
      },
    );

    testWidgets(
      'should display Show Less button when showPastTransactions is true',
      (tester) async {
        when(
          () => mockViewModel.recentTransactions,
        ).thenReturn(['Transaction 1']);
        when(() => mockViewModel.showPastTransactions).thenReturn(true);

        await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
        await tester.pump();

        expect(find.text('Show Less'), findsOneWidget);
        expect(find.byIcon(Icons.expand_less), findsOneWidget);
      },
    );

    testWidgets('should call toggleTransactionView when Show More is tapped', (
      tester,
    ) async {
      when(
        () => mockViewModel.recentTransactions,
      ).thenReturn(['Transaction 1']);
      when(() => mockViewModel.showPastTransactions).thenReturn(false);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Show More'));
      await tester.pump();

      verify(() => mockViewModel.toggleTransactionView()).called(1);
    });

    testWidgets('should call toggleTransactionView when Show Less is tapped', (
      tester,
    ) async {
      when(
        () => mockViewModel.recentTransactions,
      ).thenReturn(['Transaction 1']);
      when(() => mockViewModel.showPastTransactions).thenReturn(true);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Show Less'));
      await tester.pump();

      verify(() => mockViewModel.toggleTransactionView()).called(1);
    });

    testWidgets('should display transaction cards with correct styling', (
      tester,
    ) async {
      when(
        () => mockViewModel.recentTransactions,
      ).thenReturn(['Transaction 1']);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.byType(Card), findsWidgets);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });
  });

  group('Error Handling', () {
    testWidgets('should show error dialog when errorMessage is set', (
      tester,
    ) async {
      when(() => mockViewModel.errorMessage).thenReturn('Test error message');

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump(); // Build initial frame
      await tester.pump(); // Process post-frame callback

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets(
      'should navigate to /scanner when error is "Failed to fetch balance"',
      (tester) async {
        when(
          () => mockViewModel.errorMessage,
        ).thenReturn('Failed to fetch balance');

        await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
        await tester.pump();
        await tester.pump();

        expect(find.text('Failed to fetch balance'), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.text('Scanner'), findsOneWidget);
      },
    );

    testWidgets('should navigate to /login for other errors', (tester) async {
      when(() => mockViewModel.errorMessage).thenReturn('User not known');

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();
      await tester.pump();

      expect(find.text('User not known'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should display error dialog only once', (tester) async {
      when(() => mockViewModel.errorMessage).thenReturn('Something went wrong');

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();
      await tester.pump();

      // Should only show one dialog with the title and message
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Error'), findsOneWidget); // Dialog title
      expect(
        find.text('Something went wrong'),
        findsOneWidget,
      ); // Error message
    });
  });

  group('Load Card Dialog', () {
    testWidgets('should open dialog when Load card button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      expect(find.text('Load Loyalty Card'), findsOneWidget);
      expect(
        find.text('Select an amount to add to your card.'),
        findsOneWidget,
      );
    });

    testWidgets('should initialize dialog with \$1.00 amount', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      expect(find.text('\$1.00'), findsOneWidget);
    });

    testWidgets('should increment amount by 25¢ when +25¢ is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+25¢'));
      await tester.pumpAndSettle();

      expect(find.text('\$1.25'), findsOneWidget);
    });

    testWidgets('should decrement amount by 25¢ when -25¢ is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      // Increment first
      await tester.tap(find.text('+25¢'));
      await tester.pumpAndSettle();

      // Then decrement
      await tester.tap(find.text('-25¢'));
      await tester.pumpAndSettle();

      expect(find.text('\$1.00'), findsOneWidget);
    });

    testWidgets('should disable -25¢ button at minimum amount', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      final decrementButton = find.widgetWithText(OutlinedButton, '-25¢');
      final button = tester.widget<OutlinedButton>(decrementButton);

      expect(button.onPressed, isNull);
    });

    testWidgets('should not go below \$1.00 minimum', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      // Try to decrement below minimum (button should be disabled)
      final decrementButton = find.widgetWithText(OutlinedButton, '-25¢');
      await tester.tap(decrementButton);
      await tester.pumpAndSettle();

      expect(find.text('\$1.00'), findsOneWidget);
    });

    testWidgets('should not go above \$500.00 maximum', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      // Tap increment many times to reach max
      final incrementButton = find.text('+25¢');
      for (int i = 0; i < 2000; i++) {
        await tester.tap(incrementButton);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('\$500.00'), findsOneWidget);

      // Button should be disabled
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, '+25¢'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should select \$10 when \$10 ChoiceChip is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('\$10'));
      await tester.pumpAndSettle();

      expect(find.text('\$10.00'), findsOneWidget);
    });

    testWidgets('should select \$15 when \$15 ChoiceChip is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('\$15'));
      await tester.pumpAndSettle();

      expect(find.text('\$15.00'), findsOneWidget);
    });

    testWidgets('should select \$25 when \$25 ChoiceChip is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('\$25'));
      await tester.pumpAndSettle();

      expect(find.text('\$25.00'), findsOneWidget);
    });

    testWidgets('should update slider when amount changes', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, equals(1.0));
    });

    testWidgets('should close dialog when Cancel is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      expect(find.text('Load Loyalty Card'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Load Loyalty Card'), findsNothing);
    });

    testWidgets('should have Pay button in dialog', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Pay'), findsOneWidget);
    });
  });

  group('Payment Handling', () {
    testWidgets(
      'should call loadCard with correct amount on successful payment',
      (tester) async {
        when(
          () => mockViewModel.loadCard(any()),
        ).thenAnswer((_) async => PaymentResult.success);
        when(() => mockViewModel.userBalance).thenReturn(25.0);

        await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
        await tester.pump();

        await tester.tap(find.text('Load card'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pay'));
        await tester.pumpAndSettle();

        verify(() => mockViewModel.loadCard(1.0)).called(1);
      },
    );

    testWidgets('should show success dialog on successful payment', (
      tester,
    ) async {
      when(
        () => mockViewModel.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);
      when(() => mockViewModel.userBalance).thenReturn(25.0);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(
        find.text(
          'Thank you! Your payment of \$1.00 was processed successfully.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should call fetchTransactions after successful payment', (
      tester,
    ) async {
      when(
        () => mockViewModel.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);
      when(() => mockViewModel.userBalance).thenReturn(25.0);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      verify(() => mockViewModel.fetchTransactions()).called(1);
    });

    testWidgets('should show canceled dialog when payment is canceled', (
      tester,
    ) async {
      when(
        () => mockViewModel.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.canceled);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      expect(find.text('Payment Canceled'), findsOneWidget);
      expect(find.text('Payment of \$1.00 was canceled.'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should show failed dialog when payment fails', (tester) async {
      when(
        () => mockViewModel.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.failed);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      expect(find.text('Payment Failed'), findsOneWidget);
      expect(
        find.text(
          'An error occurred while processing your payment. Please try again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should close status dialog when Done is tapped', (
      tester,
    ) async {
      when(
        () => mockViewModel.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);
      when(() => mockViewModel.userBalance).thenReturn(25.0);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      expect(find.text('Payment Successful!'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Payment Successful!'), findsNothing);
    });

    testWidgets('should handle custom amount payment', (tester) async {
      when(
        () => mockViewModel.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.success);
      when(() => mockViewModel.userBalance).thenReturn(25.0);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      // Set custom amount
      await tester.tap(find.text('\$25'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      verify(() => mockViewModel.loadCard(25.0)).called(1);
    });

    testWidgets('should not call fetchTransactions on failed payment', (
      tester,
    ) async {
      when(
        () => mockViewModel.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.failed);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      verifyNever(() => mockViewModel.fetchTransactions());
    });

    testWidgets('should not call fetchTransactions on canceled payment', (
      tester,
    ) async {
      when(
        () => mockViewModel.loadCard(any()),
      ).thenAnswer((_) async => PaymentResult.canceled);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      await tester.tap(find.text('Load card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      verifyNever(() => mockViewModel.fetchTransactions());
    });
  });

  group('Widget Lifecycle', () {
    testWidgets('should remove listener on dispose', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      // Navigate away to dispose the widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      verify(() => mockViewModel.removeListener(any())).called(1);
    });
  });

  group('Edge Cases', () {
    testWidgets('should handle null userName gracefully', (tester) async {
      when(() => mockViewModel.userName).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.byType(CreditCard), findsOneWidget);
      // Should use default 'John Doe'
    });

    testWidgets('should handle null userBalance gracefully', (tester) async {
      when(() => mockViewModel.userBalance).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Current Balance: \$0.00'), findsOneWidget);
    });

    testWidgets('should handle empty transaction list', (tester) async {
      when(() => mockViewModel.recentTransactions).thenReturn([]);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('No transactions found.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('should handle very large balance', (tester) async {
      when(() => mockViewModel.userBalance).thenReturn(9999.99);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Current Balance: \$9999.99'), findsOneWidget);
    });

    testWidgets('should handle zero balance', (tester) async {
      when(() => mockViewModel.userBalance).thenReturn(0.0);

      await tester.pumpWidget(createTestWidget(const LoyaltyPage()));
      await tester.pump();

      expect(find.text('Current Balance: \$0.00'), findsOneWidget);
    });
  });
}
