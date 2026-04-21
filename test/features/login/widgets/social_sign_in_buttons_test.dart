import 'package:clean_stream_laundry_app/features/login/controller.dart';
import 'package:clean_stream_laundry_app/features/login/widgets/social_sign_in_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../mocks.dart';

class MockLoginController extends Mock implements LoginController {}

void main() {
  late MockAuthService mockAuthService;
  late MockLoginController mockController;

  setUp(() {
    mockAuthService = MockAuthService();
    mockController = MockLoginController();

    when(() => mockController.authService).thenReturn(mockAuthService);

    // Stub async methods
    when(() => mockAuthService.googleSignIn())
        .thenAnswer((_) async {});
    when(() => mockAuthService.appleSignIn())
        .thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: SocialSignInButtons(controller: mockController),
      ),
    );
  }

  testWidgets('renders both social sign-in buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Sign in with Google'), findsOneWidget);
        expect(find.text('Sign in with Apple'), findsOneWidget);
      });

  testWidgets('tapping Google button calls googleSignIn',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Sign in with Google'));
        await tester.pump();

        verify(() => mockAuthService.googleSignIn()).called(1);
      });

  testWidgets('tapping Apple button calls appleSignIn',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.text('Sign in with Apple'));
        await tester.pump();

        verify(() => mockAuthService.appleSignIn()).called(1);
      });

  testWidgets('google logo is displayed',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byKey(const Key('google_logo')), findsOneWidget);
      });
}