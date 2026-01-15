import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }

    if (getIt.isRegistered<ProfileService>()) {
      getIt.unregister<ProfileService>();
    }

    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<ProfileService>(mockProfileService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(
            body: Text('Login Page'),
          ),
        ),
        GoRoute(
          path: '/homePage',
          builder: (context, state) => const Scaffold(
            body: Text('Home Page'),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('LoadingPage Widget Tests', () {
    testWidgets('displays logo animation when no error', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.text('authentication Failed'), findsNothing);

      await tester.pumpAndSettle();
    });

    testWidgets('displays error UI when authentication fails', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Authentication Failed'), findsOneWidget);
      expect(find.text('Exception: Network error'), findsOneWidget);
      expect(find.text('Return to Login'), findsOneWidget);
    });

    testWidgets('error button navigates to login page', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenThrow(Exception('Auth failed'));

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Return to Login'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });
  });

  group('authentication logic Tests', () {
    testWidgets('navigates to home page when user is logged in', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
      verify(() => mockAuthService.isLoggedIn()).called(1);
    });

    testWidgets('navigates to login page when user is not logged in', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.failure);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
      verify(() => mockAuthService.isLoggedIn()).called(1);
    });

    testWidgets('handles authentication service errors gracefully', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenThrow(Exception('Service unavailable'));

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Authentication Failed'), findsOneWidget);
      expect(find.text('Exception: Service unavailable'), findsOneWidget);
    });
  });

  group('Animation Tests', () {
    testWidgets('logo animation is present and configured correctly', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 3));
        return AuthenticationResponses.success;
      });

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pump();

      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);

      final animationBuilder = tester.widget<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );

      expect(animationBuilder.tween.begin, 0.95);
      expect(animationBuilder.tween.end, 1.05);
      expect(animationBuilder.duration, const Duration(seconds: 1));
      expect(find.byType(Transform), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('animation does not show when error occurs', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenThrow(Exception('Error'));

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      expect(find.byType(Image), findsNothing);
    });
  });

  group('Cold Start Tests', () {
    testWidgets('navigates correctly after authentication check', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.isLoggedIn()).called(1);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('handles authentication during cold start', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.failure);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });
  });

  group('Deep Link Tests', () {
    testWidgets('navigates to home page on email verification deep link', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.app_links/messages'),
            (MethodCall methodCall) async {
          if (methodCall.method == 'getInitialAppLink') {
            return 'clean-stream://email-verification';
          }
          return null;
        },
      );

      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('handles null initial app link', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.app_links/messages'),
            (MethodCall methodCall) async {
          if (methodCall.method == 'getInitialAppLink') {
            return null;
          }
          return null;
        },
      );

      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('ignores deep link with wrong scheme', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.app_links/messages'),
            (MethodCall methodCall) async {
          if (methodCall.method == 'getInitialAppLink') {
            return 'https://email-verification';
          }
          return null;
        },
      );

      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('ignores deep link with wrong host', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.app_links/messages'),
            (MethodCall methodCall) async {
          if (methodCall.method == 'getInitialAppLink') {
            return 'clean-stream://wrong-host';
          }
          return null;
        },
      );

      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.app_links/messages'),
        null,
      );
    });
  });

  group('State Management Tests', () {
    testWidgets('does not navigate if widget is unmounted', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return AuthenticationResponses.success;
      });

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });

  group('UI Element Tests', () {
    testWidgets('error icon has correct properties', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenThrow(Exception('Error'));

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, Colors.redAccent);
      expect(icon.size, 80);
    });

    testWidgets('logo has correct dimensions', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.height, 250);

      await tester.pumpAndSettle();
    });

    testWidgets('all text elements are present in error state', (WidgetTester tester) async {
      when(() => mockAuthService.isLoggedIn())
          .thenThrow(Exception('Test error'));

      await tester.pumpWidget(createTestWidget(LoadingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Authentication Failed'), findsOneWidget);
      expect(find.text('Exception: Test error'), findsOneWidget);
      expect(find.text('Return to Login'), findsOneWidget);
    });
  });
}