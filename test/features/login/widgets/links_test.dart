import 'package:clean_stream_laundry_app/features/login/widgets/links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget buildWidget() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Scaffold(body: LoginLinks())),
          GoRoute(
            path: '/signup',
            builder: (_, __) => const Scaffold(body: Text('Sign Up Page')),
          ),
          GoRoute(
            path: '/password-reset',
            builder: (_, __) =>
            const Scaffold(body: Text('Password Reset Page')),
          ),
        ],
      ),
    );
  }

  group('LoginLinks', () {
    testWidgets('displays Create Account text', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('displays Reset Password text', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('Create Account is blue and underlined', (tester) async {
      await tester.pumpWidget(buildWidget());

      final text = tester.widget<Text>(find.text('Create Account'));
      expect(text.style?.color, Colors.blue);
      expect(text.style?.decoration, TextDecoration.underline);
    });

    testWidgets('Reset Password is blue and underlined', (tester) async {
      await tester.pumpWidget(buildWidget());

      final text = tester.widget<Text>(find.text('Reset Password'));
      expect(text.style?.color, Colors.blue);
      expect(text.style?.decoration, TextDecoration.underline);
    });

    testWidgets('Create Account navigates to /signup', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up Page'), findsOneWidget);
    });

    testWidgets('Reset Password navigates to /password-reset', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Password Reset Page'), findsOneWidget);
    });

    testWidgets('both links are wrapped in InkWell', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(
        find.ancestor(
          of: find.text('Create Account'),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text('Reset Password'),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
    });
  });
}