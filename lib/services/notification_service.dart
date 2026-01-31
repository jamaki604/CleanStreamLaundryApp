import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import '../main.dart';


class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final ProfileService profileService;

  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    ProfileService? profileService, required bool initialize,
  })  : flutterLocalNotificationsPlugin =
      plugin ?? getIt<FlutterLocalNotificationsPlugin>(),
        profileService = profileService ?? getIt<ProfileService>() {
    _init();
  }

  Future<bool> _requestPermission() async {

    // iOS permission
    if (Platform.isIOS) {
      final ios = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final result = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    //Android permission
    final status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  Future<void> _init() async {
    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'your_channel_id',
      'Your Channel',
      description: 'General notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    final allowed = await _requestPermission();
    if (!allowed) {
      return;
    }

    Future.delayed(delay, () async {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'Your Channel',
            importance: Importance.high,
            priority: Priority.high,
          ),
           iOS: DarwinNotificationDetails(
             presentAlert: true,
             presentBadge: true,
             presentSound: true,
            )
        ),
      );
    });
  }

  Future<void> scheduleDelayedMachineNotification({
    required int id,
    required Duration givenDelay,
  }) async {
    final allowed = await _requestPermission();
    if (!allowed) return;

    final userDelayMinutes = await profileService.getNotificationDelay();
    final userDelay = Duration(minutes: userDelayMinutes);

    Duration totalDelay = givenDelay - userDelay;

    String notifTitle;
    String notifBody;

    if (totalDelay.isNegative) {
      totalDelay = Duration.zero;
      notifTitle = "Machine Started!";
      final roundedDelay = givenDelay.inMinutes;
      final unit = roundedDelay == 1 ? "minute" : "minutes";
      notifBody = "Your machine will be finished in $roundedDelay $unit!";
    }
    else if(userDelayMinutes == 0){
      notifTitle = "Machine Finished!";
      notifBody = "Your machine is finished";
  }
    else {
      notifTitle = "Machine Almost Ready";

      final unit = userDelayMinutes == 1 ? "minute" : "minutes";
      notifBody = "Your machine will be ready in $userDelayMinutes $unit!";
    }

    Future.delayed(totalDelay, () async {
      await flutterLocalNotificationsPlugin.show(
        id,
        notifTitle,
        notifBody,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'Your Channel',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    });
  }
}