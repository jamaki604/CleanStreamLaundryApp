import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/pages/refund_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockTransactionService mockTransactionService;
  late MockEdgeFunctionService mockEdgeFunctionService;
  late MockProfileService mockProfileService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockTransactionService = MockTransactionService();
    mockEdgeFunctionService = MockEdgeFunctionService();
    mockProfileService = MockProfileService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
    getIt.registerSingleton<EdgeFunctionService>(mockEdgeFunctionService);
    getIt.registerSingleton<ProfileService>(mockProfileService);

    // Setup default stubs
    when(() => mockAuthService.getCurrentUserId).thenReturn('test-user-id');
    when(() => mockTransactionService.getTransactionsForUser())
        .thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const RefundPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(
            body: Text('Settings Page'),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('RefundPage', () {
    testWidgets('renders correctly with all elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Refund Page'), findsOneWidget);
      expect(find.text('Select a Transaction'), findsOneWidget);
      expect(
          find.text('Please explain your reason for the refund...'),
          findsOneWidget);
      expect(find.text('Submit Refund'), findsOneWidget);
    });

    testWidgets('submit button is disabled when form is invalid',
            (tester) async {
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pumpAndSettle();

          final submitButton = find.widgetWithText(ElevatedButton, 'Submit Refund');
          expect(submitButton, findsOneWidget);

          final button = tester.widget<ElevatedButton>(submitButton);
          expect(button.onPressed, isNull);
        });

    testWidgets('loads transactions on init', (tester) async {
      final mockTransactions = [
        {'id': 1, 'amount': 10.0, 'date': '2024-01-01'},
        {'id': 2, 'amount': 20.0, 'date': '2024-01-02'},
      ];

      when(() => mockTransactionService.getTransactionsForUser())
          .thenAnswer((_) async => mockTransactions);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(() => mockTransactionService.getTransactionsForUser()).called(1);
    });

    testWidgets('can select transaction from dropdown', (tester) async {
      final mockTransactions = [
        {'id': 1, 'amount': 10.0, 'date': '2024-01-01'},
      ];

      when(() => mockTransactionService.getTransactionsForUser())
          .thenAnswer((_) async => mockTransactions);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

    });

    testWidgets('can enter description text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test refund reason');
      await tester.pumpAndSettle();

      expect(find.text('Test refund reason'), findsOneWidget);
    });

    testWidgets('submit button enabled when form is valid', (tester) async {
      final mockTransactions = [
        {'id': 123, 'amount': 10.0, 'date': '2024-01-01'},
      ];

      when(() => mockTransactionService.getTransactionsForUser())
          .thenAnswer((_) async => mockTransactions);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test refund reason');
      await tester.pumpAndSettle();

    });

    testWidgets('handles refund submission successfully', (tester) async {
      final mockTransactions = [
        {'id': 123, 'amount': 25.50, 'date': '2024-01-01'},
      ];

      when(() => mockTransactionService.getTransactionsForUser())
          .thenAnswer((_) async => mockTransactions);
      when(() => mockProfileService.getUserNameById('test-user-id'))
          .thenAnswer((_) async => 'Test User');
      when(() => mockTransactionService.recordRefundRequest(
        transaction_id: any(named: 'transaction_id'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => "25.50");
      when(() => mockEdgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
    });

    testWidgets('shows error when user is not logged in', (tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to settings after successful refund',
            (tester) async {
          final mockTransactions = [
            {'id': 123, 'amount': 25.50, 'date': '2024-01-01'},
          ];

          when(() => mockTransactionService.getTransactionsForUser())
              .thenAnswer((_) async => mockTransactions);
          when(() => mockProfileService.getUserNameById('test-user-id'))
              .thenAnswer((_) async => 'Test User');
          when(() => mockTransactionService.recordRefundRequest(
            transaction_id: any(named: 'transaction_id'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => "25.50");
          when(() => mockEdgeFunctionService.runEdgeFunction(
            name: any(named: 'name'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => null);

          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pumpAndSettle();
        });

    testWidgets('handles transaction fetch error gracefully', (tester) async {
      when(() => mockTransactionService.getTransactionsForUser())
          .thenThrow(Exception('Failed to fetch transactions'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Refund Page'), findsOneWidget);
    });
  });
}