import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/pages/home_page.dart';
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
  late MockProfileService mockProfileService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockLocationService = MockLocationService();
    mockMachineService = MockMachineService();
    mockProfileService = MockProfileService();
    mockAuthService = MockAuthService();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<LocationService>()) {
      getIt.unregister<LocationService>();
    }
    if (getIt.isRegistered<MachineService>()) {
      getIt.unregister<MachineService>();
    }
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }
    if (getIt.isRegistered<ProfileService>()) {
      getIt.unregister<ProfileService>();
    }

    getIt.registerSingleton<LocationService>(mockLocationService);
    getIt.registerSingleton<MachineService>(mockMachineService);
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<ProfileService>(mockProfileService);

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

  group('HomePage Widget Tests', () {
    test('should create HomePageState', () {
      const homePage = HomePage();
      final state = homePage.createState();
      expect(state, isA<HomePageState>());
    });

    group('UI Structure', () {
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

    group('location Dropdown', () {
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

        await tester.pumpAndSettle(const Duration(seconds: 1));

        final dropdownFinder = find.descendant(
          of: find.byType(DropdownButtonHideUnderline),
          matching: find.byType(DropdownButton<String>),
        );

        expect(dropdownFinder, findsOneWidget);

        final dropdown = tester.widget<DropdownButton<String>>(dropdownFinder);
        expect(dropdown.items, isNotNull);
        expect(dropdown.items!.length, equals(2));

        expect(dropdown.items![0].value, equals('123 Main St'));
        expect(dropdown.items![1].value, equals('456 Oak Ave'));
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

        expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

    });

    group('Nearest Location Button', () {
      testWidgets('should find and select nearest location when button is tapped', (tester) async {
        final testLocations = [
          {
            "id": 1,
            "Address": "123 Main St",
            "Latitude": 40.0,
            "Longitude": -86.0,
          },
          {
            "id": 2,
            "Address": "456 Oak Ave",
            "Latitude": 40.5,
            "Longitude": -86.5,
          },
        ];

        mockLocations(testLocations);
        mockMachineCounts('1');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final nearestLocationButton = find.ancestor(
          of: find.text('Find Nearest Location'),
          matching: find.byType(InkWell),
        );
        expect(nearestLocationButton, findsOneWidget);

        await tester.tap(nearestLocationButton);
        await tester.pumpAndSettle();

        verify(() => mockLocationService.getLocations()).called(greaterThan(1));
      });

      testWidgets('should display nearest location button with correct styling', (tester) async {
        mockLocations([{"id": 1, "Address": "123 Main St"}]);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final button = find.ancestor(
          of: find.text('Find Nearest Location'),
          matching: find.byType(InkWell),
        );
        expect(button, findsOneWidget);

        final inkWell = tester.widget<InkWell>(button);
        expect(inkWell.onTap, isNotNull);

        expect(find.text('Find Nearest Location'), findsOneWidget);
      });

      testWidgets('should update selected location after finding nearest', (tester) async {
        final testLocations = [
          {
            "id": 1,
            "Address": "123 Main St",
            "Latitude": 40.0,
            "Longitude": -86.0,
          },
          {
            "id": 2,
            "Address": "456 Oak Ave",
            "Latitude": 40.5,
            "Longitude": -86.5,
          },
        ];

        mockLocations(testLocations);
        mockMachineCounts('1');
        mockMachineCounts('2');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Select Location'), findsOneWidget);

        final nearestLocationButton = find.ancestor(
          of: find.text('Find Nearest Location'),
          matching: find.byType(InkWell),
        );
        await tester.tap(nearestLocationButton);
        await tester.pumpAndSettle();

      });

      testWidgets('should save selected location to storage', (tester) async {
        final testLocations = [
          {
            "id": 1,
            "Address": "123 Main St",
            "Latitude": 40.0,
            "Longitude": -86.0,
          },
        ];

        mockLocations(testLocations);
        mockMachineCounts('1');

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final nearestLocationButton = find.ancestor(
          of: find.text('Find Nearest Location'),
          matching: find.byType(InkWell),
        );
        await tester.tap(nearestLocationButton);
        await tester.pumpAndSettle();
      });
    });
  });

}