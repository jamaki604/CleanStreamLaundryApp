import 'dart:io';

import 'package:clean_stream_laundry_app/features/maintenance_request/controller.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}
class MockProfileService extends Mock implements ProfileService {}
class MockEdgeFunctionService extends Mock implements EdgeFunctionService {}

void main() {
  late MaintenanceController controller;
  late MockAuthService auth;
  late MockProfileService profile;
  late MockEdgeFunctionService edge;

  setUp(() {
    auth = MockAuthService();
    profile = MockProfileService();
    edge = MockEdgeFunctionService();

    controller = MaintenanceController(
      authService: auth,
      profileService: profile,
      edgeFunctionService: edge,
    );
  });

  group('MaintenanceController Tests', () {
    test('Initial state is correct', () {
      expect(controller.selectedCategory, isNull);
      expect(controller.selectedImage, isNull);
      expect(controller.isLoading, false);
      expect(controller.isFormValid, false);
    });

    test('Selecting a category updates state', () {
      controller.selectCategory('App Maintenance');
      expect(controller.selectedCategory, 'App Maintenance');
      expect(controller.isFormValid, false);
    });

    test('Form becomes valid when category + description are set', () {
      controller.selectCategory('Other');
      controller.descriptionController.text = 'Something is broken';

      expect(controller.isFormValid, true);
    });

    test('submitMaintenance returns false when userId is null', () async {
      when(() => auth.getCurrentUserId).thenReturn(null);

      final result = await controller.submitMaintenance();
      expect(result, false);
    });

    test('submitMaintenance calls edge function with correct payload', () async {
      when(() => auth.getCurrentUserId).thenReturn('user123');
      when(() => profile.getUserNameById('user123'))
          .thenAnswer((_) async => 'John Doe');

      when(() => edge.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => null);

      controller.selectCategory('Washer/Dryer Maintenance');
      controller.descriptionController.text = 'Machine leaking';

      final result = await controller.submitMaintenance();

      expect(result, true);

      verify(() => edge.runEdgeFunction(
        name: 'maintenance-request',
        body: {
          'username': 'John Doe',
          'user_id': 'user123',
          'category': 'Washer/Dryer Maintenance',
          'description': 'Machine leaking',
          'has_image': false,
        },
      )).called(1);
    });

    test('Image selection updates selectedImage', () {
      // Simulate a picked file
      final fakeFile = File('test_assets/fake_image.jpg');
      controller.selectedImage = fakeFile;

      expect(controller.selectedImage!.path, contains('fake_image.jpg'));
    });
  });
}