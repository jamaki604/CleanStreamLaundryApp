import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/pages/loyalty_card_page.dart';
import 'package:clean_stream_laundry_app/widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';

class MockAuthService extends Mock implements AuthService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockProfileService extends Mock implements ProfileService {}

class MockLoyaltyViewModel extends Mock implements LoyaltyViewModel {}

void main() {
  late MockAuthService mockAuthService;
  late MockTransactionService mockTransactionService;
  late MockProfileService mockProfileService;
  late MockLoyaltyViewModel mockLoyaltyViewModel;
  late GoRouter router;

  final List<Map<String, dynamic>> fiveMockRawTransactions = List.generate(
    5,
    (index) => {
      'id': 'mock-id-$index',
      'amount': 10.0 + index,
      'description': 'Item $index',
      'type': 'test type',
      'created_at': DateTime.now()
          .subtract(Duration(days: index))
          .toIso8601String(),
    },
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockTransactionService = MockTransactionService();
    mockProfileService = MockProfileService();
    mockLoyaltyViewModel = MockLoyaltyViewModel();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }
    if (getIt.isRegistered<TransactionService>()) {
      getIt.unregister<TransactionService>();
    }
    if (getIt.isRegistered<ProfileService>()) {
      getIt.unregister<ProfileService>();
    }
    if (getIt.isRegistered<LoyaltyViewModel>()) {
      getIt.unregister<LoyaltyViewModel>();
    }

    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
    getIt.registerSingleton<ProfileService>(mockProfileService);
    getIt.registerSingleton<LoyaltyViewModel>(mockLoyaltyViewModel);

    when(
      () => mockLoyaltyViewModel.initialize(),
    ).thenAnswer((_) async {}); // FIX: Return Future<void>
    when(
      () => mockLoyaltyViewModel.toggleTransactionView(),
    ).thenAnswer((_) async {});
    when(
      () => mockLoyaltyViewModel.fetchTransactions(),
    ).thenAnswer((_) async {});
    when(
      () => mockLoyaltyViewModel.loadCard(any()),
    ).thenAnswer((_) async => PaymentResult.success);

    // Stub properties
    when(() => mockLoyaltyViewModel.userBalance).thenReturn(50.0);
    when(() => mockLoyaltyViewModel.userName).thenReturn('Test User');
    when(() => mockLoyaltyViewModel.isLoading).thenReturn(false);
    when(() => mockLoyaltyViewModel.errorMessage).thenReturn(null);
    when(() => mockLoyaltyViewModel.recentTransactions).thenReturn([]);
    when(() => mockLoyaltyViewModel.showPastTransactions).thenReturn(false);

    when(() => mockLoyaltyViewModel.recentTransactions).thenReturn([
      'Transaction 1',
      'Transaction 2',
      'Transaction 3',
      "Transaction 4",
    ]);
    when(() => mockLoyaltyViewModel.showPastTransactions).thenReturn(false);

    when(() => mockLoyaltyViewModel.toggleTransactionView()).thenAnswer((
      _,
    ) async {
      // Simulate expanding the list
      when(() => mockLoyaltyViewModel.showPastTransactions).thenReturn(true);
      when(() => mockLoyaltyViewModel.recentTransactions).thenReturn([
        'Transaction 1',
        'Transaction 2',
        'Transaction 3',
        'Transaction 4',
        'Transaction 5',
      ]);
    });

    // Stub addListener and removeListener (required for ChangeNotifier)
    when(() => mockLoyaltyViewModel.addListener(any())).thenReturn(null);
    when(() => mockLoyaltyViewModel.removeListener(any())).thenReturn(null);

    when(() => mockAuthService.getCurrentUserId).thenReturn('test-user-id');

    when(
      () => mockProfileService.getUserBalanceById('test-user-id'),
    ).thenAnswer((_) async => {'balance': 50.0, 'full_name': 'Test User'});

    when(
      () => mockTransactionService.getTransactionsForUser(),
    ).thenAnswer((_) async => []);

    router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => LoyaltyPage()),
        GoRoute(
          path: '/login',
          builder: (context, state) => Scaffold(body: Text('Login Page')),
        ),
        GoRoute(
          path: '/scanner',
          builder: (context, state) => Scaffold(body: Text('Scanner Page')),
        ),
      ],
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    return MaterialApp.router(routerConfig: router);
  }

  group('LoyaltyPage Widget Tests', () {
    testWidgets('Displays the CreditCard widget after loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(
        find.byType(CreditCard),
        findsOneWidget,
        reason:
            'The CreditCard widget should be displayed after data is fetched.',
      );
    });

    testWidgets('Displays the Load card button after loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Load card'),
        findsOneWidget,
        reason:
            'The "Load card" ElevatedButton should be displayed and functional.',
      );
    });

    testWidgets('Displays the correct username after fetching data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(
        find.text('Test User'),
        findsOneWidget,
        reason: 'Should display the mocked full_name (Test User).',
      );

      verify(
        () => mockProfileService.getUserBalanceById('test-user-id'),
      ).called(1);
    });

    testWidgets('Displays the correct current balance after fetching data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(
        find.text('Current Balance: \$50.00'),
        findsOneWidget,
        reason:
            'Should display the mocked user balance formatted to two decimal places.',
      );
    });

    testWidgets('Displays "No recent transactions" when none are fetched', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.text('Transactions'), findsOneWidget);

      expect(
        find.text('No recent transactions'),
        findsOneWidget,
        reason:
            'Should display the default message when the transaction list is empty.',
      );

      expect(
        find.byType(ListTile),
        findsNothing,
        reason: 'Should not display any ListTile when transactions are empty.',
      );
    });

    testWidgets('Find Show More/Less text)', (WidgetTester tester) async {
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => fiveMockRawTransactions);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Show'),
        findsOneWidget,
        reason:
            'The text "Show" (part of "Show More/Less") should be visible on the page.',
      );
    });

    testWidgets(
      'Load card button opens the load amount dialog with pay button',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final loadCardButton = find.widgetWithText(ElevatedButton, 'Load card');
        await tester.tap(loadCardButton);
        await tester.pump();

        expect(
          find.byType(AlertDialog),
          findsOneWidget,
          reason: 'The AlertDialog for loading card should be displayed.',
        );

        expect(
          find.widgetWithText(ElevatedButton, 'Pay'),
          findsOneWidget,
          reason: 'The dialog must contain a "Pay" ElevatedButton.',
        );

        final cancelButton = find.widgetWithText(TextButton, 'Cancel');
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(
          find.byType(AlertDialog),
          findsNothing,
          reason: 'Dialog should be dismissed.',
        );
      },
    );

    testWidgets(
      'Shows error dialog and navigates to login when user is not known',
      (WidgetTester tester) async {
        when(() => mockAuthService.getCurrentUserId).thenReturn(null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('User not known'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);

        final okButton = find.widgetWithText(TextButton, 'OK');
        await tester.tap(okButton);
        await tester.pumpAndSettle();

        expect(find.text('Login Page'), findsOneWidget);
      },
    );

    testWidgets(
      'Shows error dialog and navigates to scanner when balance fetch fails',
      (WidgetTester tester) async {
        when(
          () => mockProfileService.getUserBalanceById('test-user-id'),
        ).thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Failed to fetch balance'), findsOneWidget);

        final okButton = find.widgetWithText(TextButton, 'OK');
        await tester.tap(okButton);
        await tester.pumpAndSettle();

        expect(find.text('Scanner Page'), findsOneWidget);
      },
    );

    testWidgets(
      'Displays default values when getUserBalanceById returns null',
      (WidgetTester tester) async {
        when(
          () => mockProfileService.getUserBalanceById('test-user-id'),
        ).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Current Balance: \$0.00'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
      },
    );

    testWidgets('Displays transactions when fetched successfully', (
      WidgetTester tester,
    ) async {
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => fiveMockRawTransactions.take(3).toList());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.receipt_long), findsAtLeastNWidgets(1));
    });

    testWidgets('Show More button expands transaction list', (
      WidgetTester tester,
    ) async {
      when(
        () => mockTransactionService.getTransactionsForUser(),
      ).thenAnswer((_) async => fiveMockRawTransactions);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Show More'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      final showMoreButton = find.text('Show More');
      await tester.tap(showMoreButton);
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Show Less'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
      verify(() => mockTransactionService.getTransactionsForUser()).called(2);
    });

    testWidgets('Verify styling of load card dialog elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final loadCardButton = find.widgetWithText(ElevatedButton, 'Load card');
      await tester.tap(loadCardButton);
      await tester.pump();

      // Verify dialog title
      expect(find.text('Load Loyalty Card'), findsOneWidget);

      // Verify initial amount display
      expect(find.text('\$1.00'), findsOneWidget);

      // Verify choice chips exist
      expect(find.text('\$10'), findsOneWidget);
      expect(find.text('\$15'), findsOneWidget);
      expect(find.text('\$25'), findsOneWidget);

      // Verify increment/decrement buttons
      expect(find.text('-25¢'), findsOneWidget);
      expect(find.text('+25¢'), findsOneWidget);

      // Verify slider exists
      expect(find.byType(Slider), findsOneWidget);

      // Verify action buttons
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Pay'), findsOneWidget);

      // Verify descriptive text
      expect(
        find.text('Select an amount to add to your card.'),
        findsOneWidget,
      );

      // Test decrement button is disabled at minimum (1.0)
      final decrementButton = find.widgetWithText(OutlinedButton, '-25¢');
      final OutlinedButton decrementWidget = tester.widget(decrementButton);
      expect(decrementWidget.onPressed, isNull); // Should be disabled at 1.0

      // Test increment button functionality
      final incrementButton = find.widgetWithText(OutlinedButton, '+25¢');
      await tester.tap(incrementButton);
      await tester.pump();
      expect(find.text('\$1.25'), findsOneWidget);

      // Verify decrement is now enabled
      await tester.tap(decrementButton);
      await tester.pump();
      expect(find.text('\$1.00'), findsOneWidget);

      // Test choice chip selection
      await tester.tap(find.text('\$10'));
      await tester.pump();
      expect(find.text('\$10.00'), findsOneWidget);

      // Verify slider properties
      final Slider sliderWidget = tester.widget(find.byType(Slider));
      expect(sliderWidget.min, equals(1.0));
      expect(sliderWidget.max, equals(50.0));
      expect(sliderWidget.value, equals(10.0));
    });
  });
}
