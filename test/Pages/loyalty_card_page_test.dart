import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/profile_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:clean_stream_laundry_app/Pages/loyalty_card_page.dart';
import 'package:clean_stream_laundry_app/Widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthService extends Mock implements AuthService {}
class MockTransactionService extends Mock implements TransactionService {}
class MockProfileService extends Mock implements ProfileService {}

void main() {
  late MockAuthService mockAuthService;
  late MockTransactionService mockTransactionService;
  late MockProfileService mockProfileService;
  late GoRouter router;

  final List<Map<String, dynamic>> fiveMockRawTransactions = List.generate(
    5,
        (index) => {
      'id': 'mock-id-$index',
      'amount': 10.0 + index,
      'description': 'Item $index',
      'type': 'test type',
      'created_at': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
    },
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockTransactionService = MockTransactionService();
    mockProfileService = MockProfileService();

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

    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
    getIt.registerSingleton<ProfileService>(mockProfileService);

    when(() => mockAuthService.getCurrentUserId).thenReturn('test-user-id');

    when(() => mockProfileService.getUserBalanceById('test-user-id'))
        .thenAnswer((_) async => {'balance': 50.0, 'full_name': 'Test User'});

    when(() => mockTransactionService.getTransactionsForUser())
        .thenAnswer((_) async => []);

    router = GoRouter(
      routes: [GoRoute(path: '/', builder: (context, state) => LoyaltyPage())],
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    return MaterialApp.router(routerConfig: router);
  }


  group('LoyaltyPage Widget Tests', () {
      testWidgets('Displays the CreditCard widget after loading', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.byType(CreditCard), findsOneWidget,
            reason: 'The CreditCard widget should be displayed after data is fetched.');
      });

      testWidgets('Displays the Load card button after loading', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.widgetWithText(ElevatedButton, 'Load card'), findsOneWidget,
            reason: 'The "Load card" ElevatedButton should be displayed and functional.');
      });

      testWidgets('Displays the correct username after fetching data', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.pumpAndSettle();

        expect(find.text('Test User'), findsOneWidget,
            reason: 'Should display the mocked full_name (Test User).');

        verify(() => mockProfileService.getUserBalanceById('test-user-id')).called(1);
      });

      testWidgets('Displays the correct current balance after fetching data', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.pumpAndSettle();

        expect(find.text('Current Balance: \$50.00'), findsOneWidget,
            reason: 'Should display the mocked user balance formatted to two decimal places.');
      });

      testWidgets('Displays "No recent transactions" when none are fetched', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.pumpAndSettle();

        expect(find.text('Transactions'), findsOneWidget);

        expect(find.text('No recent transactions'), findsOneWidget,
            reason: 'Should display the default message when the transaction list is empty.');

        expect(find.byType(ListTile), findsNothing,
            reason: 'Should not display any ListTile when transactions are empty.');
      });

      testWidgets('Find Show More/Less text)', (WidgetTester tester) async {
        when(() => mockTransactionService.getTransactionsForUser())
            .thenAnswer((_) async => fiveMockRawTransactions);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.textContaining('Show'), findsOneWidget,
            reason: 'The text "Show" (part of "Show More/Less") should be visible on the page.');
      });

      testWidgets('Load card button opens the load amount dialog with pay button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final loadCardButton = find.widgetWithText(ElevatedButton, 'Load card');
        await tester.tap(loadCardButton);
        await tester.pump();

        expect(find.byType(AlertDialog), findsOneWidget, reason: 'The AlertDialog for loading card should be displayed.');

        expect(find.text('Enter load amount'), findsOneWidget, reason: 'The dialog should have the title "Enter load amount".');

        expect(find.widgetWithText(ElevatedButton, 'Pay'), findsOneWidget, reason: 'The dialog must contain a "Pay" ElevatedButton.');

        final cancelButton = find.widgetWithText(TextButton, 'Cancel');
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing, reason: 'Dialog should be dismissed.');
      });
  });
}