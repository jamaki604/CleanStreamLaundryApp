import 'package:clean_stream_laundry_app/features/loading/controller.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

/// Convenience: run init() with a controllable mounted flag and collect routes.
Future<List<String>> _runInit(
    LoadingPageController controller, {
      bool mounted = true,
    }) async {
  final routes = <String>[];
  await controller.init(
    navigate: (route, {extra}) => routes.add(route),
    isMounted: () => mounted,
  );
  return routes;
}

void main() {
  late MockAuthService mockAuth;
  late MockAppLinks mockAppLinks;

  setUpAll(() {
    // Mocktail needs fallback values for any non-nullable custom types used
    // with any() matchers. Uri is a Dart core type so no fallback needed.
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockAuth = MockAuthService();
    mockAppLinks = MockAppLinks();

    // Default: no deep link
    when(() => mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);
  });

  // ─────────────────────────────────────────────
  // _automaticLogIn
  // ─────────────────────────────────────────────

  group('_automaticLogIn', () {
    test('navigates to /homePage when auth returns success', () async {
      when(() => mockAuth.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      final routes = await _runInit(controller);

      expect(routes, contains('/homePage'));
    });

    test('navigates to /login when auth returns non-success', () async {
      when(() => mockAuth.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.failure);

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      final routes = await _runInit(controller);

      expect(routes, contains('/login'));
    });

    test('sets error and notifies listeners when auth throws', () async {
      when(() => mockAuth.isLoggedIn()).thenThrow(Exception('network error'));

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      bool notified = false;
      controller.addListener(() => notified = true);

      await _runInit(controller);

      expect(controller.error, isNotNull);
      expect(controller.error, contains('network error'));
      expect(notified, isTrue);
    });

    test('does not navigate when isMounted returns false', () async {
      when(() => mockAuth.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      final routes = await _runInit(controller, mounted: false);

      expect(routes, isEmpty);
    });

    test('does not set error when unmounted and auth throws', () async {
      when(() => mockAuth.isLoggedIn()).thenThrow(Exception('oops'));

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      await _runInit(controller, mounted: false);

      expect(controller.error, isNull);
    });
  });

  // ─────────────────────────────────────────────
  // _coldStartRedirect – no deep link
  // ─────────────────────────────────────────────

  group('_coldStartRedirect with no deep link', () {
    test('does not produce a cold-start navigation when initialUri is null',
            () async {
          when(() => mockAuth.isLoggedIn())
              .thenAnswer((_) async => AuthenticationResponses.success);
          when(() => mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);

          final controller = LoadingPageController(
            authService: mockAuth,
            appLinks: mockAppLinks,
          );

          final routes = await _runInit(controller);

          // Only the auth navigation should fire
          expect(routes, equals(['/homePage']));
        });
  });

  // ─────────────────────────────────────────────
  // _coldStartRedirect – reset-protected
  // ─────────────────────────────────────────────

  group('_coldStartRedirect – reset-protected URI', () {
    test('navigates to /reset-protected and passes URI as extra', () async {
      final uri = Uri.parse('clean-stream://reset-protected?token=abc');
      when(() => mockAppLinks.getInitialAppLink()).thenAnswer((_) async => uri);
      when(() => mockAuth.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.failure);

      final capturedExtras = <Object?>[];
      final routes = <String>[];

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      await controller.init(
        navigate: (route, {extra}) {
          routes.add(route);
          capturedExtras.add(extra);
        },
        isMounted: () => true,
      );

      expect(routes, contains('/reset-protected'));
      expect(capturedExtras, contains(uri));
    });
  });

  // ─────────────────────────────────────────────
  // _coldStartRedirect – email-verification
  // ─────────────────────────────────────────────

  group('_coldStartRedirect – email-verification URI', () {
    test('navigates to /homePage for email-verification deep link', () async {
      final uri = Uri.parse('clean-stream://email-verification');
      when(() => mockAppLinks.getInitialAppLink()).thenAnswer((_) async => uri);
      when(() => mockAuth.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.failure);

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      final routes = await _runInit(controller);

      expect(routes, contains('/homePage'));
    });
  });

  // ─────────────────────────────────────────────
  // _coldStartRedirect – change-email
  // ─────────────────────────────────────────────

  group('_coldStartRedirect – change-email URI', () {
    test('navigates to /email-verification for change-email deep link',
            () async {
          final uri = Uri.parse('https://change-email');
          when(() => mockAppLinks.getInitialAppLink()).thenAnswer((_) async => uri);
          when(() => mockAuth.isLoggedIn())
              .thenAnswer((_) async => AuthenticationResponses.failure);

          final controller = LoadingPageController(
            authService: mockAuth,
            appLinks: mockAppLinks,
          );

          final routes = await _runInit(controller);

          expect(routes, contains('/email-verification'));
        });
  });

  // ─────────────────────────────────────────────
  // _coldStartRedirect – oauth
  // ─────────────────────────────────────────────

  group('_coldStartRedirect – oauth URI', () {
    test('calls getSessionFromURI and navigates to /homePage when logged in',
            () async {
          final uri = Uri.parse('clean-stream://oauth?code=xyz');
          when(() => mockAppLinks.getInitialAppLink()).thenAnswer((_) async => uri);
          when(() => mockAuth.getSessionFromURI(uri)).thenAnswer((_) async {});
          when(() => mockAuth.isLoggedIn())
              .thenAnswer((_) async => AuthenticationResponses.success);

          final controller = LoadingPageController(
            authService: mockAuth,
            appLinks: mockAppLinks,
          );

          final routes = await _runInit(controller);

          verify(() => mockAuth.getSessionFromURI(uri)).called(1);
          expect(routes, contains('/homePage'));
        });

    test('navigates to /login after oauth when session is not valid', () async {
      final uri = Uri.parse('clean-stream://oauth?code=xyz');
      when(() => mockAppLinks.getInitialAppLink()).thenAnswer((_) async => uri);
      when(() => mockAuth.getSessionFromURI(uri)).thenAnswer((_) async {});
      when(() => mockAuth.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.failure);

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      final routes = await _runInit(controller);

      expect(routes, contains('/login'));
    });

    test('does not navigate oauth redirect when unmounted', () async {
      final uri = Uri.parse('clean-stream://oauth?code=xyz');
      when(() => mockAppLinks.getInitialAppLink()).thenAnswer((_) async => uri);
      when(() => mockAuth.getSessionFromURI(uri)).thenAnswer((_) async {});
      when(() => mockAuth.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      final routes = await _runInit(controller, mounted: false);

      expect(routes, isEmpty);
    });
  });

  // ─────────────────────────────────────────────
  // _coldStartRedirect – swallows exceptions silently
  // ─────────────────────────────────────────────

  group('_coldStartRedirect error handling', () {
    test('swallows exceptions silently and does not expose error', () async {
      when(() => mockAppLinks.getInitialAppLink())
          .thenThrow(Exception('link error'));
      when(() => mockAuth.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.failure);

      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );

      await expectLater(_runInit(controller), completes);
      expect(controller.error, isNull);
    });
  });

  // ─────────────────────────────────────────────
  // disposeController
  // ─────────────────────────────────────────────

  group('disposeController', () {
    test('can be called without throwing', () {
      final controller = LoadingPageController(
        authService: mockAuth,
        appLinks: mockAppLinks,
      );
      expect(() => controller.disposeController(), returnsNormally);
    });
  });
}