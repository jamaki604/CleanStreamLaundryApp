import 'package:clean_stream_laundry_app/Pages/EmailVerification.dart';
import 'package:clean_stream_laundry_app/Pages/Loading.dart';
import 'package:clean_stream_laundry_app/Pages/Scanner.dart';
import 'package:clean_stream_laundry_app/Pages/Signup.dart';
import 'package:clean_stream_laundry_app/Pages/Login.dart';
import 'package:clean_stream_laundry_app/Pages/NotFound.dart';
import 'package:clean_stream_laundry_app/Pages/Settings.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';

GoRouter createRouter(AuthSystem authenticator) => GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => LoginScreen(auth:authenticator)),
    GoRoute(path: '/signup', builder: (_, __) => SignUpScreen(auth:authenticator)),
    GoRoute(path: '/scanner', builder: (_, __) => const ScannerWidget()),
    GoRoute(path: '/loading',
      builder: (context, state) {
        final uri = Uri.parse(state.uri.queryParameters['uri'] ?? '');
        return LoadingPage(authRedirectUri: uri,auth:authenticator);
      }
    ),
    GoRoute(path: '/settings',builder: (_,__) => Settings(auth: authenticator)),
    GoRoute(path: '/emailVerification',builder: (_,__) => EmailVerificationPage(auth: authenticator))
  ],

  errorBuilder: (context, state) => const NotFoundScreen(),
);