import 'package:clean_stream_laundry_app/features/widgets/custom_app_bar.dart';
import 'package:clean_stream_laundry_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  group("Custom App Bar Tests", () {
    test('CustomAppBar instantiates correctly', () {
      const customAppBar = CustomAppBar();
      expect(customAppBar, isA<CustomAppBar>());
    });

    test('CustomAppBar implements PreferredSizeWidget', () {
      const customAppBar = CustomAppBar();
      expect(customAppBar, isA<PreferredSizeWidget>());
    });

    testWidgets('CustomAppBar builds an AppBar widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(appBar: const CustomAppBar())),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('CustomAppBar uses theme primary background', (tester) async {
      const testColor = Color(0xFF2073A9);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(primary: testColor),
          ),
          home: Scaffold(appBar: const CustomAppBar()),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, testColor);
    });

    testWidgets('CustomAppBar renders correctly inside Scaffold', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(),
            body: const Text('Testing'),
          ),
        ),
      );

      expect(find.text('Testing'), findsOneWidget);
    });

    testWidgets('settings icon navigates to settings route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const Scaffold(appBar: CustomAppBar()),
              ),
              GoRoute(
                path: '/settings',
                builder: (_, _) => const Scaffold(body: Text('Settings Page')),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('settings-button')));
      await tester.pumpAndSettle();

      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('notification bell opens no notifications sheet', (
      tester,
    ) async {
      final notificationService = MockNotificationService();
      when(
        () => notificationService.getPendingNotifications(),
      ).thenAnswer((_) async => const []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(notificationService: notificationService),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('notifications-button')));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('No notifications'), findsOneWidget);
    });

    testWidgets('notification bell shows pending notifications', (
      tester,
    ) async {
      final notificationService = MockNotificationService();
      when(() => notificationService.getPendingNotifications()).thenAnswer(
        (_) async => const [
          AppNotification(
            id: 1,
            title: 'Machine Almost Ready',
            body: 'Dryer 12 will be finished in 5 minutes!',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(notificationService: notificationService),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('notifications-button')));
      await tester.pumpAndSettle();

      expect(find.text('Machine Almost Ready'), findsOneWidget);
      expect(
        find.text('Dryer 12 will be finished in 5 minutes!'),
        findsOneWidget,
      );
    });
  });
}
