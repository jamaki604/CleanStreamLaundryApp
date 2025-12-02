import 'package:clean_stream_laundry_app/Logic/Enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/profile_service.dart';
import 'package:clean_stream_laundry_app/Pages/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;
  late GoRouter router;

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

    router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => SignUpScreen()),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Page')),
        ),
        GoRoute(
          path: '/email-verification',
          builder: (context, state) =>
              const Scaffold(body: Text('Email Verification Page')),
        ),
      ],
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  // Helper function to set up test viewport with enough height for SignUpScreen
  void setupViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());
  }

  Widget createWidgetUnderTest() {
    return MaterialApp.router(routerConfig: router);
  }

  group('SignUpScreen Widget Tests', () {
    testWidgets('should display logo', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Image), findsOneWidget);
    });
    testWidgets('should display all input fields', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsNWidgets(4));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('should display Create Account button', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(
        find.widgetWithText(ElevatedButton, 'Create Account'),
        findsOneWidget,
      );
    });

    testWidgets('should display login link', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Already have an account? Login'), findsOneWidget);
    });

    testWidgets('should navigate to login when login link is tapped', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('should show error when fields are empty', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields.'), findsOneWidget);
    });

    testWidgets('should show error when passwords do not match', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'Password123!');
      await tester.enterText(find.byType(TextField).at(3), 'Password456!');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });



    testWidgets('should navigate to email verification on success',
            (WidgetTester tester) async {
          // 1️⃣ Mock AuthService → success
          when(() => mockAuthService.signUp(any(), any()))
              .thenAnswer((_) async => AuthenticationResponses.success);

          // 2️⃣ Mock ProfileService → accept any args
          when(() => mockProfileService.createAccount(
              name: any(named: 'name'), id: any(named: 'id')))
              .thenAnswer((_) async => {});

          // 3️⃣ Build the widget
          setupViewport(tester);
          await tester.pumpWidget(createWidgetUnderTest());

          // 4️⃣ Fill the form
          await tester.enterText(find.byType(TextField).at(0), 'Test User');
          await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
          await tester.enterText(find.byType(TextField).at(2), 'Password123!');
          await tester.enterText(find.byType(TextField).at(3), 'Password123!');

          // 5️⃣ Submit
          await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
          await tester.pump(); // start async work
          await tester.pumpAndSettle(const Duration(seconds: 2)); // wait for navigation

          // 6️⃣ Verify navigation
          expect(find.text('Email Verification Page'), findsOneWidget);
        });

    testWidgets('should show error for password without digit', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      when(
        () => mockAuthService.signUp(any(), any()),
      ).thenAnswer((_) async => AuthenticationResponses.noDigit);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'Password!');
      await tester.enterText(find.byType(TextField).at(3), 'Password!');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please include a digit'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show error for password too short', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      when(
        () => mockAuthService.signUp(any(), any()),
      ).thenAnswer((_) async => AuthenticationResponses.lessThanMinLength);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'Pass1!');
      await tester.enterText(find.byType(TextField).at(3), 'Pass1!');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password length is too short'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('should show error for password without special character', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      when(
        () => mockAuthService.signUp(any(), any()),
      ).thenAnswer((_) async => AuthenticationResponses.noSpecialCharacter);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'Password123');
      await tester.enterText(find.byType(TextField).at(3), 'Password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please include a special character'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('should show error for password without uppercase', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      when(
        () => mockAuthService.signUp(any(), any()),
      ).thenAnswer((_) async => AuthenticationResponses.noUppercase);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'password123!');
      await tester.enterText(find.byType(TextField).at(3), 'password123!');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please include an uppercase letter'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('should show error for invalid special character', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      when(() => mockAuthService.signUp(any(), any())).thenAnswer(
        (_) async => AuthenticationResponses.invalidSpecialCharacter,
      );

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).at(0), 'Test User');
      await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'Password123<');
      await tester.enterText(find.byType(TextField).at(3), 'Password123<');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please use a different special character'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('should have correct button styles', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create Account'),
      );

      expect(button.style, isNotNull);
    });

    testWidgets('should have all text fields with proper icons', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      final nameField = tester.widget<TextField>(find.byType(TextField).at(0));
      final emailField = tester.widget<TextField>(find.byType(TextField).at(1));
      final passwordField = tester.widget<TextField>(
        find.byType(TextField).at(2),
      );
      final confirmPasswordField = tester.widget<TextField>(
        find.byType(TextField).at(3),
      );

      expect((nameField.decoration as InputDecoration).prefixIcon, isA<Icon>());
      expect(
        (emailField.decoration as InputDecoration).prefixIcon,
        isA<Icon>(),
      );
      expect(
        (passwordField.decoration as InputDecoration).prefixIcon,
        isA<Icon>(),
      );
      expect(
        (confirmPasswordField.decoration as InputDecoration).prefixIcon,
        isA<Icon>(),
      );
    });

    testWidgets('password fields should be obscured', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      final passwordField = tester.widget<TextField>(
        find.byType(TextField).at(2),
      );
      final confirmPasswordField = tester.widget<TextField>(
        find.byType(TextField).at(3),
      );

      expect(passwordField.obscureText, true);
      expect(confirmPasswordField.obscureText, true);
    });
  });
}
