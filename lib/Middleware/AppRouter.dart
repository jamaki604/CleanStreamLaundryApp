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
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: LoginScreen(auth: authenticator),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: SignUpScreen(auth:authenticator),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
    GoRoute(
      path: '/scanner',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: ScannerWidget(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
    GoRoute(path: '/loading', builder: (context, state)  => LoadingPage(auth:authenticator)),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Settings(auth:authenticator),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
    GoRoute(
      path: '/loyalty',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: LoyaltyPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
    GoRoute(
      path: '/confirmation',
      pageBuilder: (context, state) {
        final machineId = state.uri.queryParameters['machineId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: PaymentPage(machineId: machineId),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        );
      },
    ),
    GoRoute(
      path: '/email-verification',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: EmailVerificationPage(auth: authenticator),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    )
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);
