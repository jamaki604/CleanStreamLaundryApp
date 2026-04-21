import 'package:clean_stream_laundry_app/features/machine_payment/machine_payment.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockMachineService mockMachineService;
  late MockProfileService mockProfileService;
  late MockTransactionService mockTransactionService;
  late MockMachineCommunicationService mockMachineCommunicator;
  late MockNotificationService mockNotificationService;
  late MockPaymentProcessor mockPaymentProcessor;

  setUpAll(() {
    registerFallbackValue(FakeAuthService());
    registerFallbackValue(const Duration(seconds: 1));
  });

  setUp(() async {
    mockAuthService = MockAuthService();
    mockMachineService = MockMachineService();
    mockProfileService = MockProfileService();
    mockTransactionService = MockTransactionService();
    mockMachineCommunicator = MockMachineCommunicationService();
    mockNotificationService = MockNotificationService();
    mockPaymentProcessor = MockPaymentProcessor();

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<MachineService>(mockMachineService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);
    GetIt.instance.registerSingleton<TransactionService>(mockTransactionService);
    GetIt.instance.registerSingleton<MachineCommunicationService>(
        mockMachineCommunicator);
    GetIt.instance.registerSingleton<NotificationService>(
        mockNotificationService);
    GetIt.instance.registerSingleton<PaymentProcessor>(mockPaymentProcessor);

    when(() => mockNotificationService.scheduleEarlyMachineNotification(
      id: any(named: 'id'),
      machineTime: any(named: 'machineTime'),
      machineName: any(named: 'machineName'),
    )).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidget(String machineId) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/payment',
        routes: [
          GoRoute(
            path: '/payment',
            builder: (_, __) => MachinePayment(machineId: machineId),
          ),
          GoRoute(
            path: '/homePage',
            builder: (_, __) => const Scaffold(body: Text('Home Page')),
          ),
        ],
      ),
    );
  }

  void mockWasherMachine({double price = 3.50, double balance = 10.0}) {
    when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
    when(() => mockMachineService.getMachineById(any()))
        .thenAnswer((_) async => {'Name': 'Washer01', 'Price': price});
    when(() => mockProfileService.getUserBalanceById(any()))
        .thenAnswer((_) async => {'balance': balance});
  }

  void mockDryerMachine({double price = 1.50, double balance = 10.0}) {
    when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
    when(() => mockMachineService.getMachineById(any()))
        .thenAnswer((_) async => {'Name': 'Dryer01', 'Price': price});
    when(() => mockProfileService.getUserBalanceById(any()))
        .thenAnswer((_) async => {'balance': balance});
  }

  // ---------------------------------------------------------------------------
  // Loading state
  // ---------------------------------------------------------------------------

  group('Loading state', () {
    testWidgets('shows loading indicator while fetching machine info',
            (tester) async {
          when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
          when(() => mockMachineService.getMachineById(any())).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return {'Name': 'Washer01', 'Price': 3.50};
          });
          when(() => mockProfileService.getUserBalanceById(any()))
              .thenAnswer((_) async => {'balance': 10.0});

          await tester.pumpWidget(createWidget('machine123'));
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();
          expect(find.byType(CircularProgressIndicator), findsNothing);
        });
  });

  // ---------------------------------------------------------------------------
  // Content display
  // ---------------------------------------------------------------------------

  group('Content display', () {
    testWidgets('displays machine name and Amount Due after loading',
            (tester) async {
          mockWasherMachine();
          await tester.pumpWidget(createWidget('machine123'));
          await tester.pumpAndSettle();

          expect(find.text('Machine Washer01'), findsOneWidget);
          expect(find.text('Amount Due'), findsOneWidget);
        });

    testWidgets('displays formatted price', (tester) async {
      mockWasherMachine(price: 3.50);
      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.text('\$3.50'), findsOneWidget);
    });

    testWidgets('displays laundry service icon', (tester) async {
      mockWasherMachine();
      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_laundry_service), findsOneWidget);
    });

    testWidgets('handles null userId gracefully', (tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);
      when(() => mockMachineService.getMachineById(any()))
          .thenAnswer((_) async => {'Name': 'Washer01', 'Price': 3.50});

      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      verifyNever(() => mockProfileService.getUserBalanceById(any()));
    });

    testWidgets('handles machine not found', (tester) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(() => mockMachineService.getMachineById(any()))
          .thenAnswer((_) async => null);
      when(() => mockProfileService.getUserBalanceById(any()))
          .thenAnswer((_) async => {'balance': 10.0});

      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.text('Machine Unknown'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('shows WasherControlsCard for washer machines', (tester) async {
      mockWasherMachine();
      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.text('Select Your Cycle'), findsOneWidget);
    });

    testWidgets('shows DryerControlsCard for dryer machines', (tester) async {
      mockDryerMachine();
      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.text('Set Dry Time'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Payment buttons
  // ---------------------------------------------------------------------------

  group('Payment buttons', () {
    testWidgets('displays both payment buttons', (tester) async {
      mockDryerMachine();
      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      expect(find.text('Pay \$1.50'), findsOneWidget);
      expect(find.text('Pay with Loyalty'), findsOneWidget);
    });

    testWidgets('disables loyalty button when balance is insufficient',
            (tester) async {
          mockDryerMachine(price: 5.00, balance: 1.00);
          await tester.pumpWidget(createWidget('machine123'));
          await tester.pumpAndSettle();

          final button = tester.widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Pay with Loyalty'),
          );
          expect(button.onPressed, isNull);
        });

    testWidgets('enables loyalty button when balance is sufficient',
            (tester) async {
          mockDryerMachine(price: 1.50, balance: 10.00);
          await tester.pumpWidget(createWidget('machine123'));
          await tester.pumpAndSettle();

          final button = tester.widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Pay with Loyalty'),
          );
          expect(button.onPressed, isNotNull);
        });
  });

  // ---------------------------------------------------------------------------
  // Direct payment
  // ---------------------------------------------------------------------------

  group('Direct payment', () {
    testWidgets('shows success dialog when payment and machine wake succeed',
            (tester) async {
          mockDryerMachine();
          when(() => mockPaymentProcessor.processPayment(any(), any()))
              .thenAnswer((_) async => PaymentResult.success);
          when(() => mockMachineCommunicator.wakeDevice(any()))
              .thenAnswer((_) async => true);

          await tester.pumpWidget(createWidget('machine123'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Pay \$1.50'));
          await tester.pump();
          await tester.pumpAndSettle();

          expect(find.text('Payment Processed! Machine Ready!'), findsOneWidget);
        });

    testWidgets('shows machine error dialog when machine fails to wake',
            (tester) async {
          mockDryerMachine();
          when(() => mockPaymentProcessor.processPayment(any(), any()))
              .thenAnswer((_) async => PaymentResult.success);
          when(() => mockMachineCommunicator.wakeDevice(any()))
              .thenAnswer((_) async => false);

          await tester.pumpWidget(createWidget('machine123'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Pay \$1.50'));
          await tester.pump();
          await tester.pumpAndSettle();

          expect(find.text('Machine Error'), findsOneWidget);
        });

    testWidgets('shows payment failed dialog when payment fails', (tester) async {
      mockDryerMachine();
      when(() => mockPaymentProcessor.processPayment(any(), any()))
          .thenAnswer((_) async => PaymentResult.failed);

      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay \$1.50'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Payment Failed'), findsOneWidget);
    });

    testWidgets('shows Back to Home button after successful direct payment',
            (tester) async {
          mockDryerMachine();
          when(() => mockPaymentProcessor.processPayment(any(), any()))
              .thenAnswer((_) async => PaymentResult.success);
          when(() => mockMachineCommunicator.wakeDevice(any()))
              .thenAnswer((_) async => true);

          await tester.pumpWidget(createWidget('machine123'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Pay \$1.50'));
          await tester.pump();
          await tester.pumpAndSettle();

          // Dismiss dialog
          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();

          expect(find.text('Back to Home'), findsOneWidget);
        });

    testWidgets('schedules notification after successful direct payment',
            (tester) async {
          mockDryerMachine();
          when(() => mockPaymentProcessor.processPayment(any(), any()))
              .thenAnswer((_) async => PaymentResult.success);
          when(() => mockMachineCommunicator.wakeDevice(any()))
              .thenAnswer((_) async => true);

          await tester.pumpWidget(createWidget('machine123'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Pay \$1.50'));
          await tester.pump();
          await tester.pumpAndSettle();

          verify(() => mockNotificationService.scheduleEarlyMachineNotification(
            id: 1,
            machineTime: any(named: 'machineTime'),
            machineName: any(named: 'machineName'),
          )).called(1);
        });
  });

  // ---------------------------------------------------------------------------
  // Loyalty payment
  // ---------------------------------------------------------------------------

  group('Loyalty payment', () {
    testWidgets('processes loyalty payment and wakes machine', (tester) async {
      mockDryerMachine(price: 1.50, balance: 10.00);
      when(() => mockMachineCommunicator.wakeDevice(any()))
          .thenAnswer((_) async => true);
      when(() => mockProfileService.updateBalanceById(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTransactionService.recordTransaction(
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        type: any(named: 'type'),
      ))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay with Loyalty'));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(() =>
          mockProfileService.updateBalanceById('user123', 8.5))
          .called(1);
      verify(() => mockMachineCommunicator.wakeDevice('machine123')).called(1);
      verify(() => mockTransactionService.recordTransaction(
        amount: 1.50,
        description: any(named: 'description'),
        type: 'laundry',
      ))
          .called(1);
    });

    testWidgets('shows machine error when device fails to wake', (tester) async {
      mockDryerMachine(price: 1.50, balance: 10.00);
      when(() => mockMachineCommunicator.wakeDevice(any()))
          .thenAnswer((_) async => false);
      when(() => mockProfileService.updateBalanceById(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockTransactionService.recordTransaction(
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        type: any(named: 'type'),
      ))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidget('machine123'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay with Loyalty'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Machine Error'), findsWidgets);
      verifyNever(() => mockTransactionService.recordTransaction(
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        type: any(named: 'type'),
      ));
    });

    testWidgets('schedules notification after successful loyalty payment',
            (tester) async {
          mockWasherMachine(price: 3.50, balance: 10.00);
          when(() => mockMachineCommunicator.wakeDevice(any()))
              .thenAnswer((_) async => true);
          when(() => mockProfileService.updateBalanceById(any(), any()))
              .thenAnswer((_) async {});
          when(() => mockTransactionService.recordTransaction(
            amount: any(named: 'amount'),
            description: any(named: 'description'),
            type: any(named: 'type'),
          ))
              .thenAnswer((_) async {});

          await tester.pumpWidget(createWidget('machine123'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Pay with Loyalty'));
          await tester.pump();
          await tester.pumpAndSettle();

          verify(() => mockNotificationService.scheduleEarlyMachineNotification(
            id: 1,
            machineTime: any(named: 'machineTime'),
            machineName: any(named: 'machineName'),
          )).called(1);
        });
  });
}