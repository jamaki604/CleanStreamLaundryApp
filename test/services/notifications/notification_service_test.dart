import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/services/notification_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'mocks.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockIOSFlutterLocalNotificationsPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}


class FakeInitializationSettings extends Fake implements InitializationSettings {}
class FakeAndroidInitializationSettings extends Fake implements AndroidInitializationSettings {}
class FakeDarwinInitializationSettings extends Fake implements DarwinInitializationSettings {}
class FakeNotificationDetails extends Fake implements NotificationDetails {}
class FakeAndroidNotificationChannel extends Fake implements AndroidNotificationChannel {}
class FakeAndroidNotificationDetails extends Fake implements AndroidNotificationDetails {}
class FakeDarwinNotificationDetails extends Fake implements DarwinNotificationDetails {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel permissionChannel =
  MethodChannel('flutter.baseflow.com/permissions/methods');

  setUpAll(() {
    registerFallbackValue(FakeInitializationSettings());
    registerFallbackValue(FakeAndroidInitializationSettings());
    registerFallbackValue(FakeDarwinInitializationSettings());
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(FakeAndroidNotificationChannel());
    registerFallbackValue(FakeAndroidNotificationDetails());
    registerFallbackValue(FakeDarwinNotificationDetails());
  });

  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidImpl;
  late MockIOSFlutterLocalNotificationsPlugin mockIOSImpl;
  late MockProfileService mockProfileService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GetIt.instance.reset();

    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidImpl = MockAndroidFlutterLocalNotificationsPlugin();
    mockIOSImpl = MockIOSFlutterLocalNotificationsPlugin();
    mockProfileService = MockProfileService();

    final getIt = GetIt.instance;
    getIt.registerSingleton<FlutterLocalNotificationsPlugin>(mockPlugin);
    getIt.registerSingleton<ProfileService>(mockProfileService);

    when(() => mockPlugin.initialize(any())).thenAnswer((_) async {});

    when(() => mockPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidImpl);

    when(() => mockPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>())
        .thenReturn(mockIOSImpl);

    when(() => mockAndroidImpl.createNotificationChannel(any()))
        .thenAnswer((_) async {});

    when(() => mockIOSImpl.requestPermissions(
      alert: any(named: 'alert'),
      badge: any(named: 'badge'),
      sound: any(named: 'sound'),
    )).thenAnswer((_) async => true);

    when(() => mockPlugin.show(
      any(),
      any(),
      any(),
      any(),
    )).thenAnswer((_) async {});

    when(() => mockProfileService.getNotificationLeadTime())
        .thenAnswer((_) async => 5);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall call) async {
      if (call.method == 'checkPermissionStatus') {
        return 1;
      }
      if (call.method == 'requestPermissions') {
        return <int, int>{0: 1};
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);

    await GetIt.instance.reset();
  });

  testWidgets('sends notification with equal given delay and user delay', (tester) async {
    fakeAsync((async) {
      final service = NotificationService(
        initialize: false,
        plugin: mockPlugin,
        profileService: mockProfileService,
      );

      when(() => mockProfileService.getNotificationLeadTime())
          .thenAnswer((_) async => 5);

      const givenMachineTime = Duration(minutes: 5);

      service.scheduleEarlyMachineNotification(
        id: 1,
        machineTime: givenMachineTime,
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
  testWidgets('sends notification when given delay is greater than user delay', (tester) async {
    fakeAsync((async) {
      final service = NotificationService(
        initialize: false,
        plugin: mockPlugin,
        profileService: mockProfileService,
      );

      when(() => mockProfileService.getNotificationLeadTime())
          .thenAnswer((_) async => 5);

      const givenMachineTime = Duration(minutes: 20);

      service.scheduleEarlyMachineNotification(
        id: 2,
        machineTime: givenMachineTime,
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

  testWidgets('sends "Machine Started!" when user delay is greater than given delay', (tester) async {
    fakeAsync((async) {
      final service = NotificationService(
        initialize: false,
        plugin: mockPlugin,
        profileService: mockProfileService,
      );

      when(() => mockProfileService.getNotificationLeadTime())
          .thenAnswer((_) async => 5);

      const givenMachineTime = Duration(minutes: 3);

      service.scheduleEarlyMachineNotification(
        id: 3,
        machineTime: givenMachineTime,
      );

      async.elapse(Duration.zero);

      verify(() =>
          mockPlugin.show(
            3,
            "Machine Started!",
            "Your machine will be finished in 3 minutes!",
            any(),
          )).called(1);
    });
  });
  }