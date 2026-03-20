import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/availability_card.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockLocationService mockLocationService;
  late MockMachineService mockMachineService;
  late MockProfileService mockProfileService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockLocationService = MockLocationService();
    mockMachineService = MockMachineService();
    mockProfileService = MockProfileService();

    GetIt.instance.reset();
    GetIt.instance.registerSingleton<AuthService>(mockAuthService);
    GetIt.instance.registerSingleton<LocationService>(mockLocationService);
    GetIt.instance.registerSingleton<MachineService>(mockMachineService);
    GetIt.instance.registerSingleton<ProfileService>(mockProfileService);

    SharedPreferences.setMockInitialValues({});

    when(() => mockAuthService.getCurrentUserId).thenReturn(null);
    when(() => mockLocationService.getLocations()).thenAnswer((_) async => [
      {'id': 1, 'Address': '123 Main St'},
    ]);
  });

  tearDown(() => GetIt.instance.reset());

  void mockMachineCounts({
    int washers = 5,
    int idleWashers = 3,
    int dryers = 4,
    int idleDryers = 2,
  }) {
    when(() => mockMachineService.getWasherCountByLocation(any()))
        .thenAnswer((_) async => washers);
    when(() => mockMachineService.getIdleWasherCountByLocation(any()))
        .thenAnswer((_) async => idleWashers);
    when(() => mockMachineService.getDryerCountByLocation(any()))
        .thenAnswer((_) async => dryers);
    when(() => mockMachineService.getIdleDryerCountByLocation(any()))
        .thenAnswer((_) async => idleDryers);
  }

  Widget buildWidget(HomePageController controller) {
    return MaterialApp(
      home: Scaffold(
        body: AvailabilityCard(controller: controller),
      ),
    );
  }

  group('AvailabilityCard', () {
    group('Loading state', () {
      testWidgets('shows CircularProgressIndicator while loading',
              (tester) async {
            mockMachineCounts();

            final controller =
            HomePageController(locationParser: MockLocationParser());
            await controller.init();
            controller.selectLocation('123 Main St');

            when(() => mockMachineService.getWasherCountByLocation(any()))
                .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 100));
              return 5;
            });

            await tester.pumpWidget(buildWidget(controller));
            await tester.pump();

            expect(find.byType(CircularProgressIndicator), findsOneWidget);

            await tester.pumpAndSettle();
          });
    });

    group('Loaded state', () {
      testWidgets('displays Availability header', (tester) async {
        mockMachineCounts();

        final controller =
        HomePageController(locationParser: MockLocationParser());
        await controller.init();
        controller.selectLocation('123 Main St');

        await tester.pumpWidget(buildWidget(controller));
        await tester.pumpAndSettle();

        expect(find.text('Availability'), findsOneWidget);
      });

      testWidgets('displays washer count text', (tester) async {
        mockMachineCounts(washers: 5, idleWashers: 3);

        final controller =
        HomePageController(locationParser: MockLocationParser());
        await controller.init();
        controller.selectLocation('123 Main St');

        await tester.pumpWidget(buildWidget(controller));
        await tester.pumpAndSettle();

        expect(find.text('3/5 Washers'), findsOneWidget);
      });

      testWidgets('displays dryer count text', (tester) async {
        mockMachineCounts(dryers: 4, idleDryers: 2);

        final controller =
        HomePageController(locationParser: MockLocationParser());
        await controller.init();
        controller.selectLocation('123 Main St');

        await tester.pumpWidget(buildWidget(controller));
        await tester.pumpAndSettle();

        expect(find.text('2/4 Dryers'), findsOneWidget);
      });

      testWidgets('displays laundry service icons', (tester) async {
        mockMachineCounts();

        final controller =
        HomePageController(locationParser: MockLocationParser());
        await controller.init();
        controller.selectLocation('123 Main St');

        await tester.pumpWidget(buildWidget(controller));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.local_laundry_service), findsNWidgets(2));
      });

      testWidgets('shows all zeros when no location selected', (tester) async {
        final controller =
        HomePageController(locationParser: MockLocationParser());
        await controller.init();

        await tester.pumpWidget(buildWidget(controller));
        await tester.pumpAndSettle();

        expect(find.text('0/0 Washers'), findsOneWidget);
        expect(find.text('0/0 Dryers'), findsOneWidget);
      });
    });
  });
}