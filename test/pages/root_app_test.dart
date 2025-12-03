import 'package:clean_stream_laundry_app/middleware/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/pages/root_app.dart';
import 'package:go_router/go_router.dart';
import 'mocks.dart';
import 'package:clean_stream_laundry_app/main.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';


void main() {
  late MockAuthService auth;
  late MockRouterService routerService;

  setUp(() {
    getIt.reset();
    routerService = MockRouterService();
    auth = MockAuthService();

    getIt.registerSingleton<RouterService>(routerService);
    getIt.registerSingleton<AuthService>(auth);

    final fakeRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Placeholder(key: Key('fake-home')),
        ),
      ],
    );

    when(() => routerService.createRouter(auth)).thenReturn(fakeRouter);
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('RootApp builds correctly using mocked services & fake GoRouter',
          (tester) async {
        final theme = ThemeData(
          primaryColor: Colors.orange,
        );

        await tester.pumpWidget(RootApp(theme: theme));
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);

        expect(find.byKey(const Key('fake-home')), findsOneWidget);

        final MaterialApp app = tester.widget(find.byType(MaterialApp));
        expect(app.theme!.primaryColor, Colors.orange);
      });
}