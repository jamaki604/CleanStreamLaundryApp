import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final transactionService = GetIt.instance<TransactionService>();
  final authService = GetIt.instance<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return BasePage(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   "Settings \n",
                //   style: TextStyle(
                //     fontSize: 48,
                //     fontWeight: FontWeight.w500,
                //     color: Theme.of(context).colorScheme.fontSecondary,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                Image.asset('assets/Logo.png', width: 230, height: 230),

                ElevatedButton(
                  onPressed: () {
                    authService.logout();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Sign Out"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    themeManager.toggleTheme();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(Theme.of(context).colorScheme.modeChangerText),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final transactions = await transactionService
                        .getTransactionsForUser();
                    context.go(
                      '/monthlyTransactionHistory',
                      extra: transactions,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Monthly Report"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    context.go('/refundPage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Request Refund"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
