import '../../logic/services/door_unlock_service.dart';

class DoorUnlocker implements DoorUnlockService {
  bool cancelled = false;

  final _readerToDoor = {
    "Reader A": "Front Door",
    //"Reader A": "Broken Door",
    "Reader B": "Back Door",
  };

  @override
  Future<List<String>> getNearbyDoors() async {
    await Future.delayed(const Duration(seconds: 1));
    return _readerToDoor.values.toList();
  }

  @override
  Future<bool> unlockDoor(String doorId) async {
    await Future.delayed(const Duration(seconds: 1));
    return doorId != "Broken Door"; // simulate access denied
  }

  void cancelUnlockingDoor() {
    cancelled = true;
  }

  Future<bool> unlockNearestDoor() async {
    cancelled = false;

    final doors = await getNearbyDoors();

    if (cancelled || doors.isEmpty)
      return false;

    final nearest = doors.first;
    return await unlockDoor(nearest);
  }


}