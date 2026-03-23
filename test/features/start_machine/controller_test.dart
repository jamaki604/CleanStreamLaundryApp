import 'package:clean_stream_laundry_app/features/start_machine/controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockDoorUnlocker mockUnlocker;
  late MockProfileService mockProfileService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockUnlocker = MockDoorUnlocker();
    mockProfileService = MockProfileService();
    mockAuthService = MockAuthService();
  });

  StartPageController buildController() => StartPageController(
    profileService: mockProfileService,
    authService: mockAuthService,
    doorUnlocker: mockUnlocker,
  );

  group('loadUserData', () {
    test('sets balance when userId and service return data', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user1');
      when(() => mockProfileService.getUserBalanceById('user1'))
          .thenAnswer((_) async => {'balance': 42.0});

      final controller = buildController();
      await controller.loadUserData();

      expect(controller.balance, {'balance': 42.0});
      expect(controller.balanceValue, 42.0);
    });

    test('does not call getUserBalanceById when userId is null', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);

      final controller = buildController();
      await controller.loadUserData();

      verifyNever(() => mockProfileService.getUserBalanceById(any()));
      expect(controller.balance, isNull);
    });

    test('notifies listeners after loading', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user1');
      when(() => mockProfileService.getUserBalanceById(any()))
          .thenAnswer((_) async => {'balance': 10.0});

      final controller = buildController();
      var notified = false;
      controller.addListener(() => notified = true);

      await controller.loadUserData();

      expect(notified, isTrue);
    });
  });

  group('hasSufficientBalance', () {
    test('returns false when balance is null', () {
      final controller = buildController();
      expect(controller.hasSufficientBalance, isFalse);
    });

    test('returns false when balance is below minimum', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user1');
      when(() => mockProfileService.getUserBalanceById(any()))
          .thenAnswer((_) async => {'balance': 15.0});

      final controller = buildController();
      await controller.loadUserData();

      expect(controller.hasSufficientBalance, isFalse);
    });

    test('returns true when balance equals minimum', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user1');
      when(() => mockProfileService.getUserBalanceById(any()))
          .thenAnswer((_) async => {'balance': minimumBalance});

      final controller = buildController();
      await controller.loadUserData();

      expect(controller.hasSufficientBalance, isTrue);
    });

    test('returns true when balance exceeds minimum', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user1');
      when(() => mockProfileService.getUserBalanceById(any()))
          .thenAnswer((_) async => {'balance': 50.0});

      final controller = buildController();
      await controller.loadUserData();

      expect(controller.hasSufficientBalance, isTrue);
    });
  });

  group('unlockDoor', () {
    test('resets cancelSearch to false before unlocking', () async {
      when(() => mockUnlocker.unlockNearestDoor())
          .thenAnswer((_) async => true);

      final controller = buildController();
      controller.cancelSearch = true;

      await controller.unlockDoor();

      expect(controller.cancelSearch, isFalse);
    });

    test('returns true when unlockNearestDoor succeeds', () async {
      when(() => mockUnlocker.unlockNearestDoor())
          .thenAnswer((_) async => true);

      final controller = buildController();
      final result = await controller.unlockDoor();

      expect(result, isTrue);
    });

    test('returns false when unlockNearestDoor fails', () async {
      when(() => mockUnlocker.unlockNearestDoor())
          .thenAnswer((_) async => false);

      final controller = buildController();
      final result = await controller.unlockDoor();

      expect(result, isFalse);
    });

    test('calls unlockNearestDoor on the doorUnlocker', () async {
      when(() => mockUnlocker.unlockNearestDoor())
          .thenAnswer((_) async => true);

      final controller = buildController();
      await controller.unlockDoor();

      verify(() => mockUnlocker.unlockNearestDoor()).called(1);
    });
  });

  group('cancelUnlock', () {
    test('sets cancelSearch to true', () {
      when(() => mockUnlocker.cancelUnlockingDoor()).thenReturn(null);

      final controller = buildController();
      controller.cancelUnlock();

      expect(controller.cancelSearch, isTrue);
    });

    test('calls cancelUnlockingDoor on doorUnlocker', () {
      when(() => mockUnlocker.cancelUnlockingDoor()).thenReturn(null);

      final controller = buildController();
      controller.cancelUnlock();

      verify(() => mockUnlocker.cancelUnlockingDoor()).called(1);
    });
  });
}