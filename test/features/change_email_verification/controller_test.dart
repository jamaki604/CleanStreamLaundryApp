import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/features/change_email_verification/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late FakeAppLinks fakeAppLinks;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockAuthService = MockAuthService();
    fakeAppLinks = FakeAppLinks();
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() {
    fakeAppLinks.dispose();
    GetIt.instance.reset();
  });

  /// Minimal widget tree
  Widget buildWithContext(
      Widget Function(BuildContext context) builder) {
    return MaterialApp(home: Builder(builder: builder));
  }

  /// GoRouter widget tree - initial route creates and inits controller,
  /// use for deep-link and nav tests.
  Widget buildWithRouter({
    required FakeAppLinks appLinks,
    required void Function(ChangeEmailVerificationController) onControllerReady,
  }) {
    final router = GoRouter(
      initialLocation: '/change-email-verification',
      routes: [
        GoRoute(
          path: '/change-email-verification',
          builder: (context, state) {
            final controller = ChangeEmailVerificationController(
              appLinks: appLinks,
              context: context,
            );
            onControllerReady(controller);
            controller.init();
            return const SizedBox();
          },
        ),
        GoRoute(
          path: '/editProfile',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('resendVerification', () {
    testWidgets('resend verification is called', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      late ChangeEmailVerificationController controller;

      await tester.pumpWidget(buildWithContext((context) {
        controller = ChangeEmailVerificationController(
          appLinks: fakeAppLinks,
          context: context,
        );
        return const SizedBox();
      }));

      await controller.resendVerification();

      verify(() => mockAuthService.resendVerification()).called(1);
    });

    testWidgets('sets resent to true on success', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      late ChangeEmailVerificationController controller;

      await tester.pumpWidget(buildWithContext((context) {
        controller = ChangeEmailVerificationController(
          appLinks: fakeAppLinks,
          context: context,
        );
        return const SizedBox();
      }));

      await controller.resendVerification();

      expect(controller.resent, isTrue);
      expect(controller.lastResponse, equals(AuthenticationResponses.success));
    });

    testWidgets('sets lastResponse on failure and does not set resent',
            (tester) async {
          when(() => mockAuthService.resendVerification())
              .thenAnswer((_) async => AuthenticationResponses.error);

          late ChangeEmailVerificationController controller;

          await tester.pumpWidget(buildWithContext((context) {
            controller = ChangeEmailVerificationController(
              appLinks: fakeAppLinks,
              context: context,
            );
            return const SizedBox();
          }));

          await controller.resendVerification();

          expect(controller.resent, isFalse);
          expect(controller.lastResponse, equals(AuthenticationResponses.error));
        });

    testWidgets('does not call resend again when already resent',
            (tester) async {
          when(() => mockAuthService.resendVerification())
              .thenAnswer((_) async => AuthenticationResponses.success);

          late ChangeEmailVerificationController controller;

          await tester.pumpWidget(buildWithContext((context) {
            controller = ChangeEmailVerificationController(
              appLinks: fakeAppLinks,
              context: context,
            );
            return const SizedBox();
          }));

          await controller.resendVerification();
          await controller.resendVerification();

          verify(() => mockAuthService.resendVerification()).called(1);
        });
  });

  group('Deep link handling', () {
    testWidgets('verifies session refresh and getCurrentUser() is called on deep link nav', (tester) async {
      when(() => mockAuthService.refreshSession()).thenAnswer((_) async => {});
      when(() => mockAuthService.getCurrentUser()).thenAnswer((_) => null);

      await tester.pumpWidget(
        buildWithRouter(
          appLinks: fakeAppLinks,
          onControllerReady: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://change-email'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.refreshSession()).called(1);
      verify(() => mockAuthService.getCurrentUser()).called(1);
    });
  });
  
  group('Lifecycle', () {
    testWidgets('dispose cancels stream subscription without error',
            (tester) async {
          late ChangeEmailVerificationController controller;

          await tester.pumpWidget(buildWithContext((context) {
            controller = ChangeEmailVerificationController(
              appLinks: fakeAppLinks,
              context: context,
            );
            controller.init();
            return const SizedBox();
          }));

          expect(() => controller.dispose(), returnsNormally);
        });
  });
}