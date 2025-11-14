import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';

class SupabaseAvailabilityCheckService {
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();

  SupabaseAvailabilityCheckService();

  Future<String> checkAvailability(String deviceId) async {
    try {
      final response = await edgeFunctionService.runEdgeFunction(name: "ping-device", body: {'deviceId': deviceId});

      final data = response?.data;
      print(data.toString());

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
    } catch (e) {
      print("Ping error: $e");
      return "Ping Server Error";

    }
  }
}