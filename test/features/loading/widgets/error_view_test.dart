import 'package:clean_stream_laundry_app/features/loading/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _buildErrorView(String error, {List<RouteBase>? extraRoutes}) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(
        path: '/test',
        builder: (_, __) => Scaffold(body: ErrorView(error: error)),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold(key: Key('login'))),
      ...?extraRoutes,
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('ErrorView', () {
    testWidgets('renders the error icon', (tester) async {
      await tester.pumpWidget(_buildErrorView('Some error'));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders the "Authentication Failed" heading', (tester) async {
      await tester.pumpWidget(_buildErrorView('Some error'));

      expect(find.text('Authentication Failed'), findsOneWidget);
    });

    testWidgets('renders the supplied error message', (tester) async {
      const message = 'Network timeout occurred';
      await tester.pumpWidget(_buildErrorView(message));

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('renders the "Return to Login" button', (tester) async {
      await tester.pumpWidget(_buildErrorView('err'));

      expect(find.text('Return to Login'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('tapping the button navigates to /login', (tester) async {
      await tester.pumpWidget(_buildErrorView('err'));

      await tester.tap(find.text('Return to Login'));
      await tester.pumpAndSettle();

      // After navigation, the login scaffold (with its Key) should be present
      expect(find.byKey(const Key('login')), findsOneWidget);
    });

    testWidgets('renders different error messages correctly', (tester) async {
      const message = 'Exception: Invalid credentials';
      await tester.pumpWidget(_buildErrorView(message));

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('long error messages do not overflow', (tester) async {
      final longError = 'E' * 300;
      await tester.pumpWidget(_buildErrorView(longError));

      // pumpAndSettle ensures no overflow exceptions are thrown in frame render
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}