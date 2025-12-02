import 'package:clean_stream_laundry_app/Logic/Theme/theme.dart';
import 'package:clean_stream_laundry_app/Widgets/status_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget _wrapWithRouter(Widget child) {
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (_, __) => child,
        ),
        GoRoute(
          path: '/homePage',
          builder: (_, __) => const Scaffold(body: Text("HomePage")),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('statusDialog Tests', () {

    testWidgets('Dialog displays title, message, and success icon', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(const Scaffold(body: SizedBox.shrink())),
      );

      statusDialog(
        tester.element(find.byType(Scaffold)),
        title: "Success!",
        message: "Operation completed.",
        isSuccess: true,
      );

      await tester.pumpAndSettle();

      // Check that dialog content appears
      expect(find.text("Success!"), findsOneWidget);
      expect(find.text("Operation completed."), findsOneWidget);

      // Check that the success icon is present
      final iconFinder = find.byIcon(Icons.check_circle);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('Dialog displays error icon when isSuccess is false', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(const Scaffold(body: SizedBox.shrink())),
      );

      statusDialog(
        tester.element(find.byType(Scaffold)),
        title: "Error!",
        message: "Something went wrong.",
        isSuccess: false,
      );

      await tester.pumpAndSettle();

      expect(find.text("Error!"), findsOneWidget);
      expect(find.text("Something went wrong."), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('Pressing Done closes dialog', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(const Scaffold(body: SizedBox.shrink())),
      );

      statusDialog(
        tester.element(find.byType(Scaffold)),
        title: "Test",
        message: "Message",
        isSuccess: false,
      );

      await tester.pumpAndSettle();

      expect(find.text("Test"), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    });

    testWidgets('Pressing Done navigates to /homePage when isSuccess is true', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(const Scaffold(body: SizedBox.shrink())),
      );

      statusDialog(
        tester.element(find.byType(Scaffold)),
        title: "Success",
        message: "Message",
        isSuccess: true,
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text("HomePage"), findsOneWidget);
    });

  });
}