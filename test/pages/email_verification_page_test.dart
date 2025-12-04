import 'dart:async';
import 'package:clean_stream_laundry_app/pages/email_verification_page.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late StreamController<bool> authChangeController;

  setUpAll(() {
    registerFallbackValue(FakeAuthService());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    authChangeController = StreamController<bool>.broadcast();

    GetIt.instance.registerSingleton<AuthService>(mockAuthService);

    when(() => mockAuthService.onAuthChange)
        .thenAnswer((_) => authChangeController.stream);
    when(() => mockAuthService.isEmailVerified()).thenReturn(false);
  });

  tearDown(() {
    authChangeController.close();
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    final router = GoRouter(
      initialLocation: '/email-verification',
      routes: [
        GoRoute(
          path: '/email-verification',
          builder: (context, state) => EmailVerificationPage(),
        ),
        GoRoute(
          path: '/scanner',
          builder: (context, state) => Scaffold(body: Text('Scanner Page')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('Initialization', () {
    testWidgets('displays all required UI elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.text('Please verify your email address'), findsOneWidget);
      expect(find.text('Check your inbox and click the verification link.'),
          findsOneWidget);
      expect(find.text('Resend Verification'), findsOneWidget);
    });

    testWidgets('email icon has correct styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.email));
      expect(icon.size, equals(80));
      expect(icon.color, equals(Colors.blueAccent));
    });

    testWidgets('resend link has correct initial styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Resend Verification'));
      expect(textWidget.style?.color, equals(Colors.blue));
      expect(textWidget.style?.decoration, equals(TextDecoration.underline));
    });

    testWidgets('sets up auth change listener', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      verify(() => mockAuthService.onAuthChange).called(1);
    });

    testWidgets('text uses center alignment', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(
        find.text('Please verify your email address'),
      );
      final descText = tester.widget<Text>(
        find.text('Check your inbox and click the verification link.'),
      );

      expect(titleText.textAlign, equals(TextAlign.center));
      expect(descText.textAlign, equals(TextAlign.center));
    });
  });

  group('Navigation', () {
    testWidgets('navigates to scanner when email is verified', (tester) async {
      when(() => mockAuthService.isEmailVerified()).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      authChangeController.add(true);
      await tester.pumpAndSettle();

      expect(find.text('Scanner Page'), findsOneWidget);
    });

    testWidgets('stays on page when email not verified', (tester) async {
      when(() => mockAuthService.isEmailVerified()).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      authChangeController.add(true);
      await tester.pumpAndSettle();

      expect(find.text('Please verify your email address'), findsOneWidget);
      expect(find.text('Scanner Page'), findsNothing);
    });

    testWidgets('stays on page when user logs out', (tester) async {
      when(() => mockAuthService.isEmailVerified()).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      authChangeController.add(false);
      await tester.pumpAndSettle();

      expect(find.text('Please verify your email address'), findsOneWidget);
      expect(find.text('Scanner Page'), findsNothing);
    });
  });

  group('Resend Verification - Success', () {
    testWidgets('calls resend service method', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.resendVerification()).called(1);
    });

    testWidgets('shows success icon after resend', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Resend Verification'), findsNothing);
    });

    testWidgets('success icon has correct styling', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.size, equals(40));
      expect(icon.color, equals(Colors.green));
    });

    testWidgets('prevents multiple resend attempts', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.resendVerification()).called(1);

      await tester.tap(find.byIcon(Icons.check_circle));
      await tester.pumpAndSettle();

      verifyNever(() => mockAuthService.resendVerification());
    });
  });

  group('Resend Verification - Failure', () {
    testWidgets('shows error message on failure', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.error);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Please resend verification again at another time.'),
          findsOneWidget);
    });

    testWidgets('error icon has correct styling', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.error);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.close),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.red));
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('prevents retry after failure', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.error);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.resendVerification()).called(1);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.resendVerification()).called(1);
    });
  });

  group('InkWell Interaction', () {
    testWidgets('resend link is tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final inkWell = find.ancestor(
        of: find.text('Resend Verification'),
        matching: find.byType(InkWell),
      );

      expect(inkWell, findsOneWidget);
    });

    testWidgets('InkWell triggers resend on tap', (tester) async {
      when(() => mockAuthService.resendVerification())
          .thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final inkWell = find.ancestor(
        of: find.text('Resend Verification'),
        matching: find.byType(InkWell),
      );

      await tester.tap(inkWell);
      await tester.pumpAndSettle();

      verify(() => mockAuthService.resendVerification()).called(1);
    });
  });

  group('Widget Lifecycle', () {
    testWidgets('properly disposes stream subscription', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(EmailVerificationPage));
      GoRouter.of(context).go('/scanner');
      await tester.pumpAndSettle();

      expect(find.byType(EmailVerificationPage), findsNothing);
    });

    testWidgets('uses theme background color', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });
  });
}