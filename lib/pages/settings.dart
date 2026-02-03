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

  Future<void> _showSignOutConfirmation() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.fontInverted),
        ),

          content: Text('Are you sure you want to sign out?',
            style: TextStyle(color: Theme.of(context).colorScheme.fontInverted),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancelled
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );


    if (shouldSignOut == true) {
      authService.logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

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
                      context.push(
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
                    icon: Icons.person,
                    title: "Edit Profile",
                    onTap: () {
                      context.go('/editProfile');
                    },
                  ),
                  SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.logout,
                    title: "Sign Out",
                    onTap: () {
                      _showSignOutConfirmation();
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
