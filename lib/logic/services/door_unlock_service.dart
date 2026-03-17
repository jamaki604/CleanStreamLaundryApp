abstract class DoorUnlockService {
  Future<List<String>> getNearbyDoors();
  Future<bool> unlockDoor(String doorId);
}