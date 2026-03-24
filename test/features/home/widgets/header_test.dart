import 'package:clean_stream_laundry_app/features/home/controller.dart';
import 'package:clean_stream_laundry_app/features/home/widgets/header.dart';
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
    when(() => mockLocationService.getLocations())
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
  });

  tearDown(() => GetIt.instance.reset());

  Widget buildWidget({
    required HomePageController controller,
    VoidCallback? onNearestLocationTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Header(
          controller: controller,
          onNearestLocationTap: onNearestLocationTap ?? () {},
        ),
      ),
    );
  }

  Future<HomePageController> buildController() async {
    final controller = HomePageController(locationParser: MockLocationParser());
    await controller.init();
    return controller;
  }

  group('WelcomeHeader', () {
    group('Welcome text', () {
      testWidgets('shows generic welcome when username is null', (tester) async {
        final controller = await buildController();
        await tester.pumpWidget(buildWidget(controller: controller));

        expect(find.text('Welcome!'), findsOneWidget);
      });

      testWidgets('shows username in welcome text when set', (tester) async {
        when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
        when(() => mockProfileService.getUserNameById('user-1'))
            .thenAnswer((_) async => 'Jane');
        when(() => mockProfileService.getUserBalanceById('user-1'))
            .thenAnswer((_) async => {'balance': 10.0});

        final controller = HomePageController(locationParser: MockLocationParser());
        await controller.init();

        await tester.pumpWidget(buildWidget(controller: controller));

        expect(find.text('Welcome Jane!'), findsOneWidget);
      });
    });

    group('Balance text', () {
      testWidgets('shows Loading... when balance is null', (tester) async {
        final controller = await buildController();
        await tester.pumpWidget(buildWidget(controller: controller));

        expect(find.textContaining('Loading...'), findsOneWidget);
      });

      testWidgets('shows formatted balance when available', (tester) async {
        when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
        when(() => mockProfileService.getUserNameById('user-1'))
            .thenAnswer((_) async => 'Jane');
        when(() => mockProfileService.getUserBalanceById('user-1'))
            .thenAnswer((_) async => {'balance': 12.5});

        final controller = HomePageController(locationParser: MockLocationParser());
        await controller.init();

        await tester.pumpWidget(buildWidget(controller: controller));

        expect(find.textContaining('12.50'), findsOneWidget);
      });
    });

    group('Nearest Location button', () {
      testWidgets('displays Nearest Location text', (tester) async {
        final controller = await buildController();
        await tester.pumpWidget(buildWidget(controller: controller));

        expect(find.text('Nearest Location'), findsOneWidget);
      });

      testWidgets('is wrapped in InkWell', (tester) async {
        final controller = await buildController();
        await tester.pumpWidget(buildWidget(controller: controller));

        expect(
          find.ancestor(
            of: find.text('Nearest Location'),
            matching: find.byType(InkWell),
          ),
          findsOneWidget,
        );
      });

      testWidgets('calls onNearestLocationTap when tapped', (tester) async {
        var tapped = false;
        final controller = await buildController();

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            onNearestLocationTap: () => tapped = true,
          ),
        );

        await tester.tap(
          find.ancestor(
            of: find.text('Nearest Location'),
            matching: find.byType(InkWell),
          ),
        );

        expect(tapped, isTrue);
      });
    });
  });
}