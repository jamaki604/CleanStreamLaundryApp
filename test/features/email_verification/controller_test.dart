import 'dart:async';
import 'package:clean_stream_laundry_app/features/email_verification/controller.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late StreamController<bool> authChangeController;
  late FakeAppLinks fakeAppLinks;

  setUpAll(() {
    registerFallbackValue(FakeAuthService());
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    authChangeController = StreamController<bool>.broadcast();
    fakeAppLinks = FakeAppLinks();

    GetIt.instance.registerSingleton<AuthService>(mockAuthService);

    when(() => mockAuthService.onAuthChange)
        .thenAnswer((_) => authChangeController.stream);
    when(() => mockAuthService.isEmailVerified()).thenReturn(false);
  });

  tearDown(() {
    authChangeController.close();
    fakeAppLinks.dispose();
    GetIt.instance.reset();
  });

  /// minimal GoRouter - controller needs a context
  Widget buildWithRouter({
    required void Function(EmailVerificationController) onControllerReady,
  }) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/email-verification',
        routes: [
          GoRoute(
            path: '/email-verification',
            builder: (context, state) {
              final controller = EmailVerificationController(
                appLinks: fakeAppLinks,
                context: context,
              );
              onControllerReady(controller);
              controller.init();
              return const SizedBox();
            },
          ),
          GoRoute(
            path: '/homePage',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
        ],
      ),
    );
  }

  group('resendVerification', () {
    testWidgets('calls auth service resendVerification', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      late EmailVerificationController controller;
      await tester.pumpWidget(
        buildWithRouter(onControllerReady: (c) => controller = c),
      );

      await controller.resendVerification();

      verify(() => mockAuthService.resendVerification()).called(1);
    });

    testWidgets('sets resent to true on success', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      late EmailVerificationController controller;
      await tester.pumpWidget(
        buildWithRouter(onControllerReady: (c) => controller = c),
      );

      await controller.resendVerification();

      expect(controller.resent, isTrue);
      expect(controller.lastResponse, AuthenticationResponses.success);
    });

    testWidgets('sets lastResponse on failure, resent stays false',
            (tester) async {
          when(() => mockAuthService.resendVerification())
              .thenAnswer((_) async => AuthenticationResponses.failure);

          late EmailVerificationController controller;
          await tester.pumpWidget(
            buildWithRouter(onControllerReady: (c) => controller = c),
          );

          await controller.resendVerification();

          expect(controller.resent, isFalse);
          expect(controller.lastResponse, AuthenticationResponses.failure);
        });

    testWidgets('does not call service again when already resent',
            (tester) async {
          when(() => mockAuthService.resendVerification())
              .thenAnswer((_) async => AuthenticationResponses.success);

          late EmailVerificationController controller;
          await tester.pumpWidget(
            buildWithRouter(onControllerReady: (c) => controller = c),
          );

          await controller.resendVerification();
          await controller.resendVerification();

          verify(() => mockAuthService.resendVerification()).called(1);
        });
  });

  group('Auth change listener', () {
    testWidgets('calls isEmailVerified when authState changes',
            (tester) async {
          when(() => mockAuthService.isEmailVerified()).thenReturn(true);

          await tester.pumpWidget(buildWithRouter(onControllerReady: (_) {}));
          await tester.pumpAndSettle();

          authChangeController.add(true);
          await tester.pumpAndSettle();


          verify(() => mockAuthService.isEmailVerified()).called(1);
        });

    testWidgets('does not navigate when logged in but email not verified',
            (tester) async {
          when(() => mockAuthService.isEmailVerified()).thenReturn(false);

          await tester.pumpWidget(buildWithRouter(onControllerReady: (_) {}));
          await tester.pumpAndSettle();

          authChangeController.add(true);
          await tester.pumpAndSettle();

          expect(find.text('Home'), findsNothing);
        });

    testWidgets('does not navigate when auth emits false', (tester) async {
      when(() => mockAuthService.isEmailVerified()).thenReturn(true);

      await tester.pumpWidget(buildWithRouter(onControllerReady: (_) {}));
      await tester.pumpAndSettle();

      authChangeController.add(false);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsNothing);
    });
  });

  group('Deep link handling', () {
    testWidgets('calls getSessionFromURI on valid deep link', (tester) async {
      when(() => mockAuthService.getSessionFromURI(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildWithRouter(onControllerReady: (_) {}));
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://email-verification'));
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.pumpAndSettle();

      verify(() => mockAuthService.getSessionFromURI(any())).called(1);
    });

    testWidgets('ignores URIs with wrong host', (tester) async {
      await tester.pumpWidget(buildWithRouter(onControllerReady: (_) {}));
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://wrong-host'));
      await tester.pumpAndSettle();

      verifyNever(() => mockAuthService.getSessionFromURI(any()));
      expect(find.text('Home'), findsNothing);
    });
  });


  group('Lifecycle', () {
    testWidgets('dispose cancels subscriptions without error', (tester) async {
      late EmailVerificationController controller;
      await tester.pumpWidget(
        buildWithRouter(onControllerReady: (c) => controller = c),
      );

      expect(() => controller.dispose(), returnsNormally);
    });
  });
}