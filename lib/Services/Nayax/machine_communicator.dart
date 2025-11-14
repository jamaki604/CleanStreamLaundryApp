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

  Future<String> pingDevice(String deviceId) async {
    debugPrint("Pinging Device");
    try {
      final response = await _dio.post(
        '/ping-device',
          data: {
            'deviceId': deviceId,
          },

          options: Options(headers: {
          'Authorization': 'Bearer ${dotenv.env['ANON_KEY']}',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      print(response.toString());

      if(data['success'] == false){
        return "Could not find that machine, please try again";
      }
      else if(data['success'] == true && data['message'] == "idle"){
        return "pass";
      }
      else if(data['success'] == true && data['message'] == "in-use"){
        return "Machine is being used right now.";
      }
      else{
        return "Machine is offline right now.";
      }
    } on DioError catch (e) {
    debugPrint("Dio error: ${e.response?.statusCode} ${e.response?.data}");
    return "Dio Server Error, maybe try again?";
    } catch (e) {
      debugPrint("Ping error: $e");
      return "Ping Server Error";

    }
  }
}