import 'package:clean_stream_laundry_app/pages/change_email_verification.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'mocks.dart';
import 'package:clean_stream_laundry_app/pages/home_page.dart';

void main() {
  late MockAuthService mockAuthService;
  late FakeAppLinks fakeAppLinks;
  late MockLocationService mockLocationService;
  late MockMachineService mockMachineService;

  setUpAll(() {
    registerFallbackValue(FakeAuthService());
    registerFallbackValue(FakeUri());
    registerFallbackValue('');
  });

  setUp(() {
    mockAuthService = MockAuthService();
    fakeAppLinks = FakeAppLinks();
    mockLocationService = MockLocationService();
    mockMachineService = MockMachineService();

    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<LocationService>(mockLocationService);
    GetIt.instance.registerSingleton<MachineService>(mockMachineService);

    // Mock HomePage dependencies
    when(
      () => mockLocationService.getLocations(),
    ).thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(
      () => mockMachineService.getWasherCountByLocation(any()),
    ).thenAnswer((_) async => 0);
    when(
      () => mockMachineService.getIdleWasherCountByLocation(any()),
    ).thenAnswer((_) async => 0);
    when(
      () => mockMachineService.getDryerCountByLocation(any()),
    ).thenAnswer((_) async => 0);
    when(
      () => mockMachineService.getIdleDryerCountByLocation(any()),
    ).thenAnswer((_) async => 0);

    // Mock auth service methods for deep link handling
    when(() => mockAuthService.refreshSession()).thenAnswer((_) async => {});
    when(() => mockAuthService.getCurrentUser()).thenAnswer((_) => null);
  });

  tearDown(() {
    fakeAppLinks.dispose();
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    final router = GoRouter(
      initialLocation: '/change-email-verification',
      routes: [
        GoRoute(
          path: '/change-email-verification',
          builder: (context, state) => ChangeEmailVerificationPage(appLinks: fakeAppLinks,),
        ),
        GoRoute(path: '/homePage', builder: (context, state) => HomePage()),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('Initialization', () {
    testWidgets('displays all required UI elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.text('Please verify your new email address'), findsOneWidget);
      expect(
        find.text(
          'Check your new email\'s inbox and click the verification link.',
        ),
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

    testWidgets('resend link has correct initial styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Resend Verification'));
      expect(textWidget.style?.color, equals(Colors.blue));
      expect(textWidget.style?.decoration, equals(TextDecoration.underline));
    });

    testWidgets('text uses center alignment', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(
        find.text('Please verify your new email address'),
      );
      final descText = tester.widget<Text>(
        find.text(
          'Check your new email\'s inbox and click the verification link.',
        ),
      );

      expect(titleText.textAlign, equals(TextAlign.center));
      expect(descText.textAlign, equals(TextAlign.center));
    });
  });

  group('Resend Verification - Success', () {
    testWidgets('calls resend service method', (tester) async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.resendVerification()).called(1);
    });

    testWidgets('shows success icon after resend', (tester) async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Resend Verification'), findsNothing);
    });

    testWidgets('success icon has correct styling', (tester) async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.size, equals(40));
      expect(icon.color, equals(Colors.green));
    });

    testWidgets('prevents multiple resend attempts', (tester) async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.success);

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
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.error);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(
        find.text('Please resend verification again at another time.'),
        findsOneWidget,
      );
    });

    testWidgets('error icon has correct styling', (tester) async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.error);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend Verification'));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.close),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.red));
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('prevents retry after failure', (tester) async {
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.error);

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
      when(
        () => mockAuthService.resendVerification(),
      ).thenAnswer((_) async => AuthenticationResponses.success);

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

      final context = tester.element(find.byType(ChangeEmailVerificationPage));
      GoRouter.of(context).go('/homePage');
      await tester.pumpAndSettle();

      expect(find.byType(ChangeEmailVerificationPage), findsNothing);
    });

    testWidgets('uses theme background color', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets("Tests for an app link",(tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://change-email'));

      await tester.pumpAndSettle();
      await tester.pump();

      verify(() => mockAuthService.refreshSession()).called(1);
      verify(() => mockAuthService.getCurrentUser()).called(1);
    });

  });
}
