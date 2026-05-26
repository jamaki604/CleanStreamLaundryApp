import 'controller.dart';
import 'widgets/notification_lead.dart';
import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:clean_stream_laundry_app/core/theme/theme_manager.dart';
import 'widgets/settings_card.dart';
import 'package:clean_stream_laundry_app/features/widgets/base_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  static const int maxNotificationLeadTime =
      SettingsController.maxNotificationLeadTime;

  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadNotificationLeadTime();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showSignOutConfirmation() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Sign Out',
          style: TextStyle(color: Theme.of(ctx).colorScheme.fontInverted),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Theme.of(ctx).colorScheme.fontInverted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await _controller.signOut();
      if (mounted) context.go('/login');
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
                  Image.asset('assets/Logo.png', width: 150, height: 150),
                  SettingsCard(
                    icon: Icons.lightbulb,
                    title: Theme.of(context).colorScheme.modeChangerText,
                    onTap: themeManager.toggleTheme,
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.money,
                    title: 'Monthly Report',
                    onTap: () async {
                      final transactions = await _controller.getTransactions();
                      if (!context.mounted) {
                        return;
                      }
                      context.push(
                        '/monthlyTransactionHistory',
                        extra: transactions,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.request_page,
                    title: 'Request Refund',
                    onTap: () => context.push('/refundPage'),
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.handyman_outlined,
                    title: 'Request Facility Maintenance',
                    onTap: () => context.push('/maintenancePage'),
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () => context.go('/editProfile'),
                  ),
                  if (kIsWeb && _controller.canUseAdminWallets) ...[
                    const SizedBox(height: 14),
                    SettingsCard(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Wallets',
                      onTap: () => context.go('/admin/wallets'),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.timer,
                    title: 'Notify Before Finish',
                    subtitle: "Minutes you're notified before machine finish",
                    trailing: _controller.isLoadingDelay
                        ? const SizedBox(
                            height: 110,
                            width: 110,
                            child: CircularProgressIndicator(strokeWidth: 4),
                          )
                        : NotificationLead(
                            value: _controller.notificationLeadTime,
                            onIncrement: _controller.increment,
                            onDecrement: _controller.decrement,
                          ),
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: _showSignOutConfirmation,
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => context.push('/legal/privacy'),
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () => context.push('/legal/terms'),
                  ),
                  const SizedBox(height: 14),
                  SettingsCard(
                    icon: Icons.card_membership_outlined,
                    title: 'Loyalty Card Terms',
                    onTap: () => context.push('/legal/loyalty-card'),
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
