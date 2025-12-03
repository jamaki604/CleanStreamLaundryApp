import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';

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

  @override
  Future<String> checkAvailability(String deviceId) async {
    try {
      final response = await edgeFunctionService.runEdgeFunction(name: "ping-device", body: {'deviceId': deviceId});

      final data = response?.data;
      print(data.toString());

      if(data['success'] == false){
        return "Could not find that machine, please try again.";
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