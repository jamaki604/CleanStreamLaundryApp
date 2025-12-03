import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/services/nayax/machine_communicator.dart';
import 'package:clean_stream_laundry_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  late MachineCommunicator machineCommunicator;
  late EdgeFunctionMock edgeFunctionMock;

  group("Awake machine Tests", () {
    setUp(() {
      getIt.reset();
      edgeFunctionMock = EdgeFunctionMock();

      getIt.registerLazySingleton<EdgeFunctionService>(
              () => edgeFunctionMock);

      machineCommunicator = MachineCommunicator();
    });

    test("machine successfully wakes up", () async {
      when(() =>
          edgeFunctionMock.runEdgeFunction(
              name: any(named: 'name'), body: any(named: 'body'))).thenAnswer((
          _) async =>
          FunctionResponse(status: 200,
              data: {
                "success": true,
                "deviceId": 5,
                "error": "Device reachable",
                "responseTime": "84ms"
              }));

      final result = await machineCommunicator.wakeDevice('123');
      expect(result, true);
    });

    test("machine fails to wake up", () async {
      when(() =>
          edgeFunctionMock.runEdgeFunction(
              name: any(named: 'name'), body: any(named: 'body'))).thenAnswer((
          _) async =>
          FunctionResponse(status: 503,
              data: {
                "success": false,
                "deviceId": 5,
                "error": "Device unreachable",
                "responseTime": "84ms"
              }));

      final result = await machineCommunicator.wakeDevice('123');
      expect(result, false);
    });

    test("Tests if there is an unexpected error", () async {
      when(() =>
          edgeFunctionMock.runEdgeFunction(
              name: any(named: 'name'), body: any(named: 'body'))).thenThrow(
          Exception("Test error"));

      final result = await machineCommunicator.wakeDevice('123');
      expect(result, false);
    });
  });


  group("Check Availability Tests", () {
    setUp(() {
      getIt.reset();
      edgeFunctionMock = EdgeFunctionMock();

      getIt.registerLazySingleton<EdgeFunctionService>(
              () => edgeFunctionMock);

      machineCommunicator = MachineCommunicator();
    });

    test('Check idle availability', () async {
      when(() =>
          edgeFunctionMock.runEdgeFunction(
              name: any(named: 'name'),
              body: any(named: 'body'))).thenAnswer((_) async =>
          FunctionResponse(
              status: 200,
              data: {
                "success": true,
                "deviceId": 10000000,
                "message": "idle",
                "responseTime": "84ms"
              }));

      final result = await machineCommunicator.checkAvailability('10000000');
      expect(result, equals('pass'));
    });

    test('Check in-use availability', () async {
      when(() =>
          edgeFunctionMock.runEdgeFunction(
              name: any(named: 'name'),
              body: any(named: 'body'))).thenAnswer((_) async =>
          FunctionResponse(
              status: 200,
              data: {
                "success": true,
                "deviceId": 10000001,
                "message": "in-use",
                "responseTime": "01ms"
              }));

      final result = await machineCommunicator.checkAvailability('10000001');
      expect(result, equals('Machine is in use right now.'));
    });

    test('Check offline availability', () async {
      when(() =>
          edgeFunctionMock.runEdgeFunction(
              name: any(named: 'name'),
              body: any(named: 'body'))).thenAnswer((_) async =>
          FunctionResponse(
              status: 200,
              data: {
                "success": true,
                "deviceId": 10000002,
                "message": "offline",
                "responseTime": "20ms"
              }));

      final result = await machineCommunicator.checkAvailability('10000002');
      expect(result, equals('Machine is offline right now.'));
    });

    test('Check nonsense message', () async {
      when(() =>
          edgeFunctionMock.runEdgeFunction(
              name: any(named: 'name'),
              body: any(named: 'body'))).thenAnswer((_) async =>
          FunctionResponse(
              status: 200,
              data: {
                "success": true,
                "deviceId": 10000002,
                "message": "nonsensical prompt",
                "responseTime": "2ms"
              }));

      final result = await machineCommunicator.checkAvailability('10000002');
      expect(result, equals('Machine is offline right now.'));
    });

    test('Check success failure', () async {
      when(() =>
          edgeFunctionMock.runEdgeFunction(
              name: any(named: 'name'),
              body: any(named: 'body'))).thenAnswer((_) async =>
          FunctionResponse(
              status: 200,
              data: {
                "success": false,
                "deviceId": 10000000,
                "message": "idle",
                "responseTime": "104ms"
              }));

      final result = await machineCommunicator.checkAvailability('10000000');
      expect(result, equals('Could not find that machine, please try again.'));
    });
  });
}