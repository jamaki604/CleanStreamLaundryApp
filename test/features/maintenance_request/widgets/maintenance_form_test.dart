import 'dart:io';

import 'package:clean_stream_laundry_app/features/maintenance_request/widgets/maintenance_form.dart';
import 'package:clean_stream_laundry_app/features/maintenance_request/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMaintenanceController extends Mock implements MaintenanceController {}
class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockMaintenanceController controller;


  Widget buildForm() {
    return MaterialApp(
      home: Scaffold(
        body: MaintenanceForm(controller: controller),
      ),
    );
  }

  setUp(() {
    controller = MockMaintenanceController();

    when(() => controller.categories).thenReturn(['Electrical', 'Washer', 'Dryer']);
    when(() => controller.selectedCategory).thenReturn(null);
    when(() => controller.descriptionController)
        .thenReturn(TextEditingController());
    when(() => controller.selectedImage).thenReturn(null);
    when(() => controller.attemptedSubmit).thenReturn(false);
    when(() => controller.isFormValid).thenReturn(true);

    when(() => controller.selectCategory(any())).thenReturn(null);
    when(() => controller.pickImage(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  testWidgets('MaintenanceForm renders all fields', (tester) async {
    await tester.pumpWidget(buildForm());

    expect(find.text('Select a Category'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    expect(find.text('Reason for Maintenance'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    expect(find.text('Attach a Photo (Optional)'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('Dropdown shows categories from controller', (tester) async {
    await tester.pumpWidget(buildForm());

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Electrical'), findsOneWidget);
    expect(find.text('Washer'), findsOneWidget);
    expect(find.text('Dryer'), findsOneWidget);
  });

  testWidgets('Selecting a category triggers controller.selectCategory',
          (tester) async {
        await tester.pumpWidget(buildForm());

        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Washer').last);
        await tester.pumpAndSettle();

        verify(() => controller.selectCategory('Washer')).called(1);
      });

  testWidgets('Typing in description updates controller.descriptionController',
          (tester) async {
        final textController = TextEditingController();
        when(() => controller.descriptionController).thenReturn(textController);

        await tester.pumpWidget(buildForm());

        await tester.enterText(find.byType(TextField), 'Motor is making noise');
        expect(textController.text, 'Motor is making noise');
      });

  testWidgets('Shows placeholder when no image selected', (tester) async {
    when(() => controller.selectedImage).thenReturn(null);

    await tester.pumpWidget(buildForm());

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.text('Tap to take or upload a photo'), findsOneWidget);
  });

  testWidgets('Shows image preview when selectedImage is not null',
          (tester) async {
        final fakeImage = File('fake_path.jpg');
        when(() => controller.selectedImage).thenReturn(fakeImage);

        await tester.pumpWidget(buildForm());

        expect(find.byType(Image), findsOneWidget);
      });

  testWidgets('Shows error message when form invalid and attemptedSubmit',
          (tester) async {
        when(() => controller.attemptedSubmit).thenReturn(true);
        when(() => controller.isFormValid).thenReturn(false);

        await tester.pumpWidget(buildForm());

        expect(find.text('Please fill in all fields'), findsOneWidget);
      });

  testWidgets('Tapping image picker calls controller.pickImage',
          (tester) async {
        await tester.pumpWidget(buildForm());
        
        await tester.tap(find.text('Tap to take or upload a photo'));
        await tester.pump();

        verify(() => controller.pickImage(any())).called(1);
      });
}