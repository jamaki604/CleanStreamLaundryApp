import 'package:clean_stream_laundry_app/features/maintenance_request/widgets/location_selector.dart';
import 'package:clean_stream_laundry_app/features/maintenance_request/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMaintenanceController extends Mock implements MaintenanceController {}

void main() {
  late MockMaintenanceController mockController;

  setUp(() {
    mockController = MockMaintenanceController();
    when(() => mockController.locations).thenReturn(['123 Wash Ave', '456 Spin Ct']);
    when(() => mockController.selectedLocation).thenReturn(null);
    when(() => mockController.selectLocation(any())).thenReturn(null);
  });

  Widget createWidget() {
    return MaterialApp(
      home: Scaffold(
        body: LocationSelector(controller: mockController),
      ),
    );
  }

  testWidgets('displays placeholder text when no location is selected', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Select Location'), findsOneWidget);
  });

  testWidgets('displays the selected location name from the controller', (tester) async {
    when(() => mockController.selectedLocation).thenReturn('123 Wash Ave');

    await tester.pumpWidget(createWidget());

    expect(find.text('123 Wash Ave'), findsOneWidget);
    expect(find.text('Select Location'), findsNothing);
  });

  testWidgets('opens bottom sheet and shows options when tapped', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(find.text('No Applicable Location'), findsOneWidget);
    expect(find.text('123 Wash Ave'), findsOneWidget);
    expect(find.text('456 Spin Ct'), findsOneWidget);
  });

  testWidgets('calls selectLocation on controller and closes sheet when an item is tapped', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('456 Spin Ct'));
    await tester.pumpAndSettle();

    verify(() => mockController.selectLocation('456 Spin Ct')).called(1);
    expect(find.text('456 Spin Ct'), findsNothing);
  });

  testWidgets('selecting "No Applicable Location" sends correct string', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No Applicable Location'));
    await tester.pumpAndSettle();

    verify(() => mockController.selectLocation('No Applicable Location')).called(1);
  });
}