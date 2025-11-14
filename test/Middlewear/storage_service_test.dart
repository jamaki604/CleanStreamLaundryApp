import 'package:clean_stream_laundry_app/Middleware/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMock extends Mock implements SharedPreferences {}

void main() {
  late SharedPreferencesMock sharedPrefsMock;
  late StorageService storageService;

  setUp(() {
    sharedPrefsMock = SharedPreferencesMock();
    storageService = StorageService();
    storageService.storageInstance = sharedPrefsMock;
  });

  test("setValue saves to SharedPreferences", () async {
    when(() => sharedPrefsMock.setString(any(), any()))
        .thenAnswer((_) async => true);

    await storageService.setValue("testKey", "testValue");

    verify(() => sharedPrefsMock.setString("testKey", "testValue")).called(1);
  });

  test("getValue returns stored value", () async {
    when(() => sharedPrefsMock.getString("testKey"))
        .thenReturn("testValue");

    final result = await storageService.getValue("testKey");

    expect(result, "testValue");
  });

  test('Tes that initializer works', () async {
    // Provide fake initial values
    SharedPreferences.setMockInitialValues({});

    final service = StorageService();
    await service.init();

    expect(service.storageInstance, isNotNull);
  });
}
