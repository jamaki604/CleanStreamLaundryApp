import '../../logic/services/door_unlock_service.dart';

class DoorUnlocker implements DoorUnlockService {
  final _readerToDoor = {
    "Reader A": "Front Door",
    "Reader B": "Broken Door",
  };

  @override
  Future<List<String>> getNearbyDoors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _readerToDoor.values.toList();
  }

  @override
  Future<bool> unlockDoor(String doorId) async {
    await Future.delayed(const Duration(seconds: 1));
    return doorId != "Broken Door"; // simulate access denied
  }

  Future<bool> unlockNearestDoor() async {
    final doors = await getNearbyDoors();
    if (doors.isEmpty) return false;

    final nearest = doors.first;
    return await unlockDoor(nearest);
  }

}