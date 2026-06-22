import 'package:clean_stream_laundry_app/logic/services/admin_wallet_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAdminWalletService implements AdminWalletService {
  final SupabaseClient client;

  SupabaseAdminWalletService({required this.client});

  @override
  Future<List<Map<String, dynamic>>> searchWallets(String query) async {
    final trimmed = query.trim();
    final baseQuery = client
        .from('wallet_balances')
        .select(
          'wallet_account_id,user_id,status,paid_balance_cents,promo_balance_cents,total_balance_cents',
        );

    if (trimmed.isEmpty) {
      final response = await baseQuery.limit(25);
      return (response as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
    }

    final walletIds = <String>{};
    final userIds = <String>{};
    final escaped = trimmed.replaceAll(',', r'\,');

    try {
      final profileRows = await client
          .from('profiles')
          .select('id')
          .or('email.ilike.%$escaped%,full_name.ilike.%$escaped%')
          .limit(25);
      for (final row in profileRows as List) {
        final id = (row as Map)['id'] as String?;
        if (id != null) userIds.add(id);
      }
    } catch (_) {
      // Search still works by wallet and Stripe reference if profile fields differ.
    }

    try {
      final loadRows = await client
          .from('wallet_loads')
          .select('wallet_account_id')
          .or(
            'stripe_payment_intent_id.ilike.%$escaped%,stripe_checkout_session_id.ilike.%$escaped%,stripe_charge_id.ilike.%$escaped%',
          )
          .limit(25);
      for (final row in loadRows as List) {
        final id = (row as Map)['wallet_account_id'] as String?;
        if (id != null) walletIds.add(id);
      }
    } catch (_) {
      // Older data may not have Stripe IDs; fall through to wallet/user matching.
    }

    final response = await baseQuery.limit(100);
    final rows = (response as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    final lower = trimmed.toLowerCase();

    return rows.where((row) {
      return walletIds.contains(row['wallet_account_id']) ||
          userIds.contains(row['user_id']) ||
          row.values.any(
            (value) =>
                value != null && value.toString().toLowerCase().contains(lower),
          );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getWalletDetail(String walletAccountId) async {
    final balance = await client
        .from('wallet_balances')
        .select()
        .eq('wallet_account_id', walletAccountId)
        .single();
    final loads = await client
        .from('wallet_loads')
        .select()
        .eq('wallet_account_id', walletAccountId)
        .order('created_at', ascending: false);
    final redemptions = await client
        .from('wallet_redemptions')
        .select()
        .eq('wallet_account_id', walletAccountId)
        .order('created_at', ascending: false);
    final ledger = await client
        .from('wallet_ledger_entries')
        .select()
        .eq('wallet_account_id', walletAccountId)
        .order('created_at', ascending: false);

    return {
      'balance': balance,
      'loads': loads,
      'redemptions': redemptions,
      'ledger': ledger,
    };
  }

  @override
  Future<void> adjustWallet({
    required String walletAccountId,
    required int amountCents,
    required int paidAmountCents,
    required int promoAmountCents,
    required String note,
  }) async {
    await client.rpc(
      'admin_adjust_wallet',
      params: {
        'wallet_id': walletAccountId,
        'amount_cents': amountCents,
        'paid_amount_cents': paidAmountCents,
        'promo_amount_cents': promoAmountCents,
        'adjustment_note': note,
      },
    );
  }

  @override
  Future<void> lockWallet(String walletAccountId, bool locked) async {
    await client.rpc(
      'admin_set_wallet_status',
      params: {
        'wallet_id': walletAccountId,
        'new_status': locked ? 'locked' : 'active',
        'status_note': locked
            ? 'Wallet locked by admin'
            : 'Wallet unlocked by admin',
      },
    );
  }

  @override
  Future<void> recordCashRedemptionOrStripeRefund({
    required String walletAccountId,
    required int amountCents,
    required String note,
  }) async {
    await client.rpc(
      'admin_record_legal_cash_redemption',
      params: {
        'wallet_id': walletAccountId,
        'amount_cents': amountCents.abs(),
        'stripe_refund_id': null,
        'redemption_note': note,
      },
    );
  }

  @override
  Future<void> recordDeletedAccountComplaint({
    required String walletAccountId,
    required String note,
    String resolution = 'denied',
  }) async {
    await client.rpc(
      'record_deleted_account_complaint',
      params: {
        'wallet_id': walletAccountId,
        'complaint_note': note,
        'resolution': resolution,
      },
    );
  }
}
