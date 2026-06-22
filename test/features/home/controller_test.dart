import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockLocationService mockLocationService;
  late MockMachineService mockMachineService;
  late MockProfileService mockProfileService;
  late MockLocationParser mockLocationParser;

  final testLocations = [
    {'id': 1, 'Address': '123 Main St', 'Latitude': 40.0, 'Longitude': -86.0},
    {'id': 2, 'Address': '456 Oak Ave', 'Latitude': 40.5, 'Longitude': -86.5},
  ];

  setUp(() {
    mockAuthService = MockAuthService();
    mockLocationService = MockLocationService();
    mockMachineService = MockMachineService();
    mockProfileService = MockProfileService();
    mockLocationParser = MockLocationParser();

    GetIt.instance.reset();
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<LocationService>(mockLocationService);
    GetIt.instance.registerSingleton<MachineService>(mockMachineService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);

    SharedPreferences.setMockInitialValues({});

    when(() => mockAuthService.getCurrentUserId).thenReturn(null);
    when(
      () => mockLocationService.getLocations(),
    ).thenAnswer((_) async => testLocations);
    when(
      () => mockLocationParser.getNearestLocation(any()),
    ).thenAnswer((_) async => null);
  });

  tearDown(() => GetIt.instance.reset());

  HomePageController buildController() =>
      HomePageController(locationParser: mockLocationParser);

  group('init', () {
    test('sets isLoading to false after init', () async {
      final controller = buildController();

      expect(controller.isLoading, isTrue);

      await controller.init();

      expect(controller.isLoading, isFalse);
    });

    test('populates locations from service', () async {
      final controller = buildController();

      await controller.init();

      expect(controller.locations, testLocations);
    });

    test('populates locationID map', () async {
      final controller = buildController();

      await controller.init();

      expect(controller.locationID['123 Main St'], equals(1));
      expect(controller.locationID['456 Oak Ave'], equals(2));
    });

    test('populates locationCoordinates map', () async {
      final controller = buildController();

      await controller.init();

      expect(controller.locationCoordinates.containsKey('123 Main St'), isTrue);
      expect(controller.locationCoordinates.containsKey('456 Oak Ave'), isTrue);
    });

    test('does not call profile service when userId is null', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn(null);
      final controller = buildController();

      await controller.init();

      verifyNever(() => mockProfileService.getUserNameById(any()));
      verifyNever(() => mockProfileService.getUserBalanceById(any()));
    });

    test('loads username and balance when userId is set', () async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
      when(
        () => mockProfileService.getUserNameById('user-1'),
      ).thenAnswer((_) async => 'John Doe');
      when(
        () => mockProfileService.getUserBalanceById('user-1'),
      ).thenAnswer((_) async => {'balance': 12.50});

      final controller = buildController();
      await controller.init();

      expect(controller.username, 'John Doe');
      expect(controller.balance?['balance'], 12.50);
    });

    test('restores last selected location from storage', () async {
      SharedPreferences.setMockInitialValues({
        'lastSelectedLocation': '123 Main St',
        'locationSelectionMode': 'manual',
      });

      final controller = buildController();
      await controller.init();

      expect(controller.selectedName, '123 Main St');
      expect(controller.locationSelected, isTrue);
      expect(controller.locationIDSelected, 1);
    });

    test(
      'does not restore location if stored address not in locations',
      () async {
        SharedPreferences.setMockInitialValues({
          'lastSelectedLocation': 'Unknown Address',
          'locationSelectionMode': 'manual',
        });

        final controller = buildController();
        await controller.init();

        expect(controller.locationSelected, isFalse);
        expect(controller.locationIDSelected, isNull);
      },
    );

    test(
      'selects nearest location by default without manual preference',
      () async {
        when(
          () => mockLocationParser.getNearestLocation(any()),
        ).thenAnswer((_) async => testLocations.last);

        final controller = buildController();
        await controller.init();

        expect(controller.selectedName, '456 Oak Ave');
        expect(controller.locationSelected, isTrue);
        expect(controller.locationIDSelected, 2);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('locationSelectionMode'), 'nearest');
        expect(prefs.getString('lastSelectedLocation'), '456 Oak Ave');
      },
    );

    test('manual location preference overrides nearest default', () async {
      SharedPreferences.setMockInitialValues({
        'lastSelectedLocation': '123 Main St',
        'locationSelectionMode': 'manual',
      });
      when(
        () => mockLocationParser.getNearestLocation(any()),
      ).thenAnswer((_) async => testLocations.last);

      final controller = buildController();
      await controller.init();

      expect(controller.selectedName, '123 Main St');
      expect(controller.locationSelected, isTrue);
      expect(controller.locationIDSelected, 1);
      verifyNever(() => mockLocationParser.getNearestLocation(any()));
    });
  });

  group('selectLocation', () {
    test('sets selectedName, locationSelected, locationIDSelected', () async {
      final controller = buildController();
      await controller.init();

      controller.selectLocation('123 Main St');

      expect(controller.selectedName, '123 Main St');
      expect(controller.locationSelected, isTrue);
      expect(controller.locationIDSelected, 1);
    });

    test('does nothing for unknown address', () async {
      final controller = buildController();
      await controller.init();

      controller.selectLocation('Unknown Address');

      expect(controller.locationSelected, isFalse);
      expect(controller.locationIDSelected, isNull);
    });

    test('saves selection to storage', () async {
      final controller = buildController();
      await controller.init();

      controller.selectLocation('123 Main St');
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('lastSelectedLocation'), '123 Main St');
      expect(prefs.getString('locationSelectionMode'), 'manual');
    });

    test('calls onZoom when coordinates exist', () async {
      final controller = buildController();
      await controller.init();

      LatLng? zoomedTo;
      double? zoomedZoom;
      controller.onZoom = (coords, zoom) {
        zoomedTo = coords;
        zoomedZoom = zoom;
      };

      controller.selectLocation('123 Main St');

      expect(zoomedTo, isNotNull);
      expect(zoomedZoom, equals(15.0));
    });
  });

  group('selectNearestLocation', () {
    test('selects the nearest location when one is found', () async {
      when(
        () => mockLocationParser.getNearestLocation(any()),
      ).thenAnswer((_) async => testLocations.first);

      final controller = buildController();
      await controller.init();

      await controller.selectNearestLocation();

      expect(controller.selectedName, '123 Main St');
      expect(controller.locationSelected, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locationSelectionMode'), 'nearest');
      expect(prefs.getString('lastSelectedLocation'), '123 Main St');
    });

    test('does nothing when no nearest location found', () async {
      when(
        () => mockLocationParser.getNearestLocation(any()),
      ).thenAnswer((_) async => null);

      final controller = buildController();
      await controller.init();

      await controller.selectNearestLocation();

      expect(controller.locationSelected, isFalse);
    });
  });

  group('getMachineCounts', () {
    setUp(() {
      when(
        () => mockMachineService.getWasherCountByLocation(any()),
      ).thenAnswer((_) async => 5);
      when(
        () => mockMachineService.getIdleWasherCountByLocation(any()),
      ).thenAnswer((_) async => 3);
      when(
        () => mockMachineService.getDryerCountByLocation(any()),
      ).thenAnswer((_) async => 4);
      when(
        () => mockMachineService.getIdleDryerCountByLocation(any()),
      ).thenAnswer((_) async => 2);
    });

    test('returns [0,0,0,0] when no location selected', () async {
      final controller = buildController();
      await controller.init();

      final counts = await controller.getMachineCounts();

      expect(counts, [0, 0, 0, 0]);
    });

    test('returns machine counts for selected location', () async {
      final controller = buildController();
      await controller.init();
      controller.selectLocation('123 Main St');

      final counts = await controller.getMachineCounts();

      expect(counts, [5, 3, 4, 2]);
    });

    test('passes correct locationId string to each service call', () async {
      final controller = buildController();
      await controller.init();
      controller.selectLocation('123 Main St'); // id = 1

      await controller.getMachineCounts();

      verify(() => mockMachineService.getWasherCountByLocation('1')).called(1);
      verify(
        () => mockMachineService.getIdleWasherCountByLocation('1'),
      ).called(1);
      verify(() => mockMachineService.getDryerCountByLocation('1')).called(1);
      verify(
        () => mockMachineService.getIdleDryerCountByLocation('1'),
      ).called(1);
    });
  });
}
