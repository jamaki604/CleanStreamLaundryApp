import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/widgets/settings_card.dart';

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
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Logo.png', width: 230, height: 230),
                  SizedBox(height: 16),
                  SettingsCard(
                    icon: Icons.lightbulb,
                    title: Theme.of(context).colorScheme.modeChangerText,
                    onTap: () {
                      themeManager.toggleTheme();
                    },
                  ),
                  SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.money,
                    title: "Monthly Report",
                    onTap: () async {
                      final transactions = await transactionService
                          .getTransactionsForUser();
                      context.go(
                        '/monthlyTransactionHistory',
                        extra: transactions,
                      );
                    },
                  ),
                  SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.request_page,
                    title: "Request Refund",
                    onTap: () {
                      context.push('/refundPage');
                    },
                  ),
                  SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.logout,
                    title: "Sign Out",
                    onTap: () {
                      authService.logout();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
