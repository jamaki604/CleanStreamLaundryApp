import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/pages/scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'mocks.dart';

void main() {
  late MockMachineCommunicationService mockMachineCommunicator;

  setUp(() {
    mockMachineCommunicator = MockMachineCommunicationService();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<MachineCommunicationService>()) {
      getIt.unregister<MachineCommunicationService>();
    }

    getIt.registerSingleton<MachineCommunicationService>(mockMachineCommunicator);
  });

  tearDown(() => GetIt.instance.reset());

  Widget createWidgetUnderTest({String initialRoute = '/scanner'}) {
    final router = GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: '/scanner',
          builder: (context, state) => const ScannerWidget(),
        ),
        GoRoute(
          path: '/startPage',
          builder: (context, state) => const Scaffold(body: Text('Start Page')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('ScannerWidget Tests', () {
    group('UI Elements', () {
      testWidgets('should display all required UI components', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(MobileScanner), findsOneWidget);
        expect(find.widgetWithText(FloatingActionButton, 'Cancel'), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('should have scanning frame overlay', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final frameFinder = find.byWidgetPredicate(
              (widget) {
            if (widget is Container && widget.decoration is BoxDecoration) {
              final decoration = widget.decoration as BoxDecoration;
              final border = decoration.border as Border?;
              return border?.top.color == Colors.white &&
                  border?.top.width == 3 &&
                  decoration.borderRadius == BorderRadius.circular(12);
            }
            return false;
          },
        );
        expect(frameFinder, findsOneWidget);

        final container = tester.widget<Container>(frameFinder);
        expect(container.constraints?.maxWidth, 250);
        expect(container.constraints?.maxHeight, 250);
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to start page when cancel is tapped', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FloatingActionButton, 'Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Start Page'), findsOneWidget);
        expect(find.byType(ScannerWidget), findsNothing);
      });
    });

    group('Camera Controller', () {
      testWidgets('should have MobileScannerController with onDetect callback', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final mobileScanner = tester.widget<MobileScanner>(
          find.byType(MobileScanner),
        );
        expect(mobileScanner.controller, isNotNull);
        expect(mobileScanner.onDetect, isNotNull);
      });

      testWidgets('should dispose without errors', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FloatingActionButton, 'Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(ScannerWidget), findsNothing);
      });
    });
  });
}