import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}
class MockProfileService extends Mock implements ProfileService {}
class FakeUri extends Fake implements Uri {}

class FakeAppLinks implements AppLinks {
  final StreamController<Uri> _controller =
  StreamController<Uri>.broadcast();

  void emit(Uri uri) => _controller.add(uri);
  void dispose() => _controller.close();

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}