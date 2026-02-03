import 'package:clean_stream_laundry_app/logic/theme/theme.dart';
import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontSecondary,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontSecondary,
            fontSize: 12,
          ),
        )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}