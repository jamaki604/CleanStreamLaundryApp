import 'package:clean_stream_laundry_app/Components/base_page.dart';
import 'package:clean_stream_laundry_app/Components/large_button.dart';
import 'package:clean_stream_laundry_app/Logic/Services/location_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/machine_service.dart';
import 'package:clean_stream_laundry_app/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mocks.dart';

void main() {
  late MockLocationService mockLocationService;
  late MockMachineService mockMachineService;

  setUp(() {
    mockLocationService = MockLocationService();
    mockMachineService = MockMachineService();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<LocationService>()) {
      getIt.unregister<LocationService>();
    }
    if (getIt.isRegistered<MachineService>()) {
      getIt.unregister<MachineService>();
    }

    getIt.registerSingleton<LocationService>(mockLocationService);
    getIt.registerSingleton<MachineService>(mockMachineService);

    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() => GetIt.instance.reset());

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  void mockLocations([List<Map<String, dynamic>>? locations]) {
    when(() => mockLocationService.getLocations()).thenAnswer(
          (_) async => locations ?? [
        {"id": 1, "Address": "123 Main St"},
        {"id": 2, "Address": "456 Oak Ave"},
      ],
    );
  }

  void mockMachineCounts(String locationId, {
    int washers = 5,
    int idleWashers = 3,
    int dryers = 4,
    int idleDryers = 2,
  }) {
    when(() => mockMachineService.getWasherCountByLocation(locationId))
        .thenAnswer((_) async => washers);
    when(() => mockMachineService.getIdleWasherCountByLocation(locationId))
        .thenAnswer((_) async => idleWashers);
    when(() => mockMachineService.getDryerCountByLocation(locationId))
        .thenAnswer((_) async => dryers);
    when(() => mockMachineService.getIdleDryerCountByLocation(locationId))
        .thenAnswer((_) async => idleDryers);
  }

  Future<void> selectLocation(WidgetTester tester, String address) async {
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(address).last);
    await tester.pumpAndSettle();
  }

  group('HomePage Widget Tests', () {
    test('should create HomePageState', () {
      const homePage = HomePage();
      final state = homePage.createState();
      expect(state, isA<HomePageState>());
    });

    group('UI Structure', () {
      testWidgets('should be wrapped in BasePage', (tester) async {
        mockLocations([{"id": 1, "Address": "123 Main St"}]);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(BasePage), findsOneWidget);
      });

      testWidgets('should have SingleChildScrollView for scrolling', (tester) async {
        mockLocations([{"id": 1, "Address": "123 Main St"}]);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('should have proper layout structure', (tester) async {
        mockLocations([{"id": 1, "Address": "123 Main St"}]);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(Column), findsWidgets);
        expect(find.byType(Padding), findsWidgets);
      });
    });

    group('Location Dropdown', () {
      testWidgets('should display location dropdown', (tester) async {
        mockLocations();
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Select Location'), findsOneWidget);
        expect(find.byIcon(Icons.location_on), findsOneWidget);
      });

      testWidgets('should populate dropdown with locations', (tester) async {
        mockLocations();
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();

        expect(find.text('123 Main St'), findsWidgets);
        expect(find.text('456 Oak Ave'), findsOneWidget);
      });

      testWidgets('should restore last selected location from storage', (tester) async {
        SharedPreferences.setMockInitialValues({
          'lastSelectedLocation': '123 Main St',
        });
        mockLocations();
        mockMachineCounts('1');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('123 Main St'), findsOneWidget);
        expect(find.byType(LargeButton), findsNWidgets(2));
      });
    });

    group('Machine Buttons', () {
      testWidgets('should show machine buttons when location is selected', (tester) async {
        mockLocations([{"id": 1, "Address": "123 Main St"}]);
        mockMachineCounts('1');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        await selectLocation(tester, '123 Main St');

        expect(find.byType(LargeButton), findsNWidgets(2));
        expect(find.textContaining('washers'), findsOneWidget);
        expect(find.textContaining('dryers'), findsOneWidget);
      });

      testWidgets('should display correct washer counts', (tester) async {
        mockLocations([{"id": 1, "Address": "123 Main St"}]);
        mockMachineCounts('1');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        await selectLocation(tester, '123 Main St');

        expect(find.text('5 available'), findsNWidgets(1));
        expect(find.text('5/5 washers'), findsOneWidget);
      });

      testWidgets('should display correct dryer counts', (tester) async {
        mockLocations([{"id": 1, "Address": "123 Main St"}]);
        mockMachineCounts('1');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        await selectLocation(tester, '123 Main St');

        expect(find.text('4/4 dryers'), findsOneWidget);
      });
    });

    group('Loading States', () {
      testWidgets('should show loading indicator while fetching locations', (tester) async {
        when(() => mockLocationService.getLocations()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [{"id": 1, "Address": "123 Main St"}];
        });

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('should show loading indicator while fetching machine data', (tester) async {
        mockLocations([{"id": 1, "Address": "123 Main St"}]);

        when(() => mockMachineService.getWasherCountByLocation('1')).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return 5;
        });
        when(() => mockMachineService.getIdleWasherCountByLocation('1'))
            .thenAnswer((_) async => 3);
        when(() => mockMachineService.getDryerCountByLocation('1'))
            .thenAnswer((_) async => 4);
        when(() => mockMachineService.getIdleDryerCountByLocation('1'))
            .thenAnswer((_) async => 2);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('123 Main St').last);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNWidgets(3));

        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });
  
}