class WalletLedgerEntry {
  final int id;
  final String entryType;
  final int amountCents;
  final int paidAmountCents;
  final int promoAmountCents;
  final int? machineId;
  final String? stripePaymentIntentId;
  final String? stripeChargeId;
  final String? stripeRefundId;
  final String? note;
  final DateTime createdAt;

  const WalletLedgerEntry({
    required this.id,
    required this.entryType,
    required this.amountCents,
    required this.paidAmountCents,
    required this.promoAmountCents,
    required this.createdAt,
    this.machineId,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.stripeRefundId,
    this.note,
  });

  factory WalletLedgerEntry.fromJson(Map<String, dynamic> json) {
    return WalletLedgerEntry(
      id: (json['id'] as num).toInt(),
      entryType: json['entry_type'] as String,
      amountCents: (json['amount_cents'] as num).toInt(),
      paidAmountCents: (json['paid_amount_cents'] as num?)?.toInt() ?? 0,
      promoAmountCents: (json['promo_amount_cents'] as num?)?.toInt() ?? 0,
      machineId: (json['machine_id'] as num?)?.toInt(),
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      stripeChargeId: json['stripe_charge_id'] as String?,
      stripeRefundId: json['stripe_refund_id'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
