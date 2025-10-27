import 'package:clean_stream_laundry_app/Pages/EmailVerificationPage.dart';
import 'package:clean_stream_laundry_app/Pages/LoadingPage.dart';
import 'package:clean_stream_laundry_app/Pages/LoyaltyCardPage.dart';
import 'package:clean_stream_laundry_app/Pages/ScannerWidget.dart';
import 'package:clean_stream_laundry_app/Pages/SignUpScreen.dart';
import 'package:clean_stream_laundry_app/Pages/LoginScreen.dart';
import 'package:clean_stream_laundry_app/Pages/NotFoundScreen.dart';
import 'package:clean_stream_laundry_app/Pages/Settings.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';
import 'package:clean_stream_laundry_app/Pages/PaymentPage.dart';

GoRouter createRouter(AuthSystem authenticator) => GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => LoginScreen(auth:authenticator)),
    GoRoute(path: '/signup', builder: (_, __) => SignUpScreen(auth:authenticator)),
    GoRoute(path: '/scanner', builder: (_, __) => const ScannerWidget()),
    GoRoute(path: '/loading', builder: (context, state)  => LoadingPage(auth:authenticator)),
    GoRoute(path: '/settings',builder: (_,__) => Settings(auth: authenticator)),
    GoRoute(path: '/loyalty', builder: (_,__) => LoyaltyPage() ),
    GoRoute(
      path: '/confirmation',
      builder: (context, state) {
        final machineId = state.uri.queryParameters['machineId'] ?? '';
        return PaymentPage(machineId: machineId);
      },
    ),
    GoRoute(path: '/email-Verification',builder: (_,__) => EmailVerificationPage(auth: authenticator))
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);
