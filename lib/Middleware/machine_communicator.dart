import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MachineCommunicator {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
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
      return data['success'] == true && data['status'] == 'authorized';
    } catch (e) {
      return false;
    }
  }

  Future<String> pingMachine(String machineID) async {
    try {
      final response = await _dio.get(
        '/pingMachine',
        queryParameters: {'machineID': machineID},
        options: Options(headers: {
          'Authorization': 'Bearer ${dotenv.env['ANON_KEY']}',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      if (data['success'] == true && data['status'] == 'available') {
        return "true";
      } else {
        return "machine not available right now, come back later";
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return "Took too long to get a response";
      }
      return "machine not available right now, come back later";
    } catch (e) {
      return "machine not available right now, come back later";
    }
  }
}