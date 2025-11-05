import 'package:clean_stream_laundry_app/Pages/email_verification_page.dart';
import 'package:clean_stream_laundry_app/Pages/home_page.dart';
import 'package:clean_stream_laundry_app/Pages/loading_page.dart';
import 'package:clean_stream_laundry_app/Pages/loyalty_card_page.dart';
import 'package:clean_stream_laundry_app/Pages/scanner_widget.dart';
import 'package:clean_stream_laundry_app/Pages/sign_up_screen.dart';
import 'package:clean_stream_laundry_app/Pages/login_page.dart';
import 'package:clean_stream_laundry_app/Pages/not_found_page.dart';
import 'package:clean_stream_laundry_app/Pages/settings.dart';
import 'package:clean_stream_laundry_app/Pages/start_machine_page.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/AuthSystem.dart';
import 'package:clean_stream_laundry_app/Pages/payment_page.dart';

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
      path: '/paymentPage',
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
    ),
    GoRoute(
      path: '/homePage',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: HomePage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
    GoRoute(
      path: '/startPage',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: StartPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    )
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);
