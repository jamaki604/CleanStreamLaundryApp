import 'dart:async';
import 'package:clean_stream_laundry_app/features/email_verification/email_verification.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late StreamController<bool> authChangeController;
  late MockMachineService mockMachineService;
  late MockLocationService mockLocationService;
  late MockProfileService mockProfileService;
  late FakeAppLinks fakeAppLinks;

  setUpAll(() {
    registerFallbackValue(FakeAuthService());
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    authChangeController = StreamController<bool>.broadcast();
    mockMachineService = MockMachineService();
    mockLocationService = MockLocationService();
    mockProfileService = MockProfileService();
    fakeAppLinks = FakeAppLinks();

    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<MachineService>(mockMachineService);
    GetIt.instance.registerSingleton<LocationService>(mockLocationService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);

    when(() => mockAuthService.onAuthChange)
        .thenAnswer((_) => authChangeController.stream);
    when(() => mockAuthService.isEmailVerified()).thenReturn(false);
    when(() => mockLocationService.getLocations())
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
  });

  tearDown(() {
    authChangeController.close();
    fakeAppLinks.dispose();
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/email-verification',
        routes: [
          GoRoute(
            path: '/email-verification',
            builder: (context, state) =>
                EmailVerificationPage(appLinks: fakeAppLinks),
          ),
          GoRoute(
            path: '/homePage',
            builder: (context, state) => HomePage(),
          ),
          GoRoute(
            path: '/scanner',
            builder: (context, state) =>
            const Scaffold(body: Text('Scanner Page')),
          ),
        ],
      ),
    );
  }

  group('Static UI', () {
    testWidgets('displays all required UI elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.text('Please verify your email address'), findsOneWidget);
      expect(
        find.text('Check your inbox and click the verification link.'),
        findsOneWidget,
      );
      expect(find.text('Resend Verification'), findsOneWidget);
    });

    testWidgets('email icon has correct styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.email));
      expect(icon.size, equals(80));
      expect(icon.color, equals(Colors.blueAccent));
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

    testWidgets('uses theme surface color as scaffold background',
            (tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
          expect(scaffold.backgroundColor, isNotNull);
        });
  });

  group('Navigation', () {
    testWidgets('verifies email verification check called', (tester) async {
      when(() => mockAuthService.isEmailVerified()).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      authChangeController.add(true);
      await tester.pumpAndSettle();

      verify(() => mockAuthService.isEmailVerified()).called(1);
    });

    testWidgets('stays on page when email not verified', (tester) async {
      when(() => mockAuthService.isEmailVerified()).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      authChangeController.add(true);
      await tester.pumpAndSettle();

      expect(find.text('Please verify your email address'), findsOneWidget);
    });

    testWidgets('stays on page when auth emits false (logout)', (tester) async {
      when(() => mockAuthService.isEmailVerified()).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      authChangeController.add(false);
      await tester.pumpAndSettle();

      expect(find.text('Please verify your email address'), findsOneWidget);
    });

    testWidgets('verifies deeplink gets session', (tester) async {
      when(() => mockAuthService.getSessionFromURI(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://email-verification'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.getSessionFromURI(any())).called(1);
    });

    testWidgets('ignores deep link with wrong host', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://other-host'));
      await tester.pumpAndSettle();

      expect(find.text('Please verify your email address'), findsOneWidget);
    });
  });

  group('Lifecycle', () {
    testWidgets('properly disposes controller on navigation away',
            (tester) async {
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final context =
          tester.element(find.byType(EmailVerificationPage));
          GoRouter.of(context).go('/scanner');
          await tester.pumpAndSettle();

          expect(find.byType(EmailVerificationPage), findsNothing);
        });
  });
}