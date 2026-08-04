import 'package:clean_stream_laundry_app/features/cortina_payment/controller.dart';
import 'package:clean_stream_laundry_app/logic/models/cortina_vend.dart';
import 'package:clean_stream_laundry_app/logic/models/wallet_balance.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/cortina_vend_service.dart';
import 'package:clean_stream_laundry_app/logic/services/wallet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCortinaVendService extends Mock implements CortinaVendService {}

class MockAuthService extends Mock implements AuthService {}

class MockWalletService extends Mock implements WalletService {}

const dryerQuote = CortinaQuote(
  machineId: 7,
  machineName: 'Dryer 7',
  machineType: 'dryer',
  washerSizeLabel: null,
  amountCents: 150,
  dryerMinimumCents: 25,
  dryerMaximumCents: 450,
  dryerDefaultCents: 150,
  dryerIncrementCents: 25,
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CortinaVendReference(
        sessionId: 'fallback-session',
        accessToken: 'fallback-token',
      ),
    );
  });

  late MockCortinaVendService vendService;
  late MockAuthService authService;
  late MockWalletService walletService;

  setUp(() {
    vendService = MockCortinaVendService();
    authService = MockAuthService();
    walletService = MockWalletService();
    when(() => authService.getCurrentUserId).thenReturn(null);
  });

  CortinaPaymentController controller() => CortinaPaymentController(
    machineToken: 'token-1',
    uniQr: null,
    vendService: vendService,
    authService: authService,
    walletService: walletService,
    presentPaymentSheet: (_) async {},
    delay: (_) async {},
    pollAttempts: 2,
  );

  test('loads server quote and uses the default dryer amount', () async {
    when(
      () => vendService.quote(machineToken: 'token-1', uniQr: null),
    ).thenAnswer((_) async => dryerQuote);

    final subject = controller();
    await subject.init();

    expect(subject.amountCents, 150);
    expect(subject.dryerMinutes, 30);
    expect(subject.price, 1.50);
    verifyNever(() => walletService.getBalance());
  });

  test('dryer selection remains in quarter increments', () async {
    when(
      () => vendService.quote(machineToken: 'token-1', uniQr: null),
    ).thenAnswer((_) async => dryerQuote);
    final subject = controller();
    await subject.init();

    subject.setDryerAmount(163);

    expect(subject.amountCents, 150);
    expect(subject.dryerMinutes, 30);
  });

  test('card payment completes after the webhook starts the machine', () async {
    when(
      () => vendService.quote(machineToken: 'token-1', uniQr: null),
    ).thenAnswer((_) async => dryerQuote);
    when(
      () => vendService.createCardPayment(
        machineToken: 'token-1',
        uniQr: null,
        amountCents: 150,
        clientRequestId: any(named: 'clientRequestId'),
      ),
    ).thenAnswer(
      (_) async => const CortinaCardSession(
        sessionId: 'session-1',
        accessToken: 'access-1',
        clientSecret: 'secret-1',
      ),
    );
    when(
      () => vendService.status(any()),
    ).thenAnswer((_) async => const CortinaVendStatus(status: 'started'));

    final subject = controller();
    await subject.init();
    final outcome = await subject.payWithCard();

    expect(outcome, CortinaPaymentOutcome.success);
    expect(subject.paymentCompleted, isTrue);
  });

  test('signed-in users receive their wallet balance', () async {
    when(() => authService.getCurrentUserId).thenReturn('user-1');
    when(
      () => vendService.quote(machineToken: 'token-1', uniQr: null),
    ).thenAnswer((_) async => dryerQuote);
    when(() => walletService.getBalance()).thenAnswer(
      (_) async => const WalletBalance(
        walletAccountId: 'wallet-1',
        status: 'active',
        paidBalanceCents: 500,
        promoBalanceCents: 100,
        totalBalanceCents: 600,
      ),
    );

    final subject = controller();
    await subject.init();

    expect(subject.walletBalance, 6.00);
  });
}
