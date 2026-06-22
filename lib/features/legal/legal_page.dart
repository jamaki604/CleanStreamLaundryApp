import 'package:clean_stream_laundry_app/core/theme/theme.dart';
import 'package:clean_stream_laundry_app/features/widgets/base_page.dart';
import 'package:flutter/material.dart';

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
      'Clean Stream may collect account, contact, payment reference, machine usage, refund, maintenance, and support information needed to provide laundry services and operate the app.',
      'When an account is deleted, app access is removed and personal profile information is removed or anonymized where possible. Clean Stream may retain limited transaction, wallet, balance, dispute, fraud-prevention, tax, accounting, and compliance records where legally or operationally required.',
      'Final public legal URLs should replace this in-app placeholder before release.',
    ],
    LegalPageType.terms => const [
      'Use of Clean Stream Laundry services is subject to account eligibility, payment authorization, machine availability, and posted service rules.',
      'Laundry refunds may be reviewed by support when a machine or service issue occurs. Approved remedies may be returned to the wallet or handled another way at Clean Stream discretion and as required by law.',
      'Final public legal URLs should replace this in-app placeholder before release.',
    ],
    LegalPageType.loyaltyCard => const [
      'Loyalty Card loads are final sale prepaid Clean Stream Laundry credit. Balance is usable only for eligible Clean Stream Laundry services, is not a bank account, does not earn interest, and is not redeemable for cash except where required by law.',
      'Promotional bonus credits have no cash value and may be subject to separate terms. Promotional credit is tracked separately from paid credit and is applied before paid credit when a wallet payment is used.',
      'Deleting your account removes app access. Clean Stream may retain anonymized wallet, ledger, load, redemption, and complaint records for legal, tax, accounting, dispute, fraud-prevention, and compliance purposes. Deleted wallets are not normally restored or reattached.',
    ],
  };

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
