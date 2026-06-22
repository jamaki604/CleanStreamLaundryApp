import 'package:clean_stream_laundry_app/logic/models/wallet_balance.dart';
import 'package:clean_stream_laundry_app/logic/models/wallet_ledger_entry.dart';
import 'package:clean_stream_laundry_app/logic/services/payment_service.dart';
import 'package:clean_stream_laundry_app/logic/services/wallet_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseWalletService implements WalletService {
  final SupabaseClient client;
  final PaymentService paymentService;

  SupabaseWalletService({required this.client, required this.paymentService});

  String get _userId {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user logged in');
    }
    return userId;
  }

  @override
  Future<WalletBalance> getBalance() async {
    final response = await client
        .from('wallet_balances')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    if (response == null) {
      return WalletBalance.empty();
    }

    return WalletBalance.fromJson(response);
  }

  @override
  Future<void> loadCard(int amountCents) async {
    await paymentService.makePayment(
      amountCents / 100.0,
      purpose: PaymentPurpose.walletLoad,
    );
  }

  @override
  Future<Map<String, dynamic>> redeemForMachine({
    required int machineId,
    required int amountCents,
    String? note,
  }) async {
    final response = await client.rpc(
      'redeem_wallet_for_machine',
      params: {
        'target_user_id': _userId,
        'target_machine_id': machineId,
        'amount_cents': amountCents,
        'redemption_note': note,
      },
    );

    return Map<String, dynamic>.from(response as Map);
  }

  @override
  Future<List<WalletLedgerEntry>> getLedger() async {
    final balance = await getBalance();
    if (balance.walletAccountId.isEmpty) {
      return [];
    }

    final response = await client
        .from('wallet_ledger_entries')
        .select()
        .eq('wallet_account_id', balance.walletAccountId)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (entry) => WalletLedgerEntry.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }
}
