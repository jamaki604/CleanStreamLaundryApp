import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/widgets/custom_app_bar.dart';
import 'package:clean_stream_laundry_app/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {

  Widget wrapWithRouter(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => child,
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group("BasePage tests", () {
    test('BasePage instantiates correctly', () {
      const basePage = BasePage(body: Text("test"));
      expect(basePage, isA<BasePage>());
    });

    testWidgets('renders provided body widget', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(const BasePage(body: Text("Hello"))),
      );

      expect(find.text("Hello"), findsOneWidget);
    });

    testWidgets('contains a Scaffold', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(const BasePage(body: Text("test"))),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays CustomAppBar', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(const BasePage(body: Text("test"))),
      );

      expect(find.byType(CustomAppBar), findsOneWidget);
    });

    testWidgets('displays NavBar as bottom navigation', (tester) async {
      await tester.pumpWidget(
        wrapWithRouter(const BasePage(body: Text("test"))),
      );

      expect(find.byType(NavBar), findsOneWidget);
    });

    testWidgets('uses theme background color', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const BasePage(body: Text("test")),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(
            colorScheme: const ColorScheme.light(surface: Colors.red),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.red);
    });

    testWidgets('BasePage builds correctly inside Navigator', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => const BasePage(body: Text("test")),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );

      expect(find.byType(BasePage), findsOneWidget);
    });
  });
}
