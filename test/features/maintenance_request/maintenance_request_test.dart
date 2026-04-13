import 'package:clean_stream_laundry_app/features/maintenance_request/maintenance_request.dart';
import 'package:clean_stream_laundry_app/features/maintenance_request/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockMaintenanceController extends Mock
    implements MaintenanceController {}

void main() {
  late MockMaintenanceController controller;

  setUp(() {
    controller = MockMaintenanceController();

    when(() => controller.isLoading).thenReturn(false);
    when(() => controller.isFormValid).thenReturn(false);
    when(() => controller.descriptionController)
        .thenReturn(TextEditingController());
    when(() => controller.addListener(any())).thenAnswer((_) {});
    when(() => controller.dispose()).thenAnswer((_) {});
    when(() => controller.disposeController()).thenAnswer((_) {});
  });

  Widget _wrap(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => child,
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const Scaffold(body: Text('Settings Page')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('Page renders correctly', (tester) async {
    await tester.pumpWidget(_wrap(MaintenancePage(controller: controller)));

    expect(find.text('Request Maintenance'), findsOneWidget);
    expect(find.text('Submit Maintenance Request'), findsOneWidget);
  });

  testWidgets('Submit button disabled when form invalid', (tester) async {
    when(() => controller.isFormValid).thenReturn(false);

    await tester.pumpWidget(_wrap(MaintenancePage(controller: controller)));

    final button = find.text('Submit Maintenance Request');
    final widget = tester.widget<ElevatedButton>(button);

    expect(widget.onPressed, isNull);
  });

  testWidgets('Submit triggers controller when form valid', (tester) async {
    when(() => controller.isFormValid).thenReturn(true);
    when(() => controller.submitMaintenance())
        .thenAnswer((_) async => true);

    await tester.pumpWidget(_wrap(MaintenancePage(controller: controller)));

    final button = find.text('Submit Maintenance Request');
    await tester.tap(button);
    await tester.pump();

    verify(() => controller.markAttemptedSubmit()).called(1);
    verify(() => controller.submitMaintenance()).called(1);
  });

  testWidgets('Submit button disabled when form invalid', (tester) async {
    when(() => controller.isFormValid).thenReturn(false);

    await tester.pumpWidget(_wrap(MaintenancePage()));

    final button = find.text('Submit Maintenance Request');
    final widget = tester.widget<ElevatedButton>(button);

    expect(widget.onPressed, isNull);
  });

  testWidgets('Submit triggers controller when form valid', (tester) async {
    when(() => controller.isFormValid).thenReturn(true);
    when(() => controller.submitMaintenance())
        .thenAnswer((_) async => true);

    await tester.pumpWidget(_wrap(MaintenancePage()));

    final button = find.text('Submit Maintenance Request');
    await tester.tap(button);
    await tester.pump();

    verify(() => controller.markAttemptedSubmit()).called(1);
    verify(() => controller.submitMaintenance()).called(1);
  });

  testWidgets('Success dialog appears and navigates to settings',
          (tester) async {
        when(() => controller.isFormValid).thenReturn(true);
        when(() => controller.submitMaintenance())
            .thenAnswer((_) async => true);

        await tester.pumpWidget(_wrap(MaintenancePage()));

        // Tap submit
        await tester.tap(find.text('Submit Maintenance Request'));
        await tester.pumpAndSettle();

        // Dialog should appear
        expect(find.text('Success'), findsOneWidget);
        expect(find.text('Your maintenance request has been submitted'),
            findsOneWidget);

        // Close dialog
        await tester.tap(find.text('OK')); // assuming your dialog uses OK button
        await tester.pumpAndSettle();

        // Should navigate to /settings
        expect(find.text('Settings Page'), findsOneWidget);
      });
}