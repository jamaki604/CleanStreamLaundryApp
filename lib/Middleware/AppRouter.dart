import 'package:clean_stream_laundry_app/Pages/Loading.dart';
import 'package:clean_stream_laundry_app/Pages/Scanner.dart';
import 'package:clean_stream_laundry_app/Pages/Signup.dart';
import 'package:clean_stream_laundry_app/Pages/Login.dart';
import 'package:clean_stream_laundry_app/Pages/NotFound.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Pages/LoyaltyCardPage.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
    GoRoute(path: '/scanner', builder: (_, __) => const ScannerWidget()),
    GoRoute(path: '/loyalty', builder: (_, __) => const LoyaltyCardPage()),
    GoRoute(
      path: '/loading',
      builder: (context, state) {
        final uri = Uri.parse(state.uri.queryParameters['uri'] ?? '');
        return LoadingPage(authRedirectUri: uri);
      },
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);
