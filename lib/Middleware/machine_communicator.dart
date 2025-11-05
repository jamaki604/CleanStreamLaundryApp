import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MachineCommunicator {

  final Dio _dio = Dio(
      BaseOptions(baseUrl: 'https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1')
  );

  Future<bool> wakeDevice(String deviceId) async {
    try {
      final response = await _dio.post(
        '/wakeDevice',
        data: {'deviceId': deviceId},
        options: Options(headers: {
          'Authorization': 'Bearer ${dotenv.env['ANON_KEY']}',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;

      if (data['success'] == true && data['status'] == 'authorized') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}