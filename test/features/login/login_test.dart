import 'package:clean_stream_laundry_app/features/login/login.dart';
import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
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

  setUp(() async {
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();
    fakeAppLinks = FakeAppLinks();

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);
  });

  tearDown(() async {
    fakeAppLinks.dispose();
    await GetIt.instance.reset();
  });

  Widget createWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => Login(appLinks: fakeAppLinks),
          ),
          GoRoute(
            path: '/homePage',
            builder: (_, __) => const Scaffold(body: Text('Home Page')),
          ),
          GoRoute(
            path: '/email-verification',
            builder: (_, __) => const Scaffold(body: Text('Verify your email')),
          ),
          GoRoute(
            path: '/signup',
            builder: (_, __) => const Scaffold(body: Text('Sign Up Page')),
          ),
          GoRoute(
            path: '/password-reset',
            builder: (_, __) =>
                const Scaffold(body: Text('Password Reset Page')),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const Scaffold(body: Text('Login Page')),
          ),
        ],
      ),
    );
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

  group('Static UI', () {
    testWidgets('displays logo image with correct dimensions', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byKey(const Key('app_logo')));
      expect(image.height, 250);
      expect(image.width, 250);
    });

    testWidgets('displays email and password text fields', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    });

    testWidgets('displays email and lock icons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('displays Log In button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
    });

    testWidgets('displays Sign in with Google button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Sign in with Google'),
        findsOneWidget,
      );
    });

    testWidgets('displays Sign in with Apple button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Sign in with Apple'),
        findsOneWidget,
      );
    });

    testWidgets('displays Create Account link', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('displays Reset Password link', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Password'),
      );
      expect(field.obscureText, isTrue);
    });

    testWidgets('page is scrollable', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('Login functionality', () {
    testWidgets('shows error snackbar when both fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      expect(find.text('Please fill in both fields.'), findsOneWidget);
    });

    testWidgets('shows error snackbar when email is empty', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      expect(find.text('Please fill in both fields.'), findsOneWidget);
    });

    testWidgets('shows error snackbar when password is empty', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      expect(find.text('Please fill in both fields.'), findsOneWidget);
    });

    testWidgets('shows logging in snackbar when credentials entered', (
      tester,
    ) async {
      mockLoginResponse(AuthenticationResponses.success);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await enterCredentials(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      expect(find.text('Logging in as test@example.com...'), findsOneWidget);
    });

    testWidgets('navigates to home page on successful login', (tester) async {
      mockLoginResponse(AuthenticationResponses.success);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await enterCredentials(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
      verify(
        () => mockAuthService.login('test@example.com', 'password123'),
      ).called(1);
    });

    testWidgets('navigates to email verification on unverified email', (
      tester,
    ) async {
      mockLoginResponse(AuthenticationResponses.emailNotVerified);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await enterCredentials(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Verify your email'), findsOneWidget);
    });

    testWidgets('shows error colors on failed login', (tester) async {
      mockLoginResponse(AuthenticationResponses.failure);

      await tester.pumpWidget(createWidget());
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

    testWidgets('trims email whitespace before calling login', (tester) async {
      mockLoginResponse(AuthenticationResponses.success);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await enterCredentials(tester, email: '  test@example.com  ');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.login('test@example.com', any())).called(1);
    });

    testWidgets('error colors persist after subsequent input', (tester) async {
      mockLoginResponse(AuthenticationResponses.failure);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await enterCredentials(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Invalid Password or Email').first,
        'new@example.com',
      );
      await tester.pump();

      final emailIcon = tester.widget<Icon>(find.byIcon(Icons.email));
      expect(emailIcon.color, Colors.red);
    });
  });

  group('Password visibility', () {
    testWidgets('toggles password visibility when suffix icon tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Password'))
            .obscureText,
        isTrue,
      );

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Password'))
            .obscureText,
        isFalse,
      );
    });

    testWidgets('shows visibility icon when password is hidden', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('shows visibility_off icon when password is shown', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });
  });

  group('Navigation', () {
    testWidgets('navigates to sign_up on Create Account tap', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up Page'), findsOneWidget);
    });

    testWidgets('navigates to password reset on Reset Password tap', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Reset Password'));
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Password Reset Page'), findsOneWidget);
    });
  });

  group('Keyboard enter', () {
    testWidgets('pressing Enter triggers login', (tester) async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenAnswer((_) async => AuthenticationResponses.success);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Logging in as test@example.com'),
        findsOneWidget,
      );
    });
  });

  group('Deep links', () {
    testWidgets('navigates to home on email-verification deep link', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://email-verification'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('handles oauth deep link with successful session', (
      tester,
    ) async {
      when(
        () => mockAuthService.getSessionFromURI(any()),
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

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://oauth'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
      verify(() => mockAuthService.getSessionFromURI(any())).called(1);
      verify(() => mockAuthService.isLoggedIn()).called(1);
      verify(() => mockAuthService.getCurrentUser()).called(1);
      verify(
        () => mockProfileService.createAccount(id: 'testId', name: 'Test User'),
      ).called(1);
    });

    testWidgets('navigates to login on oauth deep link with failed session', (
      tester,
    ) async {
      when(
        () => mockAuthService.getSessionFromURI(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockAuthService.isLoggedIn(),
      ).thenAnswer((_) async => AuthenticationResponses.failure);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      fakeAppLinks.emit(Uri.parse('clean-stream://oauth'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('ignores deep link with null uri', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    });
  });

  group('Styling', () {
    testWidgets('Log In button has blue background and white text', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Log In'),
      );
      expect(button.style?.backgroundColor?.resolve({}), Colors.blue);
      expect(button.style?.foregroundColor?.resolve({}), Colors.white);
    });

    testWidgets('Create Account text is blue and underlined', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Create Account'));
      expect(text.style?.color, Colors.blue);
      expect(text.style?.decoration, TextDecoration.underline);
    });

    testWidgets('email field has rounded border', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Email'),
      );
      final border =
          (field.decoration as InputDecoration).border as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(12));
    });
  });
}
