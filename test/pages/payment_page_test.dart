import 'package:clean_stream_laundry_app/pages/payment_page.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/middleware/app_router.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:clean_stream_laundry_app/logic/viewmodels/loyalty_view_model.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockMachineService mockMachineService;
  late MockProfileService mockProfileService;
  late MockTransactionService mockTransactionService;
  late MockMachineCommunicationService mockMachineCommunicator;
  late MockRouterService mockRouterService;
  late MockNotificationService mockNotificationService;
  late MockPaymentProcessor mockPaymentProcessor;
  late MockLoyaltyViewModel mockLoyaltyViewModel;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeAuthService());
    registerFallbackValue(const Duration(seconds: 1));
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockMachineService = MockMachineService();
    mockProfileService = MockProfileService();
    mockTransactionService = MockTransactionService();
    mockMachineCommunicator = MockMachineCommunicationService();
    mockRouterService = MockRouterService();
    mockNotificationService = MockNotificationService();
    mockPaymentProcessor = MockPaymentProcessor();
    mockLoyaltyViewModel = MockLoyaltyViewModel();

    final getIt = GetIt.instance;
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<MachineService>(mockMachineService);
    getIt.registerSingleton<ProfileService>(mockProfileService);
    getIt.registerSingleton<TransactionService>(mockTransactionService);
    getIt.registerSingleton<MachineCommunicationService>(
      mockMachineCommunicator,
    );
    getIt.registerSingleton<RouterService>(mockRouterService);
    getIt.registerSingleton<NotificationService>(mockNotificationService);

    when(() => mockNotificationService.scheduleDelayedMachineNotification(
      id: any(named: 'id'),
      givenDelay: any(named: 'givenDelay'),
    )).thenAnswer((_) async {});
    getIt.registerSingleton<PaymentProcessor>(mockPaymentProcessor);
    getIt.registerSingleton<LoyaltyViewModel>(mockLoyaltyViewModel);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget(String machineId) {
    final router = GoRouter(
      initialLocation: '/payment',
      routes: [
        GoRoute(
          path: '/payment',
          builder: (context, state) => PaymentPage(machineId: machineId),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('PaymentPage Initialization', () {
    testWidgets('displays loading indicator initially', (tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');

      when(() => mockMachineService.getMachineById(any())).thenAnswer((
          _,
          ) async {
        await Future.delayed(Duration(milliseconds: 10));
        return {'Name': 'Washer01', 'Price': 3.50};
      });

      when(() => mockProfileService.getUserBalanceById(any())).thenAnswer((
          _,
          ) async {
        await Future.delayed(Duration(milliseconds: 10));
        return {'balance': 10.0};
      });

      await tester.pumpWidget(createTestWidget('machine123'));

      // Loader should appear on the first frame
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Now advance async tasks
      await tester.pumpAndSettle();

      // Loader should be gone after data loads
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays machine information after loading', (
        WidgetTester tester,
        ) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById('machine123'),
      ).thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});
      when(
            () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': 10.0});

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.text('Machine Washer01'), findsOneWidget);
      expect(find.text('\$3.50'), findsOneWidget);
      expect(find.text('Amount Due'), findsOneWidget);
    });

    testWidgets('handles null user ID gracefully', (WidgetTester tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pump();

      verify(() => mockAuthService.getCurrentUserId).called(1);
      verifyNever(() => mockProfileService.getUserBalanceById(any()));
    });

    testWidgets('handles machine not found error', (WidgetTester tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => null);
      when(
            () => mockProfileService.getUserBalanceById(any()),
      ).thenAnswer((_) async => {'balance': 10.0});

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.text('Machine Unknown'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);
    });
  });

  group('payment Buttons', () {
    testWidgets('displays both payment buttons', (WidgetTester tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});
      when(
            () => mockProfileService.getUserBalanceById(any()),
      ).thenAnswer((_) async => {'balance': 10.0});

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.text('Pay \$3.50'), findsOneWidget);
      expect(find.text('Pay with Loyalty'), findsOneWidget);
    });

    testWidgets('disables loyalty button when balance is insufficient', (
        WidgetTester tester,
        ) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});
      when(() => mockProfileService.getUserBalanceById(any())).thenAnswer(
            (_) async => {
          'balance': 2.0, // Insufficient balance
        },
      );

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pumpAndSettle();

      final loyaltyButton = find.widgetWithText(
        ElevatedButton,
        'Pay with Loyalty',
      );
      final button = tester.widget<ElevatedButton>(loyaltyButton);

      expect(button.onPressed, isNull);
    });

    testWidgets('enables loyalty button when balance is sufficient', (
        WidgetTester tester,
        ) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});
      when(
            () => mockProfileService.getUserBalanceById(any()),
      ).thenAnswer((_) async => {'balance': 10.0});

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pumpAndSettle();

      final loyaltyButton = find.widgetWithText(
        ElevatedButton,
        'Pay with Loyalty',
      );
      final button = tester.widget<ElevatedButton>(loyaltyButton);

      expect(button.onPressed, isNotNull);
    });
  });

  group('Loyalty payment Processing', () {
    testWidgets('processes loyalty payment successfully', (
        WidgetTester tester,
        ) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});
      when(
            () => mockProfileService.getUserBalanceById(any()),
      ).thenAnswer((_) async => {'balance': 10.0});
      when(
            () => mockProfileService.updateBalanceById(any()),
      ).thenAnswer((_) async => {});
      when(
            () => mockMachineCommunicator.wakeDevice(any()),
      ).thenAnswer((_) async => true);
      when(
            () => mockTransactionService.recordTransaction(
          amount: any(named: 'amount'),
          description: any(named: 'description'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay with Loyalty'));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(() => mockProfileService.updateBalanceById(6.5)).called(1);
      verify(() => mockMachineCommunicator.wakeDevice('machine123')).called(1);
      verify(
            () => mockTransactionService.recordTransaction(
          amount: 3.50,
          description: any(named: 'description'),
          type: 'laundry',
        ),
      ).called(1);
    });

    testWidgets('handles machine wake failure in loyalty payment', (
        WidgetTester tester,
        ) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});
      when(
            () => mockProfileService.getUserBalanceById(any()),
      ).thenAnswer((_) async => {'balance': 10.0});
      when(
            () => mockProfileService.updateBalanceById(any()),
      ).thenAnswer((_) async => {});
      when(
            () => mockMachineCommunicator.wakeDevice(any()),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay with Loyalty'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Machine Error'), findsWidgets);
      verifyNever(
            () => mockTransactionService.recordTransaction(
          amount: any(named: 'amount'),
          description: any(named: 'description'),
          type: any(named: 'type'),
        ),
      );
    });
  });

  group('UI Elements', () {
    testWidgets('displays laundry service icon', (WidgetTester tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});
      when(
            () => mockProfileService.getUserBalanceById(any()),
      ).thenAnswer((_) async => {'balance': 10.0});

      await tester.pumpWidget(createTestWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_laundry_service), findsOneWidget);
    });

    testWidgets('displays formatted price correctly', (
        WidgetTester tester,
        ) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
            () => mockMachineService.getMachineById(any()),
      ).thenAnswer((_) async => {'Name': 'Dryer05', 'Price': 2.75});
      when(
            () => mockProfileService.getUserBalanceById(any()),
      ).thenAnswer((_) async => {'balance': 5.0});

      await tester.pumpWidget(createTestWidget('machine456'));
      await tester.pumpAndSettle();

      expect(find.text('Machine Dryer05'), findsOneWidget);
      expect(find.text('\$2.75'), findsOneWidget);
      expect(find.text('Pay \$2.75'), findsOneWidget);
    });
  });
}