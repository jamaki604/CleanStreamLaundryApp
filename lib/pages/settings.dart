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
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final transactionService = GetIt.instance<TransactionService>();
  final authService = GetIt.instance<AuthService>();
  final profileService = GetIt.instance<ProfileService>();

  int notificationDelay = 5;
  bool _loadingDelay = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationDelay();
  }

  Future<void> _loadNotificationDelay() async {
    final value = await profileService.getNotificationDelay();
    setState(() {
      notificationDelay = value;
      _loadingDelay = false;
    });
  }

  Future<void> _updateDelay(int newDelayValue) async {
    setState(() => notificationDelay = newDelayValue);
    await profileService.setNotificationDelay(newDelayValue);
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
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.money,
                    title: "Monthly Report",
                    onTap: () async {
                      final transactions =
                      await transactionService.getTransactionsForUser();
                      context.push(
                        '/monthlyTransactionHistory',
                        extra: transactions,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.request_page,
                    title: "Request Refund",
                    onTap: () {
                      context.push('/refundPage');
                    },
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.person,
                    title: "Edit Profile",
                    onTap: () {
                      context.go('/editProfile');
                    },
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.timer,
                    title: "Notification Delay",
                    subtitle:
                    "Minutes you’re notified before machine finish",
                    trailing: _loadingDelay
                        ? const SizedBox(
                      height: 110,
                      width: 110,
                      child: CircularProgressIndicator(strokeWidth: 4),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                            Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                            onPressed: () async {
                              if (notificationDelay < 30) {
                                final newDelay = notificationDelay + 1;
                                await _updateDelay(newDelay);
                              }
                            },
                          ),
                        ),
                    SizedBox(
                      width: 40,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          ("  " + "$notificationDelay"),
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'RobotoMono',
                            color: Theme.of(context).colorScheme.fontSecondary,
                          ),
                        ),
                      ),
                    ),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                            Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.remove,
                                color: Colors.white, size: 20),
                            onPressed: () async {
                              if (notificationDelay > 0) {
                                final newDelay = notificationDelay - 1;
                                await _updateDelay(newDelay);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
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