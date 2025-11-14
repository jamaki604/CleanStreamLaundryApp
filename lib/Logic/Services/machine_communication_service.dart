abstract class MachineCommunicationService {
  Future<bool> wakeDevice(String deviceID);
  Future<String> pingDevice(String deviceID);
}