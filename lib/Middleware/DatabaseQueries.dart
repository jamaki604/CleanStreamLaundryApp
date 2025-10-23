import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:core';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  final SupabaseClient _client = Supabase.instance.client;


  Future<void> recordTransaction({
    required double amount,
    required String description,
    required String type,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    final response = await _client.from('transactions').insert({
      'user_id': user.id,
      'amount': amount,
      'description': description,
      'type': type,
    });

    if (response.error != null) {
      print("❌ Error inserting transaction: ${response.error!.message}");
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionsForUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}