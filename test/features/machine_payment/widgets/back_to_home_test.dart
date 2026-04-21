import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/features/machine_payment/widgets/back_to_home.dart';

void main() {
  testWidgets('BackToHome renders button with correct text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BackToHome(),
            ),
          ),
        );

        expect(find.text('Back to Home'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

  testWidgets('tapping BackToHome navigates to /homePage',
          (WidgetTester tester) async {
        String? navigatedRoute;

        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(
                body: BackToHome(),
              ),
            ),
            GoRoute(
              path: '/homePage',
              builder: (context, state) {
                navigatedRoute = state.uri.toString();
                return const Scaffold(
                  body: Text('Home Page'),
                );
              },
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(navigatedRoute, '/homePage');
        expect(find.text('Home Page'), findsOneWidget);
      });
}