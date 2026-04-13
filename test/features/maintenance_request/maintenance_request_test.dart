import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/features/maintenance_request/maintenance_request.dart';
import 'package:clean_stream_laundry_app/features/maintenance_request/controller.dart';

class MockMaintenanceController extends Mock implements MaintenanceController {}

void main() {
  late MockMaintenanceController mockController;
  late TextEditingController descriptionController;

  setUp(() {
    mockController = MockMaintenanceController();
    descriptionController = TextEditingController();

    when(() => mockController.attemptedSubmit).thenReturn(false);
    when(() => mockController.categories).thenReturn(
        ['Washer/Dryer Maintenance', 'App Maintenance', 'Other']);
    when(() => mockController.selectedCategory).thenReturn(null);
    when(() => mockController.isLoading).thenReturn(false);
    when(() => mockController.isFormValid).thenReturn(false);
    when(() => mockController.selectedImage).thenReturn(null);
    when(() => mockController.descriptionController).thenReturn(descriptionController);

    when(() => mockController.addListener(any())).thenReturn(null);
    when(() => mockController.removeListener(any())).thenReturn(null);
    when(() => mockController.disposeController()).thenReturn(null);
    when(() => mockController.dispose()).thenReturn(null);
  });

  Widget createWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => MaintenancePage(controller: mockController),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, _) => const Scaffold(body: Text('Settings Page')),
          ),
        ],
      ),
    );
  }

  group('Maintenance Page Tests', () {
    testWidgets('renders all required UI elements', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Request Maintenance'), findsOneWidget);
      expect(find.text('Submit Maintenance Request'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('submit button shows grey background when form is invalid', (tester) async {
      when(() => mockController.isFormValid).thenReturn(false);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final color = button.style?.backgroundColor?.resolve({});
      expect(color, Colors.grey);
    });

    testWidgets('calls markAttemptedSubmit on button press with auto-scroll', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final submitButton = find.text('Submit Maintenance Request');

      await tester.dragUntilVisible(
        submitButton,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump();

      verify(() => mockController.markAttemptedSubmit()).called(1);
    });

    testWidgets('shows loading indicator when controller is loading', (tester) async {
      when(() => mockController.isLoading).thenReturn(true);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows success dialog on successful submission', (tester) async {
      when(() => mockController.isFormValid).thenReturn(true);
      when(() => mockController.submitMaintenance()).thenAnswer((_) async => true);
      when(() => mockController.markAttemptedSubmit()).thenReturn(null);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final submitButton = find.text('Submit Maintenance Request');

      await tester.dragUntilVisible(
        submitButton,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pump();
      await tester.pumpAndSettle();
      
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Your maintenance request has been submitted'), findsOneWidget);
    });
  });
}