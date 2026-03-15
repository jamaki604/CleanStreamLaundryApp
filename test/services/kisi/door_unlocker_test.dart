import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/services/kisi/door_unlocker.dart';

void main() {
  group('DoorUnlocker Tests', () {
    late DoorUnlocker unlocker;

    setUp(() {
      unlocker = DoorUnlocker();
    });

    test('getNearbyDoors returns all mapped doors', () async {
      final doors = await unlocker.getNearbyDoors();

      expect(doors.length, 2);
      expect(doors, contains("Front Door"));
      expect(doors, contains("Back Door"));
    });

    test('unlockDoor returns true for normal doors', () async {
      final result = await unlocker.unlockDoor("Front Door");
      expect(result, true);
    });

    test('unlockDoor returns false for Broken Door', () async {
      final result = await unlocker.unlockDoor("Broken Door");
      expect(result, false);
    });

    test('unlockNearestDoor unlocks the first door', () async {
      final result = await unlocker.unlockNearestDoor();
      expect(result, true);
    });

    test('unlockNearestDoor returns false when cancelled after fetching doors', () async {
      final future = unlocker.unlockNearestDoor();

      unlocker.cancelUnlockingDoor();

      final result = await future;
      expect(result, false);
    });

    test('cancelUnlockingDoor sets cancelled flag', () {
      expect(unlocker.cancelled, false);
      unlocker.cancelUnlockingDoor();
      expect(unlocker.cancelled, true);
    });
  });
}