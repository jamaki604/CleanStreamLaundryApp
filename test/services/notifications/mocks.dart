import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:app_links/app_links.dart';

class MockProfileService extends Mock implements ProfileService {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockIOSFlutterLocalNotificationsPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

class FakeAppLinks extends Fake implements AppLinks {
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  void emit(Uri uri) => _controller.add(uri);

  void dispose() => _controller.close();
}