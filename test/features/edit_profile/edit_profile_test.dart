import 'dart:async';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/features/edit_profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  late MockAuthService authService;
  late MockProfileService profileService;
  late MockEdgeFunctionService edgeFunctionService;
  late StreamController<bool> authController;

  setUp(() {
    authService = MockAuthService();
    profileService = MockProfileService();
    edgeFunctionService = MockEdgeFunctionService();
    authController = StreamController<bool>.broadcast();

    GetIt.instance.reset();
    GetIt.instance.registerSingleton<AuthService>(authService);
    GetIt.instance.registerSingleton<ProfileService>(profileService);
    GetIt.instance.registerSingleton<EdgeFunctionService>(edgeFunctionService);

    when(() => authService.onAuthChange)
        .thenAnswer((_) => authController.stream);
    when(() => authService.getCurrentUserId).thenAnswer((_) => 'user-id');
    when(() => authService.getCurrentUserEmail())
        .thenAnswer((_) => 'test@example.com');
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
          GoRoute(path: '/', builder: (_, __) => const EditProfilePage()),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const Scaffold(body: Text('Settings')),
          ),
          GoRoute(
            path: '/change-email-verification',
            builder: (_, __) => const Scaffold(body: Text('Verify Email')),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const Scaffold(body: Text('Login')),
          ),
        ],
      ),
    );
  }

  group('Static UI', () {
    testWidgets('displays page title', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('loads and displays user data in info cards', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Current'), findsNWidgets(2));
      expect(find.text('John Doe'), findsNWidgets(2));
      expect(find.text('test@example.com'), findsNWidgets(2));
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('input fields have proper hint text', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Enter your full name'), findsOneWidget);
      expect(find.text('Enter your email address'), findsOneWidget);
    });

    testWidgets('displays danger zone section with delete account button',
            (tester) async {
          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          expect(find.text('Danger Zone'), findsOneWidget);
          expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
          expect(find.text('Delete Account'), findsOneWidget);
          expect(find.byIcon(Icons.delete_outline), findsOneWidget);
        });

    testWidgets('page is scrollable', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('Loading state', () {
    testWidgets('displays loading indicator while fetching data',
            (tester) async {
          final completer = Completer<String>();
          when(() => profileService.getUserNameById('user-id'))
              .thenAnswer((_) => completer.future);

          await tester.pumpWidget(createWidget());
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          completer.complete('John Doe');
          await tester.pumpAndSettle();

          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text('John Doe'), findsNWidgets(2));
        });

    testWidgets('shows error dialog when init fails', (tester) async {
      when(() => profileService.getUserNameById(any()))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining('Failed to load profile data'), findsOneWidget);
    });

    testWidgets('error dialog dismisses on OK tap', (tester) async {
      when(() => profileService.getUserNameById(any()))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsNothing);
    });
  });

  group('Navigation', () {
    testWidgets('back button navigates to settings', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('navigates to verification page when email changes',
            (tester) async {
          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextFormField, 'New Email'),
            'new@email.com',
          );
          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          verify(() => authService.updateUserAttributes(
            email: 'new@email.com',
            data: null,
          )).called(1);

          expect(find.text('Verify Email'), findsOneWidget);
        });
  });

  group('Confirmation dialog', () {
    testWidgets('shows confirmation dialog before saving changes',
            (tester) async {
          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextFormField, 'New Full Name'),
            'New Name',
          );
          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();

          expect(find.text('Confirm Changes'), findsOneWidget);
          expect(
            find.text(
                'Are you sure you want to save these changes to your profile?'),
            findsOneWidget,
          );
          expect(find.text('Cancel'), findsOneWidget);
          expect(find.text('Save'), findsOneWidget);
        });

    testWidgets('shows No Changes dialog when nothing was edited',
            (tester) async {
          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();

          expect(find.text('No Changes'), findsOneWidget);
          expect(find.text("You haven't changed anything."), findsOneWidget);

          verifyNever(() => authService.updateUserAttributes(
            email: any(named: 'email'),
            data: any(named: 'data'),
          ));
        });

    testWidgets('cancels save when user taps Cancel in confirmation',
            (tester) async {
          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextFormField, 'New Full Name'),
            'New Name',
          );
          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();

          verifyNever(() => authService.updateUserAttributes(
            email: any(named: 'email'),
            data: any(named: 'data'),
          ));
        });
  });


  group('Form validation', () {
    testWidgets('validates empty name', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Full Name'),
        '',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Name cannot be empty'), findsOneWidget);
    });

    testWidgets('validates invalid email', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Email'),
        'invalid-email',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates empty email', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Email'),
        '   ',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Email cannot be empty'), findsOneWidget);
    });

    testWidgets('enforces name character limit', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Full Name'),
        'This is a very long name that exceeds the limit',
      );
      await tester.pump();

      final textField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'New Full Name'),
      );
      expect(textField.controller!.text.length, lessThanOrEqualTo(36));
    });

    testWidgets('name field only allows alphanumeric and spaces', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Full Name'),
        'Test@#\$%',
      );
      await tester.pump();

      final textField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'New Full Name'),
      );
      expect(textField.controller!.text, 'Test');
    });
  });

  group('Save behavior', () {
    testWidgets('updates name and shows success message', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Full Name'),
        'Jane Smith',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => authService.updateUserAttributes(
        email: null,
        data: {'full_name': 'Jane Smith'},
      )).called(1);

      expect(find.text('Profile Updated'), findsOneWidget);
    });

    testWidgets('trims whitespace before saving', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Full Name'),
        '  Jane  ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Email'),
        '  jane@email.com  ',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => authService.updateUserAttributes(
        email: 'jane@email.com',
        data: {'full_name': 'Jane'},
      )).called(1);
    });

    testWidgets('disables save button while saving', (tester) async {
      final completer = Completer<void>();
      when(() => authService.updateUserAttributes(
        email: any(named: 'email'),
        data: any(named: 'data'),
      )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Full Name'),
        'New Name',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();

      final saveButton = tester.widget<ElevatedButton>(
        find
            .ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(ElevatedButton),
        )
            .first,
      );
      expect(saveButton.onPressed, isNull);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows Update Failed dialog when saveChanges throws',
            (tester) async {
          when(() => authService.updateUserAttributes(
            email: any(named: 'email'),
            data: any(named: 'data'),
          )).thenThrow(Exception('Server error'));

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextFormField, 'New Full Name'),
            'Jane Smith',
          );
          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          expect(find.text('Update Failed'), findsOneWidget);
        });
  });


  group('Delete account', () {
    Future<void> openDeleteDialog(WidgetTester tester) async {
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
    }

    testWidgets('shows delete account confirmation dialog', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      await openDeleteDialog(tester);

      expect(find.text('Delete Account?'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete your account? '
              'Any money on your loyalty card will be lost. '
              'This action cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('cancels delete when user taps Cancel', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      await openDeleteDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => edgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      ));
    });

    testWidgets('navigates to login after successful delete', (tester) async {
      when(() => authService.logout()).thenAnswer((_) async {});
      when(() => edgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer(
              (_) async => FunctionResponse(data: null, status: 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      await openDeleteDialog(tester);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows error dialog when delete returns non-200',
            (tester) async {
          when(() => edgeFunctionService.runEdgeFunction(
            name: any(named: 'name'),
            body: any(named: 'body'),
          )).thenAnswer(
                  (_) async => FunctionResponse(data: null, status: 500));

          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();
          await openDeleteDialog(tester);

          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          expect(find.text('Error'), findsOneWidget);
          expect(
            find.text('An error occurred, please try again later.'),
            findsOneWidget,
          );
        });

    testWidgets('shows error dialog when deleteAccount throws', (tester) async {
      when(() => edgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenThrow(Exception('Network failure'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();
      await openDeleteDialog(tester);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
    });
  });
}