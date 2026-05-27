import 'package:clean_stream_laundry_app/features/home/home.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockLocationService mockLocationService;
  late MockMachineService mockMachineService;
  late MockProfileService mockProfileService;

  final defaultLocations = [
    {'id': 1, 'Address': '123 Main St'},
    {'id': 2, 'Address': '456 Oak Ave'},
  ];

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
    when(
      () => mockLocationService.getLocations(),
    ).thenAnswer((_) async => defaultLocations);
  });

  tearDown(() => GetIt.instance.reset());

  Widget createWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
        ],
      ),
    );
  }

  void mockMachineCounts(
    String locationId, {
    int washers = 5,
    int idleWashers = 3,
    int dryers = 4,
    int idleDryers = 2,
  }) {
    when(
      () => mockMachineService.getWasherCountByLocation(locationId),
    ).thenAnswer((_) async => washers);
    when(
      () => mockMachineService.getIdleWasherCountByLocation(locationId),
    ).thenAnswer((_) async => idleWashers);
    when(
      () => mockMachineService.getDryerCountByLocation(locationId),
    ).thenAnswer((_) async => dryers);
    when(
      () => mockMachineService.getIdleDryerCountByLocation(locationId),
    ).thenAnswer((_) async => idleDryers);
  }

  group('Loading state', () {
    testWidgets('shows loading indicator while fetching data', (tester) async {
      when(() => mockLocationService.getLocations()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return defaultLocations;
      });

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('Static UI', () {
    testWidgets('shows welcome message without username', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Welcome!'), findsOneWidget);
    });

    testWidgets('shows welcome message with username when user loaded', (
      tester,
    ) async {
      when(() => mockAuthService.getCurrentUserId).thenReturn('user-1');
      when(
        () => mockProfileService.getUserNameById('user-1'),
      ).thenAnswer((_) async => 'Jane');
      when(
        () => mockProfileService.getUserBalanceById('user-1'),
      ).thenAnswer((_) async => {'balance': 10.00});

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Jane!'), findsOneWidget);
    });

    testWidgets('shows balance loading text when balance is null', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Loading...'), findsOneWidget);
    });

    testWidgets('has SingleChildScrollView', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('fits compact screens when a location is selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      SharedPreferences.setMockInitialValues({
        'lastSelectedLocation': '123 Main St',
        'locationSelectionMode': 'manual',
      });
      mockMachineCounts('1');

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Availability'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays Nearest Location button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nearest Location'), findsOneWidget);
    });

    testWidgets('displays Select Location text when no location chosen', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Select Location'), findsOneWidget);
    });

    testWidgets('displays location_on icon', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays navigation icon button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('does not show availability card before location selected', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Availability'), findsNothing);
    });
  });

  group('Location selector', () {
    testWidgets('shows locations in bottom sheet when tapped', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Location'));
      await tester.pumpAndSettle();

      expect(find.text('123 Main St'), findsOneWidget);
      expect(find.text('456 Oak Ave'), findsOneWidget);
    });

    testWidgets('updates selected location after tapping a location', (
      tester,
    ) async {
      mockMachineCounts('1');

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Location'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('123 Main St'));
      await tester.pumpAndSettle();

      expect(find.text('123 Main St'), findsOneWidget);
    });

    testWidgets('shows availability card after selecting a location', (
      tester,
    ) async {
      mockMachineCounts('1');

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Location'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('123 Main St'));
      await tester.pumpAndSettle();

      expect(find.text('Availability'), findsOneWidget);
    });

    testWidgets('restores last selected location from storage', (tester) async {
      SharedPreferences.setMockInitialValues({
        'lastSelectedLocation': '123 Main St',
      });
      mockMachineCounts('1');

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('123 Main St'), findsOneWidget);
    });

    testWidgets('shows snackbar when directions tapped with no location', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.navigation));
      await tester.pumpAndSettle();

      expect(
        find.text('Please select a location to get directions!'),
        findsOneWidget,
      );
    });
  });

  group('Availability card', () {
    testWidgets('shows washer and dryer counts after selecting location', (
      tester,
    ) async {
      mockMachineCounts(
        '1',
        washers: 5,
        idleWashers: 3,
        dryers: 4,
        idleDryers: 2,
      );

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Location'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('123 Main St'));
      await tester.pumpAndSettle();

      expect(find.text('3/5 Washers'), findsOneWidget);
      expect(find.text('2/4 Dryers'), findsOneWidget);
    });
  });

  group('Nearest location button', () {
    testWidgets('nearest location button is tappable', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final button = find.ancestor(
        of: find.text('Nearest Location'),
        matching: find.byType(InkWell),
      );

      expect(button, findsOneWidget);
      final inkWell = tester.widget<InkWell>(button);
      expect(inkWell.onTap, isNotNull);
    });

    testWidgets('tapping nearest location calls getLocations', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final button = find.ancestor(
        of: find.text('Nearest Location'),
        matching: find.byType(InkWell),
      );

      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(() => mockLocationService.getLocations()).called(1);
    });
  });
}
