import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:clean_stream_laundry_app/features/widgets/base_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum LegalPageType { privacy, terms, loyaltyCard }

class LegalPage extends StatelessWidget {
  final LegalPageType type;

  const LegalPage({super.key, required this.type});

  String get title => switch (type) {
    LegalPageType.privacy => 'Privacy Policy',
    LegalPageType.terms => 'Terms of Service',
    LegalPageType.loyaltyCard => 'Loyalty Card Terms',
  };

  List<String> get paragraphs => switch (type) {
    LegalPageType.privacy => const [
      'Clean Stream collects the account, contact, payment reference, machine usage, refund, maintenance, location, and support information needed to provide laundry services and operate the app.',
      'Clean Stream does not sell personal information or store complete payment-card numbers. Card payments are processed by Stripe, machine vending is provided through Nayax, and application data is hosted through Supabase.',
      'When an account is deleted, app access and profile information are removed or anonymized. Limited transaction, wallet, dispute, fraud-prevention, tax, accounting, and compliance records may be retained as described in the current public policy.',
    ],
    LegalPageType.terms => const [
      'Use of Clean Stream Laundry services is subject to account eligibility, payment authorization, machine availability, and posted service rules.',
      'If a paid machine vend is rejected, voided, or times out, Clean Stream will initiate the applicable card refund or wallet reversal. Laundry refunds may be reviewed by support using the related payment and machine records.',
      'The current public Terms of Service govern use of the website, app, payments, wallet, and connected laundry services.',
    ],
    LegalPageType.loyaltyCard => const [
      'Loyalty Card loads are final sale prepaid Clean Stream Laundry credit. Balance is usable only for eligible Clean Stream Laundry services, is not a bank account, does not earn interest, and is not redeemable for cash except where required by law.',
      'Promotional bonus credits have no cash value and may be subject to separate terms. Promotional credit is tracked separately from paid credit and is applied before paid credit when a wallet payment is used.',
      'Deleting your account removes app access. Clean Stream may retain anonymized wallet, ledger, load, redemption, and complaint records for legal, tax, accounting, dispute, fraud-prevention, and compliance purposes. Deleted wallets are not normally restored or reattached.',
    ],
  };

  Uri get publicUrl => Uri.parse(switch (type) {
    LegalPageType.privacy => 'https://cleanstreamlaundry.com/privacy',
    LegalPageType.terms => 'https://cleanstreamlaundry.com/terms',
    LegalPageType.loyaltyCard => 'https://cleanstreamlaundry.com/terms',
  });

  Future<void> _openPublicPolicy(BuildContext context) async {
    if (!await launchUrl(publicUrl, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the public policy.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontSecondary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                for (final paragraph in paragraphs) ...[
                  Text(
                    paragraph,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontSecondary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 4),
                FilledButton.icon(
                  onPressed: () => _openPublicPolicy(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View current policy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
