import 'dart:async';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/features/edit_profile/controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  late MockAuthService authService;
  late MockProfileService profileService;
  late MockEdgeFunctionService edgeFunctionService;
  late StreamController<bool> authController;
  late EditProfileController controller;

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

    controller = EditProfileController();
  });

  tearDown(() async {
    await authController.close();
    controller.disposeController();
    GetIt.instance.reset();
  });

  group('loadUserData', () {
    test('populates currentName and currentEmail from services', () async {
      await controller.init();

      expect(controller.currentName, 'John Doe');
      expect(controller.currentEmail, 'test@example.com');
    });

    test('sets controller text fields after loading', () async {
      await controller.init();

      expect(controller.nameController.text, 'John Doe');
      expect(controller.emailController.text, 'test@example.com');
    });

    test('sets isLoading to false after data loads', () async {
      expect(controller.isLoading, isTrue);

      await controller.init();

      expect(controller.isLoading, isFalse);
    });

    test('sets isLoading to false even when service throws', () async {
      when(() => profileService.getUserNameById(any()))
          .thenThrow(Exception('Network error'));

      await expectLater(controller.init(), throwsException);

      expect(controller.isLoading, isFalse);
    });

    test('reloads data when auth state changes', () async {
      await controller.init();

      when(() => profileService.getUserNameById('user-id'))
          .thenAnswer((_) async => 'Jane Doe');

      authController.add(true);
      await Future.delayed(Duration.zero);

      expect(controller.currentName, 'Jane Doe');
    });
  });

  group('hasChanges', () {
    setUp(() async {
      await controller.init();
    });

    test('returns false when nothing has changed', () {
      expect(controller.hasChanges, isFalse);
    });

    test('returns true when name differs from currentName', () {
      controller.nameController.text = 'New Name';

      expect(controller.hasChanges, isTrue);
    });

    test('returns true when email differs from currentEmail', () {
      controller.emailController.text = 'new@example.com';

      expect(controller.hasChanges, isTrue);
    });

    test('returns false when text matches after trimming', () {
      controller.nameController.text = controller.currentName;
      controller.emailController.text = controller.currentEmail;

      expect(controller.hasChanges, isFalse);
    });

    test('returns true when only whitespace differs', () {
      controller.nameController.text = '  ${controller.currentName}  ';

      expect(controller.hasChanges, isFalse);
    });
  });


  group('saveChanges', () {
    setUp(() async {
      await controller.init();
      when(() => authService.updateUserAttributes(
        email: any(named: 'email'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});
    });

    test('throws when no fields have changed', () async {
      await expectLater(controller.saveChanges(), throwsException);

      verifyNever(() => authService.updateUserAttributes(
        email: any(named: 'email'),
        data: any(named: 'data'),
      ));
    });

    test('sends only name when only name changed', () async {
      controller.nameController.text = 'Jane Smith';

      await controller.saveChanges();

      verify(() => authService.updateUserAttributes(
        email: null,
        data: {'full_name': 'Jane Smith'},
      )).called(1);
    });

    test('sends only email when only email changed', () async {
      controller.emailController.text = 'new@example.com';

      await controller.saveChanges();

      verify(() => authService.updateUserAttributes(
        email: 'new@example.com',
        data: null,
      )).called(1);
    });

    test('sends both name and email when both changed', () async {
      controller.nameController.text = 'Jane Smith';
      controller.emailController.text = 'jane@example.com';

      await controller.saveChanges();

      verify(() => authService.updateUserAttributes(
        email: 'jane@example.com',
        data: {'full_name': 'Jane Smith'},
      )).called(1);
    });

    test('trims whitespace from name and email before saving', () async {
      controller.nameController.text = '  Jane  ';
      controller.emailController.text = '  jane@email.com  ';

      await controller.saveChanges();

      verify(() => authService.updateUserAttributes(
        email: 'jane@email.com',
        data: {'full_name': 'Jane'},
      )).called(1);
    });

    test('returns true when email changed', () async {
      controller.emailController.text = 'new@example.com';

      final result = await controller.saveChanges();

      expect(result, isTrue);
    });

    test('returns false when only name changed', () async {
      controller.nameController.text = 'Jane Smith';

      final result = await controller.saveChanges();

      expect(result, isFalse);
    });

    test('updates currentName after successful save', () async {
      controller.nameController.text = 'Jane Smith';

      await controller.saveChanges();

      expect(controller.currentName, 'Jane Smith');
    });

    test('sets and clears isSaving around the service call', () async {
      final completer = Completer<void>();
      when(() => authService.updateUserAttributes(
        email: any(named: 'email'),
        data: any(named: 'data'),
      )).thenAnswer((_) => completer.future);

      controller.nameController.text = 'Jane Smith';

      final future = controller.saveChanges();

      expect(controller.isSaving, isTrue);

      completer.complete();
      await future;

      expect(controller.isSaving, isFalse);
    });

    test('clears isSaving even when service throws', () async {
      when(() => authService.updateUserAttributes(
        email: any(named: 'email'),
        data: any(named: 'data'),
      )).thenThrow(Exception('Save failed'));

      controller.nameController.text = 'Jane Smith';

      await expectLater(controller.saveChanges(), throwsException);

      expect(controller.isSaving, isFalse);
    });

    test('does nothing when called while already saving', () async {
      final completer = Completer<void>();
      when(() => authService.updateUserAttributes(
        email: any(named: 'email'),
        data: any(named: 'data'),
      )).thenAnswer((_) => completer.future);

      controller.nameController.text = 'Jane Smith';

      final firstCall = controller.saveChanges();
      final secondResult = await controller.saveChanges();

      expect(secondResult, isFalse);

      completer.complete();
      await firstCall;

      verify(() => authService.updateUserAttributes(
        email: any(named: 'email'),
        data: any(named: 'data'),
      )).called(1);
    });
  });

  group('deleteAccount', () {
    setUp(() async {
      await controller.init();
      when(() => authService.logout()).thenAnswer((_) async {});
    });

    test('calls edge function with correct arguments', () async {
      when(() => edgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer(
              (_) async => FunctionResponse(data: null, status: 200));

      await controller.deleteAccount();

      verify(() => edgeFunctionService.runEdgeFunction(
        name: 'delete-account',
        body: {'user_id': 'user-id'},
      )).called(1);
    });

    test('calls logout and returns true on 200 response', () async {
      when(() => edgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer(
              (_) async => FunctionResponse(data: null, status: 200));

      final result = await controller.deleteAccount();

      verify(() => authService.logout()).called(1);
      expect(result, isTrue);
    });

    test('does not logout and returns false on non-200 response', () async {
      when(() => edgeFunctionService.runEdgeFunction(
        name: any(named: 'name'),
        body: any(named: 'body'),
      )).thenAnswer(
              (_) async => FunctionResponse(data: null, status: 500));

      final result = await controller.deleteAccount();

      verifyNever(() => authService.logout());
      expect(result, isFalse);
    });
  });
}