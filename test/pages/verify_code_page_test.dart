import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/pages/reset_protected_page.dart';
import 'package:clean_stream_laundry_app/pages/verify_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../logic/viewmodels/mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }

    getIt.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() => GetIt.instance.reset());

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      initialLocation: '/verify-code',
      routes: [
        GoRoute(
          path: '/verify-code',
          builder: (context, state) =>
              CodeVerificationPage(email: "testEmail"),
        ),
        GoRoute(
          path: '/reset-protected',
          builder: (context, state) =>
              ResetProtectedPage(),
        )
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group("UI elements render correctly", (){

    testWidgets('validates title renders', (tester) async {

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();

      expect(find.text("Verify Code"), findsOneWidget);

    });

    testWidgets('Subheading renders', (tester) async {

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();

      expect(find.text("Enter Verification Code"), findsOneWidget);

    });

    testWidgets('Instructions render', (tester) async {

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();

      expect(find.text("We sent a 6-digit code to"), findsOneWidget);

    });

    testWidgets('Text field renders', (tester) async {

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

    });

    testWidgets('Verify Button renders', (tester) async {

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text("Verify"), findsOneWidget);
    });

    testWidgets('Resend Button renders', (tester) async {

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text("Resend code"), findsOneWidget);
    });

  });

  group("Logic tests", (){

    testWidgets('Error is thrown if a code entered is too short', (tester) async {

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '1234');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter the 6-digit code'), findsWidgets);

    });

    testWidgets('Navigates correctly if a correct code was entered', (tester) async {

      when(() => mockAuthService.verifyCode(email: any(named:"email"), code: any(named:"code"))).thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsWidgets);

    });

    testWidgets('Shows error if the code verification was not correct', (tester) async {

      when(() => mockAuthService.verifyCode(email: any(named:"email"), code: any(named:"code"))).thenAnswer((_) async => AuthenticationResponses.failure);

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text("Invalid or expired code"), findsWidgets);

    });

    testWidgets('Shows error if exception was thrown', (tester) async {

      when(() => mockAuthService.verifyCode(email: any(named:"email"), code: any(named:"code"))).thenThrow(Exception());

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text("Something went wrong. Try again"), findsWidgets);

    });

    testWidgets('Shows message if email reset was successful', (tester) async {

      when(() => mockAuthService.resetPassword(any())).thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.text("Password reset email sent! Check your email."), findsWidgets);

    });

    testWidgets('Shows message if email reset was unsuccessful', (tester) async {

      when(() => mockAuthService.resetPassword(any())).thenAnswer((_) async => AuthenticationResponses.failure);

      await tester.pumpWidget(
          createWidgetUnderTest()
      );

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.text("Failed to send reset email."), findsWidgets);

    });

  });

}