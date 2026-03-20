import 'package:clean_stream_laundry_app/features/loading/controller.dart';
import 'package:clean_stream_laundry_app/features/loading/loading.dart';
import 'package:clean_stream_laundry_app/features/loading/widgets/error_view.dart';
import 'package:clean_stream_laundry_app/features/loading/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake controller — overrides init() so the widget never triggers real auth
// ─────────────────────────────────────────────────────────────────────────────

class _FakeController extends LoadingPageController {
  _FakeController({String? error})
      : super(
    authService: MockAuthService(),
    appLinks: MockAppLinks(),
  ) {
    this.error = error;
  }

  @override
  Future<void> init({
    required void Function(String route, {Object? extra}) navigate,
    required ValueGetter<bool> isMounted,
  }) async {
    // No-op: state was already set in the constructor for the test scenario.
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: wrap a widget in a GoRouter so context.go is available
// ─────────────────────────────────────────────────────────────────────────────

Widget _withRouter(Widget child) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, __) => child),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/homePage', builder: (_, __) => const Scaffold()),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('LoadingPage', () {
    testWidgets('shows Logo when controller has no error', (tester) async {
      final controller = _FakeController();

      await tester.pumpWidget(_withRouter(LoadingPage(controller: controller)));
      await tester.pump();

      expect(find.byType(Logo), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('shows ErrorView when controller has an error', (tester) async {
      final controller = _FakeController(error: 'Something went wrong');

      await tester.pumpWidget(_withRouter(LoadingPage(controller: controller)));
      await tester.pump();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.byType(Logo), findsNothing);
    });

    testWidgets('rebuilds and shows ErrorView when error is set after init',
            (tester) async {
          final controller = _FakeController();

          await tester.pumpWidget(_withRouter(LoadingPage(controller: controller)));
          await tester.pump();

          expect(find.byType(Logo), findsOneWidget);

          // Simulate the controller receiving an error post-init
          controller.error = 'Late error';
          controller.notifyListeners();
          await tester.pump();

          expect(find.byType(ErrorView), findsOneWidget);
          expect(find.byType(Logo), findsNothing);
        });

    testWidgets('dispose does not throw when widget is removed', (tester) async {
      final controller = _FakeController();

      await tester.pumpWidget(_withRouter(LoadingPage(controller: controller)));
      await tester.pump();

      // Replace with an empty widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      expect(tester.takeException(), isNull);
    });
  });
}