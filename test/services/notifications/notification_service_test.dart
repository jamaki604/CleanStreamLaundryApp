import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_stream_laundry_app/services/notification_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';

// -------------------- MOCKS --------------------

class MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockAndroidPlugin extends Mock implements AndroidFlutterLocalNotificationsPlugin {}
class MockIOSPlugin extends Mock implements IOSFlutterLocalNotificationsPlugin {}
class MockProfileService extends Mock implements ProfileService {}

class FakeInit extends Fake implements InitializationSettings {}
class FakeAndroidInit extends Fake implements AndroidInitializationSettings {}
class FakeIOSInit extends Fake implements DarwinInitializationSettings {}
class FakeNotifDetails extends Fake implements NotificationDetails {}
class FakeAndroidNotifDetails extends Fake implements AndroidNotificationDetails {}
class FakeIOSNotifDetails extends Fake implements DarwinNotificationDetails {}
class FakeChannel extends Fake implements AndroidNotificationChannel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel permissionChannel =
  MethodChannel('flutter.baseflow.com/permissions/methods');

  setUpAll(() {
    registerFallbackValue(FakeInit());
    registerFallbackValue(FakeAndroidInit());
    registerFallbackValue(FakeIOSInit());
    registerFallbackValue(FakeNotifDetails());
    registerFallbackValue(FakeAndroidNotifDetails());
    registerFallbackValue(FakeIOSNotifDetails());
    registerFallbackValue(FakeChannel());
  });

  late MockPlugin mockPlugin;
  late MockAndroidPlugin mockAndroid;
  late MockIOSPlugin mockIOS;
  late MockProfileService mockProfile;

  setUp(() {
    GetIt.I.reset();

    mockPlugin = MockPlugin();
    mockAndroid = MockAndroidPlugin();
    mockIOS = MockIOSPlugin();
    mockProfile = MockProfileService();

    GetIt.I.registerSingleton<FlutterLocalNotificationsPlugin>(mockPlugin);
    GetIt.I.registerSingleton<ProfileService>(mockProfile);

    when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);

    when(() => mockPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroid);

    when(() => mockPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>())
        .thenReturn(mockIOS);

    when(() => mockAndroid.createNotificationChannel(any()))
        .thenAnswer((_) async {});

    when(() => mockIOS.requestPermissions(
      alert: any(named: 'alert'),
      badge: any(named: 'badge'),
      sound: any(named: 'sound'),
    )).thenAnswer((_) async => true);

    when(() => mockPlugin.show(any(), any(), any(), any()))
        .thenAnswer((_) async {});

    when(() => mockProfile.getNotificationLeadTime())
        .thenAnswer((_) async => 5);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
      if (call.method == 'checkPermissionStatus') return 1;
      if (call.method == 'requestPermissions') return {0: 1};
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  testWidgets("scheduleNotification triggers .show() after delay", (tester) async {
    fakeAsync((async) {
      final service = NotificationService();

      service.scheduleNotification(
        id: 1,
        title: "Test Title",
        body: "Test Body",
        delay: const Duration(minutes: 5),
      );

      async.elapse(const Duration(minutes: 5));

      verify(() => mockPlugin.show(
        1,
        "Test Title",
        "Test Body",
        any(),
      )).called(1);
    });
  });

  testWidgets("equal machineTime and leadTime → Machine Almost Ready", (tester) async {
    fakeAsync((async) {
      final service = NotificationService();

      when(() => mockProfile.getNotificationLeadTime())
          .thenAnswer((_) async => 5);

      service.scheduleEarlyMachineNotification(
        id: 1,
        machineTime: const Duration(minutes: 5),
      );

      async.elapse(Duration.zero);

      verify(() => mockPlugin.show(
        1,
        "Machine Almost Ready",
        "Your machine will be ready in 5 minutes!",
        any(),
      )).called(1);
    });
  });

  testWidgets("machineTime > leadTime → delayed Machine Almost Ready", (tester) async {
    fakeAsync((async) {
      final service = NotificationService();

      when(() => mockProfile.getNotificationLeadTime())
          .thenAnswer((_) async => 5);

      service.scheduleEarlyMachineNotification(
        id: 2,
        machineTime: const Duration(minutes: 20),
      );

      async.elapse(const Duration(minutes: 15));

      verify(() => mockPlugin.show(
        2,
        "Machine Almost Ready",
        "Your machine will be ready in 5 minutes!",
        any(),
      )).called(1);
    });
  });

  testWidgets("leadTime > machineTime → Machine Started!", (tester) async {
    fakeAsync((async) {
      final service = NotificationService();

      when(() => mockProfile.getNotificationLeadTime())
          .thenAnswer((_) async => 5);

      service.scheduleEarlyMachineNotification(
        id: 3,
        machineTime: const Duration(minutes: 3),
      );

      async.elapse(Duration.zero);

      verify(() => mockPlugin.show(
        3,
        "Machine Started!",
        "Your machine will be finished in 3 minutes!",
        any(),
      )).called(1);
    });
  });
}