import 'package:clean_stream_laundry_app/logic/enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/logic/parsing/password_parser.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/pages/reset_protected_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

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
      initialLocation: '/reset-protected',
      routes: [
        GoRoute(
          path: '/reset-protected',
          builder: (context, state) =>
              ResetProtectedPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Page')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('validates short password', (tester) async {

    await tester.pumpWidget(
        createWidgetUnderTest()
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'short');
    await tester.enterText(find.byType(TextField).at(1), 'short');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    String? validations = PasswordParser.process("short");

    if (validations != null) {
      expect(find.text(validations), findsWidgets);
    }
  });

  testWidgets('submits new password and navigates to login', (tester) async {

    await tester.pumpWidget(
        createWidgetUnderTest()
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Password123&');
    await tester.enterText(find.byType(TextField).at(1), 'Password123&');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(() => mockAuthService.updatePassword('Password123&')).called(1);
    expect(find.text('Password reset successful'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Login Page'), findsOneWidget);
  });

  testWidgets('shows failure message when update fails', (tester) async {

    when(() => mockAuthService.updatePassword(any())).thenThrow(Exception('network'));

    await tester.pumpWidget(
        createWidgetUnderTest()
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Password123&');
    await tester.enterText(find.byType(TextField).at(1), 'Password123&');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.updatePassword('Password123&')).called(1);
    expect(find.text('Failed to reset password'), findsWidgets);
  });

  testWidgets('shows failure message when update throws', (tester) async {
    when(
      () => mockAuthService.exchangeCodeForSession('abc'),
    ).thenAnswer((_) async => AuthenticationResponses.success);
    when(
      () => mockAuthService.updatePassword(any()),
    ).thenThrow(Exception('network'));

    await tester.pumpWidget(
      createWidgetUnderTest()
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Password123&');
    await tester.enterText(find.byType(TextField).at(1), 'Password123&');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(() => mockAuthService.updatePassword('Password123&')).called(1);
    expect(find.text('Failed to reset password'), findsWidgets);
  });
}
