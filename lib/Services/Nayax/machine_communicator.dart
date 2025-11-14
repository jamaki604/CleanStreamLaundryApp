import 'package:clean_stream_laundry_app/Logic/Services/machine_communication_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MachineCommunicator implements MachineCommunicationService {

  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();

  @override
  Future<bool> wakeDevice(String deviceId) async {
    try {
      final response = await edgeFunctionService.runEdgeFunction(
          name: 'wakeDevice',
          body: {'deviceId': deviceId}
      );

      final data = response?.data;

      if (data != null && data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<bool> pingDevice(String deviceId) async {
    debugPrint("Pinging Device");
    try {
      final response = await _dio.post(
        '/ping-device',
        data: {'deviceId': deviceId},
        options: Options(headers: {
          'Authorization': 'Bearer ${dotenv.env['ANON_KEY']}',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      print(response.toString() + "Hello world");
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}