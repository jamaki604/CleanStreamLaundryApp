class WalletBalance {
  final String walletAccountId;
  final String status;
  final int paidBalanceCents;
  final int promoBalanceCents;
  final int totalBalanceCents;

  const WalletBalance({
    required this.walletAccountId,
    required this.status,
    required this.paidBalanceCents,
    required this.promoBalanceCents,
    required this.totalBalanceCents,
  });

  double get paidBalance => paidBalanceCents / 100.0;
  double get promoBalance => promoBalanceCents / 100.0;
  double get totalBalance => totalBalanceCents / 100.0;

  factory WalletBalance.empty() => const WalletBalance(
    walletAccountId: '',
    status: 'active',
    paidBalanceCents: 0,
    promoBalanceCents: 0,
    totalBalanceCents: 0,
  );

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      walletAccountId: json['wallet_account_id'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      paidBalanceCents: (json['paid_balance_cents'] as num?)?.toInt() ?? 0,
      promoBalanceCents: (json['promo_balance_cents'] as num?)?.toInt() ?? 0,
      totalBalanceCents: (json['total_balance_cents'] as num?)?.toInt() ?? 0,
    );
  }
}
