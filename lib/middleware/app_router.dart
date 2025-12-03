import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/pages/email_verification_page.dart';
import 'package:clean_stream_laundry_app/pages/home_page.dart';
import 'package:clean_stream_laundry_app/pages/loading_page.dart';
import 'package:clean_stream_laundry_app/pages/loyalty_card_page.dart';
import 'package:clean_stream_laundry_app/pages/scanner_widget.dart';
import 'package:clean_stream_laundry_app/pages/sign_up_screen.dart';
import 'package:clean_stream_laundry_app/pages/login_page.dart';
import 'package:clean_stream_laundry_app/pages/not_found_page.dart';
import 'package:clean_stream_laundry_app/pages/settings.dart';
import 'package:clean_stream_laundry_app/pages/start_machine_page.dart';
import 'package:clean_stream_laundry_app/pages/payment_page.dart';
import 'package:clean_stream_laundry_app/pages/monthly_transaction_history.dart';
import 'package:clean_stream_laundry_app/pages/refund_page.dart';

class RouterService {
  GoRouter createRouter(AuthService authenticator) =>
      GoRouter(
        initialLocation: '/loading',
        routes: [
          GoRoute(
            path: '/login',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: LoginScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
                ),
          ),
          GoRoute(
            path: '/signup',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: SignUpScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
                ),
          ),
          GoRoute(
            path: '/scanner',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: ScannerWidget(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
                ),
          ),
          GoRoute(path: '/loading', builder: (context, state) => LoadingPage()),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: Settings(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
                ),
          ),
          GoRoute(
            path: '/loyalty',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: LoyaltyPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
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
                transitionsBuilder: (_, _, _, child) => child,
              );
            },
          ),
          GoRoute(
            path: '/email-verification',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: EmailVerificationPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
                ),
          ),
          GoRoute(
            path: '/homePage',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: HomePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
                ),
          ),
          GoRoute(
            path: '/startPage',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: StartPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
                ),
          ),
          GoRoute(
            path: '/monthlyTransactionHistory',
            pageBuilder: (context, state) {
              final transactions = state.extra as List<Map<String, dynamic>>? ??
                  [];
              return CustomTransitionPage(
                key: state.pageKey,
                child: MonthlyTransactionHistory(transactions: transactions),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                transitionsBuilder: (_, _, _, child) => child,
              );
            },
          ),
          GoRoute(
            path: '/refundPage',
            pageBuilder: (context, state) =>
                CustomTransitionPage(
                  key: state.pageKey,
                  child: RefundPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  transitionsBuilder: (_, _, _, child) => child,
                ),
          )
        ],
        errorBuilder: (context, state) => const NotFoundScreen(),
      );
}