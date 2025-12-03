import 'package:clean_stream_laundry_app/middleware/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMock extends Mock implements SharedPreferences {}

void main() {
  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
    await storageService.init();
  });

  test("setValue saves to SharedPreferences", () async {
    await storageService.setValue("testKey", "testValue");
    final result = await storageService.getValue("testKey");

    expect(result, "testValue");
  });

  test("getValue returns stored value", () async {
    await storageService.setValue("testKey", "testValue");
    final result = await storageService.getValue("testKey");

    expect(result, "testValue");
  });
}
