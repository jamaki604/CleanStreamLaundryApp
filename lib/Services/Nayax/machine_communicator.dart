import 'package:clean_stream_laundry_app/Logic/Services/machine_communication_service.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';

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
}