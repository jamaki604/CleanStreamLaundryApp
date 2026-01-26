import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;
  late FakeAppLinks fakeAppLinks;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();
    fakeAppLinks = FakeAppLinks();

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

  tearDown(() => GetIt.instance.reset());

  Widget createWidgetUnderTest({String initialRoute = '/'}) {
    final router = GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => LoginScreen(appLinks: fakeAppLinks),
        ),
        GoRoute(
          path: '/homePage',
          builder: (context, state) => const Scaffold(body: Text('Home Page')),
        ),
        GoRoute(
          path: '/email-Verification',
          builder: (context, state) =>
              const Scaffold(body: Text('Email Verification')),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) =>
              const Scaffold(body: Text('Sign Up Page')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  void mockLoginResponse(AuthenticationResponses response) {
    when(
      () => mockAuthService.login(any(), any()),
    ).thenAnswer((_) async => response);
  }

  Future<void> enterCredentials(
    WidgetTester tester, {
    String email = 'test@example.com',
    String password = 'password123',
  }) async {
    await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      password,
    );
  }

  group('LoginScreen Widget Tests', () {
    group('UI Structure', () {
      testWidgets('should display logo image', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final imageFinder = find.byKey(const Key('app_logo'));
        expect(imageFinder, findsOneWidget);

        final image = tester.widget<Image>(imageFinder);
        expect(image.height, 250);
        expect(image.width, 250);
      });

      testWidgets('should have email and password text fields', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      });

      testWidgets('should have proper icons in text fields', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.email), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsOneWidget);
      });

      testWidgets('should have login button', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
      });

      testWidgets('should have create account link', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Create Account'), findsOneWidget);

        final inkWell = find.ancestor(
          of: find.text('Create Account'),
          matching: find.byType(InkWell),
        );
        expect(inkWell, findsOneWidget);
      });

      testWidgets('should have password field obscured', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final passwordField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Password'),
        );
        expect(passwordField.obscureText, true);
      });
    });

    group('Login Functionality', () {
      testWidgets('should show error when fields are empty', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pump();

        expect(find.text('Please fill in both fields.'), findsOneWidget);
      });

      testWidgets('should show error when email is empty', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Password'),
          'password123',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pump();

        expect(find.text('Please fill in both fields.'), findsOneWidget);
      });

      testWidgets('should show error when password is empty', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Email'),
          'test@example.com',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pump();

        expect(find.text('Please fill in both fields.'), findsOneWidget);
      });

      testWidgets('should show logging in message', (tester) async {
        mockLoginResponse(AuthenticationResponses.success);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await enterCredentials(tester);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pump();

        expect(find.text('Logging in as test@example.com...'), findsOneWidget);
      });

      testWidgets('should navigate to email verification on unverified email', (
        tester,
      ) async {
        mockLoginResponse(AuthenticationResponses.emailNotVerified);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await enterCredentials(tester);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        expect(find.text('Email Verification'), findsOneWidget);
      });

      testWidgets('should change colors to red on failed login', (
        tester,
      ) async {
        mockLoginResponse(AuthenticationResponses.failure);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await enterCredentials(tester);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        expect(find.text('Invalid Password or Email'), findsNWidgets(2));

        final emailIcon = tester.widget<Icon>(find.byIcon(Icons.email));
        expect(emailIcon.color, Colors.red);

        final lockIcon = tester.widget<Icon>(find.byIcon(Icons.lock));
        expect(lockIcon.color, Colors.red);
      });

      testWidgets('should call auth service with correct credentials', (
        tester,
      ) async {
        mockLoginResponse(AuthenticationResponses.success);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        const email = 'test@example.com';
        const password = 'password123';

        await enterCredentials(tester, email: email, password: password);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        verify(() => mockAuthService.login(email, password)).called(1);
      });

      testWidgets('should trim email before login', (tester) async {
        mockLoginResponse(AuthenticationResponses.success);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await enterCredentials(tester, email: '  test@example.com  ');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        verify(
          () => mockAuthService.login('test@example.com', any()),
        ).called(1);
      });

      testWidgets('should have Apple Sign In button', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(ElevatedButton, 'Sign in with Apple'),
          findsOneWidget,
        );
      });

      testWidgets('should have Google Sign In button', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(ElevatedButton, 'Sign in with Google'),
          findsOneWidget,
        );
      });
    });

    group('Navigation', () {
      testWidgets(
        'should navigate to signup page when create account is tapped',
        (tester) async {
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pumpAndSettle();

          final createAccountFinder = find.text('Create Account');
          await tester.ensureVisible(createAccountFinder);
          await tester.tap(find.text('Create Account'));
          await tester.pumpAndSettle();

          expect(find.text('Sign Up Page'), findsOneWidget);
        },
      );
    });

    group('Styling', () {
      testWidgets('should have blue styled login button', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Log In'),
        );
        final buttonStyle = button.style;

        expect(buttonStyle?.backgroundColor?.resolve({}), Colors.blue);
        expect(buttonStyle?.foregroundColor?.resolve({}), Colors.white);
      });

      testWidgets('should have underlined create account text', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final textWidget = tester.widget<Text>(find.text('Create Account'));
        expect(textWidget.style?.color, Colors.blue);
        expect(textWidget.style?.decoration, TextDecoration.underline);
      });

      testWidgets('should have rounded text field borders', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final emailField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Email'),
        );
        final decoration = emailField.decoration as InputDecoration;
        final border = decoration.border as OutlineInputBorder;

        expect(border.borderRadius, BorderRadius.circular(12));
      });
    });

    group('Error State Persistence', () {
      testWidgets('should maintain error colors after failed login', (
        tester,
      ) async {
        mockLoginResponse(AuthenticationResponses.failure);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await enterCredentials(tester);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        await tester.pumpAndSettle();

        expect(find.text('Invalid Password or Email'), findsNWidgets(2));

        final emailIcon = tester.widget<Icon>(find.byIcon(Icons.email));
        expect(emailIcon.color, Colors.red);

        await tester.enterText(
          find.widgetWithText(TextField, 'Invalid Password or Email').first,
          'newtest@example.com',
        );
        await tester.pump();

        final emailIconAfter = tester.widget<Icon>(find.byIcon(Icons.email));
        expect(emailIconAfter.color, Colors.red);
      });
    });

    group('LoginScreen Deep Link Tests', () {
      testWidgets('navigates to /homePage on email-verification link', (
        tester,
      ) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        fakeAppLinks.emit(Uri.parse('clean-stream://email-verification'));
        await tester.pumpAndSettle();

        expect(find.text('Home Page'), findsOneWidget);
      });

      testWidgets('handles oauth link and successful login', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        when(
          () => mockAuthService.handleOAuthRedirect(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockAuthService.isLoggedIn(),
        ).thenAnswer((_) async => AuthenticationResponses.success);
        when(() => mockAuthService.getCurrentUser()).thenReturn(
          User(
            id: 'testId',
            appMetadata: {},
            userMetadata: {'full_name': 'Test User'},
            aud: '',
            createdAt: '',
          ),
        );
        when(
          () => mockProfileService.createAccount(
            id: any(named: 'id'),
            name: any(named: 'name'),
          ),
        ).thenAnswer((_) async {});

        fakeAppLinks.emit(Uri.parse('clean-stream://oauth'));
        await tester.pumpAndSettle();

        expect(find.text('Home Page'), findsOneWidget);
        verify(() => mockAuthService.handleOAuthRedirect(any())).called(1);
        verify(() => mockAuthService.isLoggedIn()).called(1);
        verify(() => mockAuthService.getCurrentUser()).called(1);
        verify(
          () =>
              mockProfileService.createAccount(id: 'testId', name: 'Test User'),
        ).called(1);
      });
    });

    group("Test for enter keystroke",() {

      testWidgets("Tests that handle_login was called when enter is clicked", (tester) async {

        when(() => mockAuthService.login(any(), any())).thenAnswer((_) async => AuthenticationResponses.success);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'test@example.com');
        await tester.enterText(find.byType(TextField).last, 'password123');

        await tester.pump();

        // Simulate pressing Enter
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle();

        expect(find.textContaining('Logging in as test@example.com'), findsOneWidget);

      });

    });
  });
}
