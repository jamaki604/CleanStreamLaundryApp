import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math'; // Remove once Nayax scanning is implemented
import 'package:flutter/foundation.dart'; // for debugPrint

class MachineCommunicator {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<bool> wakeDevice(String deviceId) async {
    debugPrint("Waking Device");
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
      print(response.toString() + "Hello world");
      return data['success'] == true && data['status'] == 'authorized';
    } catch (e) {
      return false;
    }
  }

  Future<String> pingMachine(String machineID) async {
    try {
      final response = await _dio.post(
        '/wakeDevice',
        data: {'deviceId': machineID},
        options: Options(headers: {
          'Authorization': 'Bearer ${dotenv.env['ANON_KEY']}',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      if(data['success'] == true && data['status'] == 'authorized')
        {
          return "true";
        }
      else{
        return "Machine unavalible";
      }
    } catch (e) {
      return "Couldnt find machine";
    }
  }
}