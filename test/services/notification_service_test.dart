import 'dart:io';

import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/main.dart' show getIt;
import 'package:clean_stream_laundry_app/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

import '../pages/mocks.dart';

class MockFlutterLocalNotificationsPlugin
    extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin
    extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockIOSFlutterLocalNotificationsPlugin
    extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

class MockProfileService extends Mock implements ProfileService {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidImpl;
  late MockIOSFlutterLocalNotificationsPlugin mockIOSImpl;
  late MockProfileService mockProfileService;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(const AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel',
    ));
    registerFallbackValue(const DarwinNotificationDetails());
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidImpl = MockAndroidFlutterLocalNotificationsPlugin();
    mockIOSImpl = MockIOSFlutterLocalNotificationsPlugin();
    mockProfileService = MockProfileService();

    final getIt = GetIt.instance;

    getIt.registerSingleton<FlutterLocalNotificationsPlugin>(mockPlugin);
    getIt.registerSingleton<ProfileService>(mockProfileService);

    when(() => mockPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidImpl);

    when(() => mockPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>())
        .thenReturn(mockIOSImpl);

    when(() => mockPlugin.initialize(any())).thenAnswer((_) async {});
    when(() => mockAndroidImpl.createNotificationChannel(any()))
        .thenAnswer((_) async {});
  });

  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(mockPlugin);

  tearDown(() {
    GetIt.instance.reset();
  });

  NotificationService createService() {
    final service = NotificationService();
    service.flutterLocalNotificationsPlugin = mockPlugin;
    return service;
  }

  group('RequestPermission', () {
    test('iOS → permission granted', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      when(() => mockIOSImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      )).thenAnswer((_) async => true);

      final service = createService();
      final result = await service._requestPermission();

      expect(result, true);
    });

    test('iOS → permission denied', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      when(() => mockIOSImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      )).thenAnswer((_) async => false);

      final service = createService();
      final result = await service._requestPermission();

      expect(result, false);
    });

    test('Android → already granted', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => Permission.notification.status)
          .thenAnswer((_) async => PermissionStatus.granted);

      final service = createService();
      final result = await service._requestPermission();

      expect(result, true);
    });

    test('Android → request granted', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => Permission.notification.status)
          .thenAnswer((_) async => PermissionStatus.denied);

      when(() => Permission.notification.request())
          .thenAnswer((_) async => PermissionStatus.granted);

      final service = createService();
      final result = await service._requestPermission();

      expect(result, true);
    });

    test('Android → request denied', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => Permission.notification.status)
          .thenAnswer((_) async => PermissionStatus.denied);

      when(() => Permission.notification.request())
          .thenAnswer((_) async => PermissionStatus.denied);

      final service = createService();
      final result = await service._requestPermission();

      expect(result, false);
    });
  });

  group('scheduleNotification', () {
    test('does nothing when permission denied', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => Permission.notification.status)
          .thenAnswer((_) async => PermissionStatus.denied);

      when(() => Permission.notification.request())
          .thenAnswer((_) async => PermissionStatus.denied);

      final service = createService();

      await service.scheduleNotification(
        id: 1,
        title: 'Test',
        body: 'Body',
        delay: Duration.zero,
      );

      verifyNever(() => mockPlugin.show(any(), any(), any(), any()));
    });

    test('schedules notification when allowed', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => Permission.notification.status)
          .thenAnswer((_) async => PermissionStatus.granted);

      when(() => mockPlugin.show(
        any(),
        any(),
        any(),
        any(),
      )).thenAnswer((_) async {});

      final service = createService();

      await service.scheduleNotification(
        id: 1,
        title: 'Test',
        body: 'Body',
        delay: Duration.zero,
      );

      await Future.delayed(Duration.zero);

      verify(() => mockPlugin.show(
        1,
        'Test',
        'Body',
        any(),
      )).called(1);
    });
  });

  group('scheduleDelayedMachineNotification', () {
    test('negative total delay → Machine Started!', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => Permission.notification.status)
          .thenAnswer((_) async => PermissionStatus.granted);

      when(() => mockProfileService.getNotificationDelay())
          .thenAnswer((_) async => 10);

      when(() => mockPlugin.show(any(), any(), any(), any()))
          .thenAnswer((_) async {});

      final service = createService();

      await service.scheduleDelayedMachineNotification(
        id: 1,
        givenDelay: Duration(minutes: 5),
      );

      await Future.delayed(Duration.zero);

      verify(() => mockPlugin.show(
        1,
        'Machine Started!',
        'Your machine will be finished in 5 minutes!',
        any(),
      )).called(1);
    });

    test('userDelayMinutes == 0 → Machine Finished!', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => Permission.notification.status)
          .thenAnswer((_) async => PermissionStatus.granted);

      when(() => mockProfileService.getNotificationDelay())
          .thenAnswer((_) async => 0);

      when(() => mockPlugin.show(any(), any(), any(), any()))
          .thenAnswer((_) async {});

      final service = createService();

      await service.scheduleDelayedMachineNotification(
        id: 1,
        givenDelay: Duration(minutes: 5),
      );

      await Future.delayed(Duration.zero);

      verify(() => mockPlugin.show(
        1,
        'Machine Finished!',
        'Your machine is finished',
        any(),
      )).called(1);
    });

    test('positive delay → Machine Almost Ready', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => Permission.notification.status)
          .thenAnswer((_) async => PermissionStatus.granted);

      when(() => mockProfileService.getNotificationDelay())
          .thenAnswer((_) async => 3);

      when(() => mockPlugin.show(any(), any(), any(), any()))
          .thenAnswer((_) async {});

      final service = createService();

      await service.scheduleDelayedMachineNotification(
        id: 1,
        givenDelay: Duration(minutes: 10),
      );

      await Future.delayed(Duration(minutes: 7));

      verify(() => mockPlugin.show(
        1,
        'Machine Almost Ready',
        'Your machine will be ready in 3 minutes!',
        any(),
      )).called(1);
    });
  });
}