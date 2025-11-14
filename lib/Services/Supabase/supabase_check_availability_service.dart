import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseAvailabilityCheckService {
  final Dio _dio;

  SupabaseAvailabilityCheckService({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: 'https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));


  Future<String> checkAvailability(String deviceId) async {
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
        return "Machine is in use right now.";
      }
      else{
        return "Machine is offline right now.";
      }
    } on DioError catch (e) {
      print("Dio error: ${e.response?.statusCode} ${e.response?.data}");
      return "Dio Server Error, maybe try again?";
    } catch (e) {
      print("Ping error: $e");
      return "Ping Server Error";

    }
  }
}