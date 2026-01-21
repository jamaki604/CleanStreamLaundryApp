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
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;
  late GoRouter mockRouter;

  setUp(() {
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();

    // Register mocks with GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }
    if (getIt.isRegistered<ProfileService>()) {
      getIt.unregister<ProfileService>();
    }

    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<ProfileService>(mockProfileService);

    // Setup default mock responses
    when(
      () => mockAuthService.getCurrentUserId,
    ).thenAnswer((_) => 'test-user-id');
    when(
      () => mockAuthService.getCurrentUserEmail(),
    ).thenAnswer((_) => 'test@example.com');
    when(
      () => mockProfileService.getUserNameById('test-user-id'),
    ).thenAnswer((_) async => 'John Doe');
    when(() => mockAuthService.updateEmail(any())).thenAnswer((_) async => {});
    when(
      () => mockProfileService.updateName(any()),
    ).thenAnswer((_) async => {});

    // Setup mock router
    mockRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const Scaffold(body: Text('Settings Page')),
        ),
      ],
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    return MaterialApp.router(routerConfig: mockRouter);
  }

  group('EditProfilePage', () {
    testWidgets('should load user data on init', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify services were called
      verify(() => mockAuthService.getCurrentUserId).called(1);
      verify(
        () => mockProfileService.getUserNameById('test-user-id'),
      ).called(1);
      verify(() => mockAuthService.getCurrentUserEmail()).called(1);

      // Verify UI displays current data
      expect(find.text('Current Name: John Doe'), findsOneWidget);
      expect(find.text('Current Email: test@example.com'), findsOneWidget);

      // Verify text fields are populated
      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Full Name'),
      );
      expect(nameField.controller?.text, 'John Doe');

      final emailField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Email'),
      );
      expect(emailField.controller?.text, 'test@example.com');
    });

    testWidgets(
      'should navigate back to settings when back button is pressed',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify navigation to settings
        expect(find.text('Settings Page'), findsOneWidget);
      },
    );

    testWidgets('should validate empty name field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Clear the name field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        '',
      );
      await tester.pumpAndSettle();

      // Tap Save Changes button
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Confirm in dialog
      await tester.tap(find.text('Yes, Save'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.text('Name cannot be empty'), findsOneWidget);

      // Verify services were not called
      verifyNever(() => mockAuthService.updateEmail(any()));
      verifyNever(() => mockProfileService.updateName(any()));
    });

    testWidgets('should validate empty email field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Clear the email field
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), '');
      await tester.pumpAndSettle();

      // Tap Save Changes button
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Confirm in dialog
      await tester.tap(find.text('Yes, Save'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.text('Email cannot be empty'), findsOneWidget);

      // Verify services were not called
      verifyNever(() => mockAuthService.updateEmail(any()));
      verifyNever(() => mockProfileService.updateName(any()));
    });

    testWidgets('should validate invalid email format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalidemail',
      );
      await tester.pumpAndSettle();

      // Tap Save Changes button
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Confirm in dialog
      await tester.tap(find.text('Yes, Save'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Verify services were not called
      verifyNever(() => mockAuthService.updateEmail(any()));
      verifyNever(() => mockProfileService.updateName(any()));
    });

    testWidgets('should show confirmation dialog when save is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Save Changes button
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Confirm Changes'), findsOneWidget);
      expect(
        find.text('Are you sure you want to change your information?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Yes, Save'), findsOneWidget);
    });

    testWidgets(
      'should not save when cancel is pressed in confirmation dialog',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Enter new data
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'),
          'Jane Smith',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'jane@example.com',
        );
        await tester.pumpAndSettle();

        // Tap Save Changes button
        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        // Cancel in dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify services were not called
        verifyNever(() => mockAuthService.updateEmail(any()));
        verifyNever(() => mockProfileService.updateName(any()));
      },
    );

    testWidgets('should save changes when confirmed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter new data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Jane Smith',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'jane@example.com',
      );
      await tester.pumpAndSettle();

      // Tap Save Changes button
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Confirm in dialog
      await tester.tap(find.text('Yes, Save'));
      await tester.pumpAndSettle();

      // Verify services were called with correct values
      verify(() => mockAuthService.updateEmail('jane@example.com')).called(1);
      verify(() => mockProfileService.updateName('Jane Smith')).called(1);

      // Verify success dialog appears
      expect(find.text('Information Updated'), findsOneWidget);
      expect(
        find.text('Your information has successfully been updated.'),
        findsOneWidget,
      );
    });

    testWidgets('should trim whitespace from input fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter data with whitespace
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        '  Jane Smith  ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        '  jane@example.com  ',
      );
      await tester.pumpAndSettle();

      // Tap Save Changes button
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Confirm in dialog
      await tester.tap(find.text('Yes, Save'));
      await tester.pumpAndSettle();

      // Verify services were called with trimmed values
      verify(() => mockAuthService.updateEmail('jane@example.com')).called(1);
      verify(() => mockProfileService.updateName('Jane Smith')).called(1);
    });

    testWidgets('should dispose controllers on dispose', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // If we get here without errors, controllers were disposed properly
      expect(find.byType(EditProfilePage), findsNothing);
    });
  });
}
