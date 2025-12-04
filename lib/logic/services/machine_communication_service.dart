abstract class MachineCommunicationService {
  Future<bool> wakeDevice(String deviceID);
  Future<String> checkAvailability(String deviceID);
}