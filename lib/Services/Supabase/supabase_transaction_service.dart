import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTransactionService extends TransactionService{

  late final SupabaseClient _client;

  SupabaseTransactionService({required SupabaseClient client}){
    _client = client;
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionsForUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('transactions')
        .select('id, amount, description, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> recordTransaction({
    required double amount,
    required String description,
    required String type,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('transactions').insert({
      'user_id': user.id,
      'amount': amount,
      'description': description,
      'type': type,
    });
  }

  @override
  Future<void> recordRefundRequest({
    required String transaction_id,
    required String description,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('Refunds').insert({
      'user_id': user.id,
      'transaction_id': transaction_id,
      'description': description
    });
  }

}