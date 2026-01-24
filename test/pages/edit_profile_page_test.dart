import 'dart:async';
import 'package:clean_stream_laundry_app/pages/edit_profile_page.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late MockAuthService authService;
  late MockProfileService profileService;
  late StreamController<bool> authController;

  setUp(() {
    authService = MockAuthService();
    profileService = MockProfileService();
    authController = StreamController<bool>.broadcast();

    final getIt = GetIt.instance;
    getIt.reset();

    getIt.registerSingleton<AuthService>(authService);
    getIt.registerSingleton<ProfileService>(profileService);

    when(() => authService.onAuthChange)
        .thenAnswer((_) => authController.stream);

    when(() => authService.getCurrentUserId)
        .thenAnswer((_)  => 'user-id');

    when(() => authService.getCurrentUserEmail())
        .thenAnswer((_)  => 'test@example.com');

    when(() => profileService.getUserNameById('user-id'))
        .thenAnswer((_) async => 'John Doe');

    when(() => authService.updateUserAttributes(
      email: any(named: 'email'),
      data: any(named: 'data'),
    )).thenAnswer((_) async {});
  });

  tearDown(() async {
    await authController.close();
    GetIt.instance.reset();
  });

  Widget createWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const EditProfilePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const Scaffold(body: Text('Settings')),
          ),
          GoRoute(
            path: '/change-email-verification',
            builder: (_, __) =>
            const Scaffold(body: Text('Verify Email')),
          ),
        ],
      ),
    );
  }

  testWidgets('loads and displays user data', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Current Name: John Doe'), findsOneWidget);
    expect(find.text('Current Email: test@example.com'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('shows No Changes dialog if nothing changed', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('No Changes'), findsOneWidget);
    expect(find.text('You haven’t changed anything.'), findsOneWidget);

    verifyNever(() => authService.updateUserAttributes(
      email: any(named: 'email'),
      data: any(named: 'data'),
    ));
  });

  testWidgets('validates empty name', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), '');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes, Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name cannot be empty'), findsOneWidget);
  });

  testWidgets('updates name only', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Jane Smith');

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, Save'));
    await tester.pumpAndSettle();

    verify(() => authService.updateUserAttributes(
      email: null,
      data: {'full_name': 'Jane Smith'},
    )).called(1);

    expect(find.text('Profile Updated'), findsOneWidget);
  });

  testWidgets('navigates to verification when email changes', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'new@email.com');

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, Save'));
    await tester.pumpAndSettle();

    verify(() => authService.updateUserAttributes(
      email: 'new@email.com',
      data: null,
    )).called(1);

    expect(find.text('Verify Email'), findsOneWidget);
  });

  testWidgets('trims whitespace before saving', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), '  Jane  ');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), '  jane@email.com  ');

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, Save'));
    await tester.pumpAndSettle();

    verify(() => authService.updateUserAttributes(
      email: 'jane@email.com',
      data: {'full_name': 'Jane'},
    )).called(1);
  });

  testWidgets('back button navigates to settings', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });
}
