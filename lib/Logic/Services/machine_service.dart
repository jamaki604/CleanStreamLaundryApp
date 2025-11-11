abstract class MachineService {
  Future<Map<String, dynamic>?> getMachineById(String machineId);
  Future<int> getIdleWasherCountByLocation(String locationId);
  Future<int> getIdleDryerCountByLocation(String locationId);
  Future<int> getWasherCountByLocation(String locationId);
  Future<int> getDryerCountByLocation(String locationId);
}