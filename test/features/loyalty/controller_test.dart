import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/features/loyalty/controller.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/wallet_service.dart';
import 'package:clean_stream_laundry_app/logic/models/wallet_balance.dart';
import 'package:clean_stream_laundry_app/logic/models/wallet_ledger_entry.dart';
import 'package:clean_stream_laundry_app/logic/payment/process_payment.dart';
import 'mocks.dart';
import 'package:clean_stream_laundry_app/logic/enums/payment_result_enum.dart';

void main() {
  late LoyaltyController controller;
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;
  late MockWalletService mockWalletService;
  late MockPaymentProcessor mockPaymentProcessor;

  setUp(() {
    GetIt.instance.reset();

    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();
    mockWalletService = MockWalletService();
    mockPaymentProcessor = MockPaymentProcessor();

    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);
    GetIt.instance.registerSingleton<WalletService>(mockWalletService);
    GetIt.instance.registerSingleton<PaymentProcessor>(mockPaymentProcessor);

    when(() => mockWalletService.getBalance()).thenAnswer(
      (_) async => const WalletBalance(
        walletAccountId: 'wallet123',
        status: 'active',
        paidBalanceCents: 10000,
        promoBalanceCents: 0,
        totalBalanceCents: 10000,
      ),
    );
    when(() => mockWalletService.getLedger()).thenAnswer((_) async => []);
    when(
      () => mockProfileService.getUserBalanceById(any()),
    ).thenAnswer((_) async => {'balance': 100.0, 'full_name': 'Jane Doe'});

    controller = LoyaltyController();
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('initialize', () {
    test('should fetch balance and transactions successfully', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
        () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': 100.0, 'full_name': 'Jane Doe'});

      await controller.initialize();

      expect(controller.userBalance, 100.0);
      expect(controller.userName, 'Jane Doe');
      expect(controller.isLoading, false);
      expect(controller.errorMessage, null);

      verify(() => mockAuthService.getCurrentUserId).called(1);
      verify(() => mockProfileService.getUserBalanceById('user123')).called(1);
      verify(() => mockWalletService.getBalance()).called(1);
      verify(() => mockWalletService.getLedger()).called(1);
    });

    test('should handle profile service error gracefully', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
        () => mockProfileService.getUserBalanceById('user123'),
      ).thenThrow(Exception('Network error'));

      await controller.initialize();

      expect(controller.errorMessage, 'Failed to fetch balance');
      expect(controller.isLoading, false);
    });

    test('initialize should handle null userId', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);

      await controller.initialize();

      expect(controller.errorMessage, 'User not known');
      expect(controller.isLoading, false);

      verifyNever(() => mockProfileService.getUserBalanceById(any()));
    });

    test('should default to 0.0 balance when null', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
        () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': null, 'full_name': 'Jane Doe'});
      when(
        () => mockWalletService.getBalance(),
      ).thenAnswer((_) async => WalletBalance.empty());

      await controller.initialize();

      expect(controller.userBalance, 0.0);
      expect(controller.userName, 'Jane Doe');
    });

    test('should default to "John Doe" when name is null', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');
      when(
        () => mockProfileService.getUserBalanceById('user123'),
      ).thenAnswer((_) async => {'balance': 100.0, 'full_name': null});

      await controller.initialize();

      expect(controller.userName, 'John Doe');
    });
  });

  group('toggleTransactionView', () {
    test('should toggle showPastTransactions from false to true', () async {
      expect(controller.showPastTransactions, false);

      await controller.toggleTransactionView();

      expect(controller.showPastTransactions, true);
      verify(() => mockWalletService.getLedger()).called(1);
    });

    test('should toggle showPastTransactions from true to false', () async {
      controller.showPastTransactions = true;

      await controller.toggleTransactionView();

      expect(controller.showPastTransactions, false);
    });
  });

  group('fetchTransactions', () {
    test('should call wallet ledger service', () async {
      await controller.fetchTransactions();

      verify(() => mockWalletService.getLedger()).called(1);
    });

    test('fetchTransactions filters out old wallet ledger entries', () async {
      final now = DateTime.now();
      when(() => mockWalletService.getLedger()).thenAnswer(
        (_) async => [
          WalletLedgerEntry(
            id: 1,
            entryType: 'load_paid',
            amountCents: 1000,
            paidAmountCents: 1000,
            promoAmountCents: 0,
            createdAt: now,
          ),
          WalletLedgerEntry(
            id: 2,
            entryType: 'load_bonus',
            amountCents: 500,
            paidAmountCents: 0,
            promoAmountCents: 500,
            createdAt: now.subtract(const Duration(days: 40)),
          ),
        ],
      );

      await controller.toggleTransactionView();

      expect(controller.recentTransactions.length, 1);
    });
  });

  group('loadCard', () {
    test(
      'loadCard should update balance and fetch transactions on success',
      () async {
        when(() => mockAuthService.getCurrentUserId).thenReturn('user123');

        controller.userBalance = 20.0;

        when(
          () => mockPaymentProcessor.processPayment(10.0, 'Loyalty Card'),
        ).thenAnswer((_) async => PaymentResult.success);

        when(() => mockWalletService.getBalance()).thenAnswer(
          (_) async => const WalletBalance(
            walletAccountId: 'wallet123',
            status: 'active',
            paidBalanceCents: 3000,
            promoBalanceCents: 0,
            totalBalanceCents: 3000,
          ),
        );

        final result = await controller.loadCard(10.0);

        expect(result, PaymentResult.success);
        expect(controller.userBalance, 30);

        verify(() => mockWalletService.getBalance()).called(3);
        verify(() => mockWalletService.getLedger()).called(3);
      },
    );

    test('loadCard should not update balance on failed payment', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user123');

      controller.userBalance = 20.0;

      when(
        () => mockPaymentProcessor.processPayment(10.0, 'Loyalty Card'),
      ).thenAnswer((_) async => PaymentResult.failed);

      final result = await controller.loadCard(10.0);

      expect(result, PaymentResult.failed);
      expect(controller.userBalance, 20.0);

      verifyNever(() => mockProfileService.updateBalanceById(any(), any()));
    });
  });
}
