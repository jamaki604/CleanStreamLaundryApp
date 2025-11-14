import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/Services/Nayax/machine_communicator.dart';
import 'package:clean_stream_laundry_app/Services/Supabase/supabase_edge_function_service.dart';
import 'package:clean_stream_laundry_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main(){

  late MachineCommunicator machineCommunicator;
  late EdgeFunctionMock edgeFunctionMock;

  group("Machine communicator tests", (){

    setUp((){
      getIt.reset();
      edgeFunctionMock = EdgeFunctionMock();

      getIt.registerLazySingleton<EdgeFunctionService>(
              () => edgeFunctionMock);

      machineCommunicator = MachineCommunicator();

    });

    test("Machine successfully wakes up",() async {

      when(() => edgeFunctionMock.runEdgeFunction(name: any(named:'name'), body: any(named:'body'))).thenAnswer((_) async => FunctionResponse(status: 200,data: {"success": true, "deviceId": 5, "error": "Device reachable", "responseTime": "84ms"}));

      final result = await machineCommunicator.wakeDevice('123');
      expect(result, true);
    });

    test("Machine fails to wake up",() async {

      when(() => edgeFunctionMock.runEdgeFunction(name: any(named:'name'), body: any(named:'body'))).thenAnswer((_) async => FunctionResponse(status: 503,data: {"success": false, "deviceId": 5, "error": "Device unreachable", "responseTime": "84ms"}));

      final result = await machineCommunicator.wakeDevice('123');
      expect(result, false);
    });

    test("Tests if there is an unexpected error",() async {

      when(() => edgeFunctionMock.runEdgeFunction(name: any(named:'name'), body: any(named:'body'))).thenThrow(Exception("Test error"));

      final result = await machineCommunicator.wakeDevice('123');
      expect(result, false);
    });



  });

}