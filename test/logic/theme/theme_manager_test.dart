import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'mocks.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/middleware/storage_service.dart';

void main() {
  final getIt = GetIt.instance;
  late MockStorageService mockStorage;

  setUp(() {
    getIt.reset(); // clear previous registrations
    mockStorage = MockStorageService();
    getIt.registerSingleton<StorageService>(mockStorage);
  });

  test("Initial theme loads lightMode when no value saved", () async {
    when(() => mockStorage.init()).thenAnswer((_) async {});
    when(() => mockStorage.getValue("themeData")).thenAnswer((_) async => null);

    final manager = ThemeManager();
    await Future.delayed(Duration.zero); // allow async _initTheme to complete

    expect(manager.themeData, lightMode);
  });

  test("Initial theme loads darkMode when saved value is darkMode", () async {
    when(() => mockStorage.init()).thenAnswer((_) async {});
    when(() => mockStorage.getValue("themeData"))
        .thenAnswer((_) async => "darkMode");

    final manager = ThemeManager();
    await Future.delayed(Duration.zero);

    expect(manager.themeData, darkMode);
  });

  test("toggleTheme switches from light to dark and writes to storage", () async {
    when(() => mockStorage.init()).thenAnswer((_) async {});
    when(() => mockStorage.getValue("themeData"))
        .thenAnswer((_) async => null);
    when(() => mockStorage.setValue(any(), any())).thenAnswer((_) async {});

    final manager = ThemeManager();
    await Future.delayed(Duration.zero);

    manager.toggleTheme();

    expect(manager.themeData, darkMode);
    verify(() => mockStorage.setValue("themeData", "darkMode")).called(1);
  });

  test("toggleTheme switches from dark to light and writes to storage", () async {
    when(() => mockStorage.init()).thenAnswer((_) async {});
    when(() => mockStorage.getValue("themeData"))
        .thenAnswer((_) async => "darkMode");
    when(() => mockStorage.setValue(any(), any())).thenAnswer((_) async {});

    final manager = ThemeManager();
    await Future.delayed(Duration.zero);

    manager.toggleTheme();

    expect(manager.themeData, lightMode);
    verify(() => mockStorage.setValue("themeData", "lightMode")).called(1);
  });
}
