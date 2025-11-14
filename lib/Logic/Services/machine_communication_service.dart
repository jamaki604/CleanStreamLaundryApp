abstract class MachineCommunicationService {
  Future<bool> wakeDevice(String deviceID);
  Future<bool> pingDevice(String deviceID);
}